// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

import "../storage/CometStorage.sol";
import "../math/CometAccounting.sol";
import "../config/CometConfiguration.sol";
import "../interfaces/IPriceFeed.sol";

abstract contract EconomicsCore is CometStorage, CometAccounting, CometConfiguration {
    
    uint public immutable borrowPerSecondInterestRateBase;
    uint public immutable borrowPerSecondInterestRateSlopeLow;
    uint public immutable borrowPerSecondInterestRateSlopeHigh;
    uint public immutable borrowKink;

    error TimestampTooLarge();
    error BadAsset();
    error Absurd();
    /**
     * @dev Note: Does not accrue interest first
     * @return The utilization rate of the base asset
     */
    function getUtilization() public view returns (uint) {
        uint totalSupply_ = presentValueSupply(baseSupplyIndex, totalSupplyBase);
        uint totalBorrow_ = presentValueBorrow(baseBorrowIndex, totalBorrowBase);
        if (totalSupply_ == 0) {
            return 0;
        } else {
            return totalBorrow_ * FACTOR_SCALE / totalSupply_;
        }
    }
    /**
     * @return The current timestamp
     **/
    function getNowInternal() virtual internal view returns (uint40) {
        if (block.timestamp >= 2**40) revert TimestampTooLarge();
        return uint40(block.timestamp);
    }

    /**
     * @dev Note: Does not accrue interest first
     * @param utilization The utilization to check the borrow rate for
     * @return The per second borrow rate at `utilization`
     */
    function getBorrowRate(uint utilization) public view returns (uint64) {
        if (utilization <= borrowKink) {
            // interestRateBase + interestRateSlopeLow * utilization
            return safe64(borrowPerSecondInterestRateBase + mulFactor(borrowPerSecondInterestRateSlopeLow, utilization));
        } else {
            // interestRateBase + interestRateSlopeLow * kink + interestRateSlopeHigh * (utilization - kink)
            return safe64(borrowPerSecondInterestRateBase + mulFactor(borrowPerSecondInterestRateSlopeLow, borrowKink) + mulFactor(borrowPerSecondInterestRateSlopeHigh, (utilization - borrowKink)));
        }
    }

    function getSupplyRate(uint utilization) public view returns (uint64) {
        uint borrowRate = getBorrowRate(utilization);
        return safe64(borrowRate * utilization / FACTOR_SCALE);
    }

    /**
     * @dev Calculate accrued interest indices for base token supply and borrows
     **/
    function accruedInterestIndices(uint timeElapsed) internal view returns (uint64, uint64) {
        uint64 baseSupplyIndex_ = baseSupplyIndex;
        uint64 baseBorrowIndex_ = baseBorrowIndex;
        if (timeElapsed > 0) {
            uint utilization = getUtilization();
            uint supplyRate = getSupplyRate(utilization);
            uint borrowRate = getBorrowRate(utilization);
            baseSupplyIndex_ += safe64(mulFactor(baseSupplyIndex_, supplyRate * timeElapsed));
            baseBorrowIndex_ += safe64(mulFactor(baseBorrowIndex_, borrowRate * timeElapsed));
        }
        return (baseSupplyIndex_, baseBorrowIndex_);
    }

    /**
     * @dev Accrue interest (and rewards) in base token supply and borrows
     **/
    function accrueInternal() internal {
        uint40 now_ = getNowInternal();
        uint timeElapsed = uint256(now_ - lastAccrualTime);
        if (timeElapsed > 0) {
            (baseSupplyIndex, baseBorrowIndex) = accruedInterestIndices(timeElapsed);

            // why do this later for the rewards 

            // if (totalSupplyBase >= baseMinForRewards) {
            //     trackingSupplyIndex += safe64(divBaseWei(baseTrackingSupplySpeed * timeElapsed, totalSupplyBase));
            // }
            // if (totalBorrowBase >= baseMinForRewards) {
            //     trackingBorrowIndex += safe64(divBaseWei(baseTrackingBorrowSpeed * timeElapsed, totalBorrowBase));
            // }
            
            lastAccrualTime = now_;
        }
    }

    /**
     * @notice Get the current price from a feed
     * @param priceFeed The address of a price feed
     * @return The price, scaled by `PRICE_SCALE`
     */
    function getPrice(address priceFeed) override public view returns (uint256) {
        (, int price, , , ) = IPriceFeed(priceFeed).latestRoundData();
        if (price <= 0) revert BadPrice();
        return uint256(price);
    }


        /**
     * @notice Get the i-th asset info, according to the order they were passed in originally
     * @param i The index of the asset info to get
     * @return The asset info object
     */
    function getAssetInfo(uint8 i) override public view returns (AssetInfo memory) {
        if (i >= numAssets) revert BadAsset();

        uint256 word_a;
        uint256 word_b;

        if (i == 0) {
            word_a = asset00_a;
            word_b = asset00_b;
        } else if (i == 1) {
            word_a = asset01_a;
            word_b = asset01_b;
        } else if (i == 2) {
            word_a = asset02_a;
            word_b = asset02_b;
        } else if (i == 3) {
            word_a = asset03_a;
            word_b = asset03_b;
        } else if (i == 4) {
            word_a = asset04_a;
            word_b = asset04_b;
        } else if (i == 5) {
            word_a = asset05_a;
            word_b = asset05_b;
        } else if (i == 6) {
            word_a = asset06_a;
            word_b = asset06_b;
        } else if (i == 7) {
            word_a = asset07_a;
            word_b = asset07_b;
        } else if (i == 8) {
            word_a = asset08_a;
            word_b = asset08_b;
        } else if (i == 9) {
            word_a = asset09_a;
            word_b = asset09_b;
        } else if (i == 10) {
            word_a = asset10_a;
            word_b = asset10_b;
        } else if (i == 11) {
            word_a = asset11_a;
            word_b = asset11_b;
        } else {
            revert Absurd();
        }
    }


        /**
     * @notice Check whether an account has enough collateral to borrow
     * @param account The address to check
     * @return Whether the account is minimally collateralized enough to borrow
     */
    function isBorrowCollateralized(address account) override public view returns (bool) {
        int104 principal = userBasic[account].principal;

        if (principal >= 0) {
            return true;
        }

        uint16 assetsIn = userBasic[account].assetsIn;
        int liquidity = signedMulPrice(
            presentValue(principal),
            getPrice(baseTokenPriceFeed),
            uint64(baseScale)
        );

        for (uint8 i = 0; i < numAssets; ) {
            if (isInAsset(assetsIn, i)) {
                if (liquidity >= 0) {
                    return true;
                }

                AssetInfo memory asset = getAssetInfo(i);
                uint newAmount = mulPrice(
                    userCollateral[account][asset.asset].balance,
                    getPrice(asset.priceFeed),
                    asset.scale
                );
                liquidity += signed256(mulFactor(
                    newAmount,
                    asset.borrowCollateralFactor
                ));
            }
            unchecked { i++; }
        }

        return liquidity >= 0;
    }
}
