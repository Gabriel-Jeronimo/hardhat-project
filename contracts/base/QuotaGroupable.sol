// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IQuotaGroupable} from "../interfaces/IQuotaGroupable.sol";
import {QuotaMetadata} from "./QuotaMetadata.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {QuotaStatus, AssetTypeSet, OriginalStatus} from "../types/Quota.sol";
import {IQuotaErrors} from "../interfaces/IQuotaErrors.sol";

abstract contract QuotaGroupable is IQuotaGroupable, QuotaMetadata, Pausable {
    /// @inheritdoc IQuotaGroupable
    function basket(
        uint256 referenceQuotaId,
        uint256[] memory groupQuotasId
    )
        external
        override
        whenNotPaused
        allowedInteraction(groupQuotasId.length)
        onlyIfQuotaExists(referenceQuotaId)
        onlyIfQuotaIsUnlocked(referenceQuotaId)
    {

        // Verify that the reference quota is eligible for being a basket
        if (quotaData[referenceQuotaId].assetStatus != QuotaStatus.AVAILABLE) {
            revert IQuotaErrors.QuotaIsNotAvailable(referenceQuotaId);
        }

        quotaData[referenceQuotaId].assetTypeSet = AssetTypeSet.BASKET;

        string memory expectedGroupId;
        if (quotaData[referenceQuotaId].assetsSeries.length == 0) {
            // New basket: use the first group quota's group ID
            expectedGroupId = quotaData[groupQuotasId[0]].groupId;
        } else {
            // Existing basket: use the group ID from the first asset in the series
            uint256 firstAssetId = quotaData[referenceQuotaId].assetsSeries[0];
            expectedGroupId = quotaData[firstAssetId].groupId;
        }


        for (uint256 i = 0; i < groupQuotasId.length; i++) {
            uint256 quotaId = groupQuotasId[i];
            
            _verifyGroupQuotaIsEligibleForBasket(quotaId);

            string memory currentGroupId = quotaData[quotaId].groupId;
            if (
                keccak256(bytes(expectedGroupId)) !=
                keccak256(bytes(currentGroupId))
            ) {
                revert GroupIdMismatch(expectedGroupId);
            }

            quotaData[referenceQuotaId].assetsSeries.push(quotaId);
            
            quotaData[quotaId].assetStatus = QuotaStatus.RESET_ZERO;
            quotaData[quotaId].assetTypeSet = AssetTypeSet.BASKET;
        }



        emit Basket(referenceQuotaId, groupQuotasId);
    }

    /// @inheritdoc IQuotaGroupable
    function unBasket(
        uint256 referenceQuotaId
    )
        external
        override
        whenNotPaused
        onlyIfQuotaExists(referenceQuotaId)
        onlyIfQuotaIsUnlocked(referenceQuotaId)
    {
        if (quotaData[referenceQuotaId].assetTypeSet != AssetTypeSet.BASKET) {
            revert IQuotaErrors.QuotaNotBasket(referenceQuotaId);
        }

        if (quotaData[referenceQuotaId].assetStatus != QuotaStatus.AVAILABLE) {
            revert IQuotaErrors.QuotaIsNotAvailable(referenceQuotaId);
        }

        _unBasket(referenceQuotaId);
        emit UnBasket(referenceQuotaId);
    }

    /**
     * @dev Verifies if a quota can be added to a basket by checking several conditions.
     * @dev Reverts with appropriate error messages if any condition is not met.
     * @param quotaId The ID of the quota to verify.
     * @return bool Returns true if all conditions are met.
     */
    function _verifyGroupQuotaIsEligibleForBasket(
        uint256 quotaId
    ) internal view onlyIfQuotaIsUnlocked(quotaId) returns (bool) {
        if (!exists(quotaId)) {
            revert IQuotaErrors.QuotaIdDoesntExists(quotaId);
        }

        if (quotaData[quotaId].assetStatus != QuotaStatus.AVAILABLE) {
            revert IQuotaErrors.QuotaIsNotAvailable(quotaId);
        }

        if (quotaData[quotaId].assetTypeSet != AssetTypeSet.SINGLE) {
            revert IQuotaErrors.QuotaIsNotSingle(quotaId);
        }

        return true;
    }

    /**
     *
     * Update a list of quotas from basket to single aggregation
     * @param referenceQuotaId the reference quota id of the group
     */
    function _unBasket(uint256 referenceQuotaId) internal {
        uint256[] memory empty_quotas_ids = new uint256[](0);
        uint256[] memory correlatedQuotaIds = quotaData[referenceQuotaId]
            .assetsSeries;

        for (uint quota = 0; quota < correlatedQuotaIds.length; quota++) {
            uint256 quotaId = correlatedQuotaIds[quota];

            quotaData[quotaId].assetStatus = QuotaStatus.AVAILABLE;
            quotaData[quotaId].assetTypeSet = AssetTypeSet.SINGLE;
            quotaData[quotaId].assetsSeries = empty_quotas_ids;
        }

        quotaData[referenceQuotaId].assetStatus = QuotaStatus.AVAILABLE;
        quotaData[referenceQuotaId].assetTypeSet = AssetTypeSet.SINGLE;
        quotaData[referenceQuotaId].assetsSeries = empty_quotas_ids;
    }
}
