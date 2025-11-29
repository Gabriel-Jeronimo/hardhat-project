// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IQuotaMetadata} from "./IQuotaMetadata.sol";

interface IQuotaGroupable is IQuotaMetadata {
    /**
     * Notice that a basket has been succeeded
     * @param referenceQuotaId ID from the quota who represents the group
     * @param groupQuotasId Quotas ID to be added in the group
     */
    event Basket(uint256 indexed referenceQuotaId, uint256[] groupQuotasId);

    /**
     * Notice that a unbasket has been succeeded
     * @param referenceQuotaId Quota ID who used to represented the group
     */
    event UnBasket(uint256 indexed referenceQuotaId);

    /**
     * Group two or more single quotas into a new basket quota
     * @param referenceQuotaId array of reference quota IDs
     * @param groupQuotasId array of quotas to be basket
     * @custom:event emits Basket when quotas are successfully grouped into a basket.
     * @custom:throws QuotaIsNotAvailable If any quota involved is not AVAILABLE.
     * @custom:throws QuotaIdDoesntExists If any quota ID does not exist.
     * @custom:throws GroupIdMismatch If the groupId of the reference quota does not match the groupId of the group quotas.
     * @custom:throws QuotaNotSingle if the group quota is not SINGLE.
     */
    function basket(
        uint256 referenceQuotaId,
        uint256[] memory groupQuotasId
    ) external;

    /**
     * Ungroup a basket quota
     * @dev reference quota ID MUST be valid
     * @dev update the status of all quotas to SINGLE_AVAILABLE
     * @dev clean the group property of all quotas
     * @dev msg.sender MUST have the TOKEN_MANAGER_ROLE role
     * @dev emit UnBasket event
     * @param referenceQuotaId the reference quota ID of the group
     */
    function unBasket(uint256 referenceQuotaId) external;
}
