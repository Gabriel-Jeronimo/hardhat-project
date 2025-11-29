// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {QuotaData} from "../types/Quota.sol";
import {IQuotaMetadata} from "./IQuotaMetadata.sol";
import {IQuotaGroupable} from "./IQuotaGroupable.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface IQuotaManager is IQuotaGroupable, IERC1155Receiver {
    /**
     * Notice that a quota have been created
     * @param id Created quota ID
     * @param account Address which the quota was minted
     * @param amount The amount of quotas minted
     */
    event Minted(uint256 indexed id, address account, uint256 amount);

    /**
     * Notice that a quota has been canceled
     * @param quotaIds List of canceled quota ID
     */
    event Canceled(uint256 indexed quotaIds);

    /**
     * Notice that a quota has been sold
     * @param quotaId Sold quota ID
     */
    event Sold(uint256 indexed quotaId);

    /**
     * Notice that a quota has been liquidated
     * @param quotaId Sold quota Id
     */
    event Liquidated(uint256 indexed quotaId);

    /**
     * mint a list of quotas
     * @param ids ids of quotas to be minted
     * @param amounts amount to be minted for the quotas
     * @param data metadata of quotas
     */
    function mintQuotas(
        uint256[] memory ids,
        uint256[] memory amounts,
        QuotaData[] memory data
    ) external;

    /**
     * Update a list of quotas to CANCELED status
     * @dev Batch operation
     * @dev msg.sender MUST have the TOKEN_MANAGER_ROLE role
     * @dev Quota MUST exists
     * @dev Quota MUST not be LIQUIDATED, SINGLE_RESET_ZERO
     * @dev If the quota is a basket will only cancel the reference and the group quotas
     * @dev Update tokenDisableDate to the current timestamp
     * @param ids list of quotas IDs
     */
    function cancelQuotas(uint256[] memory ids) external;

    /**
     * Set an quota status as SOLD
     * @dev Batch operation
     * @dev IDs in quotaList MUST be valid
     * @dev quota status MUST be BASKET_AVAILABLE or SINGLE_AVAILABLE
     * @dev msg.sender MUST have the TOKEN_MANAGER_ROLE role
     * @dev emit Sold event
     * @param soldQuotaList Quota IDS to update the status
     */
    function soldQuotas(uint256[] memory soldQuotaList) external;

    /**
     * Update a quota to LIQUIDATED status
     * @dev Quota MUST exist
     * @dev Quota status MUST be sold
     * @dev Update assetLiquidationDate to the current timestamp
     * @dev Update assetTransferDate to user input
     * @dev If it's a basket, turn asset series quota commonFundValuePaid into zero
     * @param id Quota to be liquidated
     * @param assetTransferDate Asset transfer date in DD-MM-YYYY format
     */
    function liquidateQuotas(
        uint256 id,
        string memory assetTransferDate
    ) external;

    /**
     * Update bidOfferValue and bidOfferTimestamp
     * @dev This function is used to update the bidOfferValue and bidOfferTimestamp fields of a quota.
     * @dev Usually, will not be called by a user but by the Auction contract when a bid in a quota happens.
     * @dev Quota MUST exist
     * @dev msg.sender MUST have the TOKEN_MANAGER_ROLE role
     * @param quotaId ID to be updated
     * @param bidOfferValue Bid value
     * @param bidOfferTimestamp Bid timestamp
     */
    function updateBidValues(
        uint256 quotaId,
        uint256 bidOfferValue,
        uint256 bidOfferTimestamp
    ) external;

    /**
     * @notice Checks if a quota with the given ID exists.
     * @param id The ID of the quota to check.
     * @return bool True if the quota exists, false otherwise.
     */
    function exists(uint256 id) external view returns (bool);

    /* Update the lock state of a quota
     * @notice ID in quotaList MUST be valid
     * @notice msg.sender must have the TOKEN_MANAGER_ROLE role
     * @param quotaId Quota ID to update lock state
     * @param state State to be used
     */
    function setLock(uint256 quotaId, bool state) external;

    /**
     * @notice Pauses all token transfers.
     * @dev This function can only be called by an account with the TOKEN_MANAGER_ROLE.
     * It triggers the internal _pause function from the Pausable contract.
     */
    function pause() external;

    /**
     * @notice Unpauses all token transfers.
     * @dev This function can only be called by an account with the TOKEN_MANAGER_ROLE.
     * It triggers the internal _unpause function from the Pausable contract.
     */
    function unpause() external;
}
