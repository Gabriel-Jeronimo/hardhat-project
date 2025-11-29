// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {QuotaData} from "../types/Quota.sol";
import {ICommonErrors} from "../interfaces/ICommonErrors.sol";
import {IQuotaErrors} from "../interfaces/IQuotaErrors.sol";
import {SafeBatch} from "../utils/SafeBatch.sol";

abstract contract QuotaState is ICommonErrors, SafeBatch {
    /// @dev Registry an QuotaData by Quota Id
    mapping(uint => QuotaData) internal quotaData;

    /// @dev List of quotas id
    uint256[] internal quotaList;

    modifier onlyIfQuotaIsUnlocked(uint256 quotaId) {
        if (_isQuotaLocked(quotaId)) {
            revert IQuotaErrors.QuotaIsLocked(quotaId);
        }
        _;
    }

    /**
     * @dev Return quota isLocked value
     * @param quotaId The ID of the quota
     * @return A boolean indicating whether the quota is locked or not.
     */
    function _isQuotaLocked(uint256 quotaId) internal view returns (bool) {
        return quotaData[quotaId].isLocked;
    }
}
