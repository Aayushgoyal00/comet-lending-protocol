// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

contract CometConfiguration {

    struct ExtConfiguration {
        bytes32 name32;
        bytes32 symbol32;
    }

    struct Configuration {

        address baseToken;
        address baseTokenPriceFeed;

        // I am not implementing governance
        // I am not implementing pausing

        // address governor;
        // address pauseGuardian;
        
        // I am also not splitting Comet.sol / CometExt.sol
        // address extensionDelegate;

// thse can be derived like this supplyRate = borrowRate × utilization

        // uint64 supplyKink;
        // uint64 supplyPerYearInterestRateSlopeLow;
        // uint64 supplyPerYearInterestRateSlopeHigh;
        // uint64 supplyPerYearInterestRateBase;


        uint64 borrowKink;
        uint64 borrowPerYearInterestRateSlopeLow;
        uint64 borrowPerYearInterestRateSlopeHigh;
        uint64 borrowPerYearInterestRateBase;

        // Remove if you trust oracle price.
        // uint64 storeFrontPriceFactor;

        uint64 trackingIndexScale;
        uint64 baseTrackingSupplySpeed;
        uint64 baseTrackingBorrowSpeed;
        uint104 baseMinForRewards;
        
        uint104 baseBorrowMin;
        uint104 targetReserves;

        AssetConfig[] assetConfigs;
    }

    struct AssetConfig {
        address asset;
        address priceFeed;
        uint8 decimals;
        uint64 borrowCollateralFactor;
        uint64 liquidateCollateralFactor;
        uint64 liquidationFactor;
        uint128 supplyCap;
    }
}
