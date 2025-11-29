// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {QuotaData} from "../types/Quota.sol";
import {IQuota} from "./IQuota.sol";

interface IQuotaMetadata is IQuota {
    /**
     * @notice Return the quota data
     * @param quotaId quota id
     */
    function getQuota(uint256 quotaId) external view returns (QuotaData memory);
}
