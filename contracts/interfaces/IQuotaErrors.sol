// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IQuotaErrors {
    /**
     * Notice that an error ocurred in mintBatch function.
     * @param assetId ID of the asset where the error occurred
     * @param reason Error message with the details of the error
     */
    event MintError(uint256 indexed assetId, string reason);

    /**
     * Notice that an error ocurred in sold function.
     * @param assetId ID of the asset where the error occurred
     * @param reason Error message with the details of the error
     */
    event SoldError(uint256 indexed assetId, string reason);

    /**
     * Notice that an error ocurred in cancel function.
     * @param assetId ID of the asset where the error occurred
     * @param reason Error message with the details of the error
     */
    event CancelError(uint256 indexed assetId, string reason);

    /// @notice Thrown when a quota id already exists
    /// @param quotaId The ID of the quota that already exists
    error QuotaIdAlreadyExists(uint256 quotaId);

    /// @notice Thrown when a quota ID does not exist
    /// @param quotaId The ID of the quota that does not exist
    error QuotaIdDoesntExists(uint256 quotaId);

    /// @notice Thrown when the quota is not a single quota
    /// @param quotaId The ID of the quota that is not single
    error QuotaIsNotSingle(uint256 quotaId);

    /// @notice Thrown when a quota is not active
    /// @param quotaId The ID of the quota that is not active
    error QuotaIsNotActive(uint256 quotaId);

    /// @notice Thrown when a quota is not sold
    /// @param quotaId The ID of the quota that has not been sold
    error QuotaIsNotSold(uint256 quotaId);

    /// @notice Thrown when the specified quota is not available
    /// @param quotaId The ID of the quota that is not available
    error QuotaIsNotAvailable(uint256 quotaId);

    /// @notice Thrown when there is a mismatch between the expected and actual quota ID
    /// @param quotaId The actual quota ID that caused the mismatch
    /// @param expectedQuotaId The expected quota ID
    error QuotaIdMismatch(uint256 quotaId, uint256 expectedQuotaId);

    /// @notice Thrown when the group id in a basket quota mismatch.
    /// @param groupId The identifier of the quota where the mismatch occurred.
    error GroupIdMismatch(string groupId);

    /// @notice Thrown when the provided group ID is empty or invalid.
    error EmptyOrInvalidGroupId();

    /**
     * @notice Thrown when the asset type set of the quota is not 'BASKET'.
     * @param referenceQuotaId The ID of the quota.
     */
    error QuotaNotBasket(uint256 referenceQuotaId);

    /**
     * @notice Thrown when the asset is locked
     * @param quotaId The ID of the quota.
     */
    error QuotaIsLocked(uint256 quotaId);
}
