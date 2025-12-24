// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

import "../storage/ComotStorage.sol";
import "../math/CometAccounting.sol";
import "../config/CometConfiguration.sol";

abstract contract CometBaseActions is CometStorage, CometAccounting, CometConfiguration {


    /**
     * @dev The change in principal broken into repay and supply amounts
     * @dev This function is only about repay & supply, not new borrows.
     */
    function repayAndSupplyAmount(int104 oldPrincipal, int104 newPrincipal) internal pure returns (uint104, uint104) {
        // If the new principal is less than the old principal, then no amount has been repaid or supplied
        if (newPrincipal < oldPrincipal) return (0, 0);

        if (newPrincipal <= 0) {
            return (uint104(newPrincipal - oldPrincipal), 0);
        } else if (oldPrincipal >= 0) {
            return (0, uint104(newPrincipal - oldPrincipal));
        } else {
            return (uint104(-oldPrincipal), uint104(newPrincipal));
        }
    }

    /**
     * @dev The change in principal broken into withdraw and borrow amounts
     * @dev This function is only about withdraw & borrow, not repayments.
     */
    function withdrawAndBorrowAmount(int104 oldPrincipal, int104 newPrincipal) internal pure returns (uint104, uint104) {
        // If the new principal is greater than the old principal, then no amount has been withdrawn or borrowed
        if (newPrincipal > oldPrincipal) return (0, 0);

        if (newPrincipal >= 0) {
            return (uint104(oldPrincipal - newPrincipal), 0);
        } else if (oldPrincipal <= 0) {
            return (0, uint104(oldPrincipal - newPrincipal));
        } else {
            return (uint104(oldPrincipal), uint104(-newPrincipal));
        }
    }

    /**
     * @dev Write updated principal to store and tracking participation
    
     */
    function updateBasePrincipal(address account, UserBasic memory basic, int104 principalNew) internal {
        // int104 principal = basic.principal;
        basic.principal = principalNew;

        //  Commenting the rewards logic for future implementation

        // if (principal >= 0) {
        //     uint indexDelta = uint256(trackingSupplyIndex - basic.baseTrackingIndex);
        //     basic.baseTrackingAccrued += safe64(uint104(principal) * indexDelta / trackingIndexScale / accrualDescaleFactor);
        // } else {
        //     uint indexDelta = uint256(trackingBorrowIndex - basic.baseTrackingIndex);
        //     basic.baseTrackingAccrued += safe64(uint104(-principal) * indexDelta / trackingIndexScale / accrualDescaleFactor);
        // }

        // if (principalNew >= 0) {
        //     basic.baseTrackingIndex = trackingSupplyIndex;
        // } else {
        //     basic.baseTrackingIndex = trackingBorrowIndex;
        // }

        userBasic[account] = basic;
    }
}