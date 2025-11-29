// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IQuota} from "./interfaces/IQuota.sol";
import {IQuotaManager} from "./interfaces/IQuotaManager.sol";
import {IQuotaMetadata} from "./interfaces/IQuotaMetadata.sol";
import {IQuotaErrors} from "./interfaces/IQuotaErrors.sol";
import {IQuotaGroupable} from "./interfaces/IQuotaGroupable.sol";
import {QuotaMetadata} from "./base/QuotaMetadata.sol";
import {QuotaGroupable} from "./base/QuotaGroupable.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {Quota} from "./base/Quota.sol";
import {QuotaState} from "./base/QuotaState.sol";
import {QuotaData} from "./types/Quota.sol";
import {QuotaStatus, AssetTypeSet} from "./types/Quota.sol";
import {OriginalStatus} from "./types/Quota.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract QuotaManager is IQuotaManager, QuotaGroupable, ERC1155Holder, Ownable {
    constructor(
        string memory uri_
    ) Quota(uri_) Ownable(msg.sender) {}

    /// @inheritdoc IQuotaManager
    function mintQuotas(
        uint256[] memory ids,
        uint256[] memory amounts,
        QuotaData[] memory data
    )
        external
        override
        whenNotPaused
        allowedInteraction(ids.length)
        onlyOwner
    {
        if (ids.length != amounts.length) {
            revert LenghtMismatch();
        }

        uint256[] memory emptyQuotaList = new uint256[](0);

        for (uint i = 0; i < ids.length; i++) {
            if (exists(ids[i])) {
                emit MintError(data[i].assetId, "ID already exists");
                continue;
            }

            if (data[i].assetId == 0) {
                emit MintError(data[i].assetId, "assetId cannot be 0");
                continue;
            }

            if (amounts[i] == 0) {
                emit MintError(
                    data[i].assetId,
                    "Token must be greater than zero"
                );
                continue;
            }

            if (ids[i] != data[i].assetId) {
                emit MintError(
                    data[i].assetId,
                    "ID differs from assetId in data"
                );
                continue;
            }

            if (keccak256(bytes(data[i].groupId)) == keccak256(bytes(""))) {
                emit MintError(data[i].assetId, "GroupId is empty");
                continue;
            }

            data[i].assetStatus = QuotaStatus.AVAILABLE;
            data[i].assetTypeSet = AssetTypeSet.SINGLE;
            data[i].cancelInvestmentDate = 0;
            data[i].bidOfferTimestamp = 0;
            data[i].assetsSeries = emptyQuotaList;
            data[i].isLocked = false;
            data[i].tokenId = totalSupply();

            quotaData[ids[i]] = data[i];
            quotaList.push(ids[i]);

            _mint(address(this), ids[i], amounts[i], "");

            emit Minted(ids[i], address(this), amounts[i]);
        }
    }

    /// @inheritdoc IQuotaManager
    function cancelQuotas(
        uint256[] memory ids
    )
        public
        override
        whenNotPaused
        allowedInteraction(ids.length)
        onlyOwner
    {
        for (uint iQuotaId = 0; iQuotaId < ids.length; iQuotaId++) {
            if (
                quotaData[ids[iQuotaId]].assetStatus != QuotaStatus.AVAILABLE &&
                quotaData[ids[iQuotaId]].assetStatus != QuotaStatus.SOLD
            ) {
                emit CancelError(
                    ids[iQuotaId],
                    "Quota is not available to cancel"
                );
                continue;
            }

            if (_isQuotaLocked(ids[iQuotaId])) {
                emit CancelError(ids[iQuotaId], "Quota is locked");
                continue;
            }

            if (quotaData[ids[iQuotaId]].assetTypeSet == AssetTypeSet.BASKET) {
                uint256[] memory assetsSeries = quotaData[ids[iQuotaId]]
                    .assetsSeries;
                _unBasket(ids[iQuotaId]);

                for (
                    uint iGroupedQuota = 0;
                    iGroupedQuota < assetsSeries.length;
                    iGroupedQuota++
                ) {
                    _cancel(assetsSeries[iGroupedQuota]);

                    emit Canceled(ids[iQuotaId]);
                }
            }

            _cancel(ids[iQuotaId]);

            emit Canceled(ids[iQuotaId]);
        }
    }

    /// @inheritdoc IQuotaManager
    function soldQuotas(
        uint256[] memory soldQuotaList
    )
        external
        override
        whenNotPaused
        allowedInteraction(soldQuotaList.length)
        onlyOwner
    {
        for (uint quota = 0; quota < soldQuotaList.length; quota++) {
            uint256 quotaId = soldQuotaList[quota];
            if (!exists(quotaId)) {
                emit SoldError(quotaId, "ID doesnt exist");
                continue;
            }

            if (quotaData[quotaId].assetStatus != QuotaStatus.AVAILABLE) {
                emit SoldError(quotaId, "Quota must be available");
                continue;
            }

            quotaData[quotaId].assetStatus = QuotaStatus.SOLD;

            emit Sold(quotaId);
        }
    }

    /// @inheritdoc IQuotaManager
    function liquidateQuotas(
        uint256 id,
        string memory assetTransferDate
    )
        external
        override
        whenNotPaused
        onlyOwner
    {
        if (!exists(id)) {
            revert QuotaIdDoesntExists(id);
        }

        if (quotaData[id].assetStatus != QuotaStatus.SOLD) {
            revert QuotaIsNotSold(id);
        }

        quotaData[id].assetStatus = QuotaStatus.LIQUIDATED;
        if (keccak256(bytes(assetTransferDate)) != keccak256(bytes(""))) {
            quotaData[id].assetTransferDate = assetTransferDate;
        }

        quotaData[id].assetLiquidationDate = block.timestamp;

        emit Liquidated(id);
    }

    /// @inheritdoc IQuotaManager
    function setLock(
        uint256 quotaId,
        bool state
    )
        external
        whenNotPaused
        onlyOwner
        onlyIfQuotaExists(quotaId)
    {
        quotaData[quotaId].isLocked = state;
    }

    /// @inheritdoc IQuotaManager
    function updateBidValues(
        uint256 quotaId,
        uint256 bidOfferValue,
        uint256 bidOfferTimestamp
    )
        external
        override
        whenNotPaused
        onlyOwner
    {
        quotaData[quotaId].bidOfferValue = bidOfferValue;
        quotaData[quotaId].bidOfferTimestamp = bidOfferTimestamp;
    }

    /// @inheritdoc IQuotaManager
    function pause()
        public
        override
        onlyOwner
    {
        _pause();
    }

    /// @inheritdoc IQuotaManager
    function unpause()
        public
        override
        onlyOwner
    {
        _unpause();
    }

    /**
     * @dev Checks if the contract supports a given interface.
     *
     * This function overrides the supportsInterface function from ERC1155Holder, IERC165, and Quota.
     * It returns true if the contract supports the interface defined by `interfaceId`.
     *
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return bool True if the contract supports the given interface, false otherwise.
     *
     * Note: The implementation currently supports the interfaces defined by IQuotaManager and IQuotaGroupable.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155Holder, IERC165, Quota)
        returns (bool)
    {
        return
            interfaceId == type(IQuotaManager).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IQuotaManager
    function exists(
        uint256 id
    ) public view override(ERC1155Supply, IQuotaManager) returns (bool) {
        return super.exists(id);
    }

    function _cancel(uint256 id) internal {
        uint256 cancelTimestamp = block.timestamp;

        if (
            quotaData[id].assetStatus == QuotaStatus.LIQUIDATED ||
            quotaData[id].assetStatus == QuotaStatus.RESET_ZERO
        ) {
            emit CancelError(id, "Quota must be available");
            return;
        }

        if (!exists(id)) {
            emit CancelError(id, "ID doesnt exist");
            return;
        }

        quotaData[id].cancelInvestmentDate = cancelTimestamp;
        burn(address(this), id, this.balanceOf(address(this), id));
    }
}
