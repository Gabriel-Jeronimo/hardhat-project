// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * SINGLE:                      A single quota, with a empty asset series
 * BASKET:                      A quota that is part of a group of quotas, either as a reference or as a member
 */
enum AssetTypeSet {
    SINGLE,
    BASKET
}

/** Quota life cycle
 * AVAILABLE:                Single quota available for auction
 * RESET_ZERO:               A member of a group of quotas
 * SOLD:                     Sold in a auction
 * LIQUIDATED:               Sold and the asset transfer has been completed
 */
enum QuotaStatus {
    AVAILABLE,
    RESET_ZERO,
    SOLD,
    LIQUIDATED
}

// Quota status
enum OriginalStatus {
    ACTIVE,
    CANCELED
}

struct QuotaData {
    uint256 tokenId;
    string ticker;
    string groupId;
    uint256 assetId;
    string assetCode;
    string groupCode;
    uint256[] assetsSeries;
    OriginalStatus assetOriginalStatus;
    QuotaStatus assetStatus;
    string creationTimestamp;
    string updateTimestamp;
    string comments;
    string assetSubcategory;
    uint256 installmentsQtyTotal;
    uint256 installmentsQtyPaidno;
    string investmentDateEnd;
    uint256 cancelInvestmentDate;
    string installmentCurrentValue;
    string reserveFundToPayPercent;
    string administratorServiceFee;
    string investmentValue;
    string commonFundPercentagePaid;
    string commonFundValuePaid;
    string debitBalance;
    string groupTermLife;
    uint256 currentDefaultQuantity;
    string installmentDueDate;
    string contractReserveFundRate;
    string totalValue;
    string contractValuePaid;
    uint256 tokenDisableDate;
    uint256 bidOfferValue;
    uint256 bidOfferTimestamp;
    string auctionClosedDate;
    string assetTransferDate;
    uint256 assetLiquidationDate;
    uint256 discountPercentageFloor;
    uint256 discountValueApplied;
    AssetTypeSet assetTypeSet;
    string investmentDateStart;
    bool isLocked;
}
