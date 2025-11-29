// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IQuotaMetadata} from "../interfaces/IQuotaMetadata.sol";
import {QuotaData} from "../types/Quota.sol";
import {Quota} from "./Quota.sol";
import {IQuota} from "../interfaces/IQuota.sol";

abstract contract QuotaMetadata is IQuotaMetadata, Quota {
    /// @inheritdoc IQuotaMetadata
    function getQuota(
        uint256 quotaId
    ) external view override returns (QuotaData memory) {
        return quotaData[quotaId];
    }
}
