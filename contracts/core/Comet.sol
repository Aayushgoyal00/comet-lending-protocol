// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;
import "./CometBaseActions.sol";
import "./CometCollateral.sol";

contract Comet is CometBaseActions,CometCollateral{

    /**
     * @param asset The asset to supply
     * @param amount The quantity to supply
     */
    function supply(address asset, uint amount) override external {
        return supplyInternal(msg.sender, msg.sender, msg.sender, asset, amount);
    }

    function supplyInternal(address operator, address from, address dst, address asset, uint amount) internal nonReentrant {
        // if (isSupplyPaused()) revert Paused();
        // if (!hasPermission(from, operator)) revert Unauthorized();

        if (asset == baseToken) {
            if (amount == type(uint256).max) {
                // remaining
                amount = borrowBalanceOf(dst);
            }
            return supplyBase(from, dst, amount);
        } else {
            return supplyCollateral(from, dst, asset, safe128(amount));
        }
    }
}