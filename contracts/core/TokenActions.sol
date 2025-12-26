// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

import "./EconomicsCore.sol";
import "../interfaces/IERC20NonStandard.sol";
abstract contract TokenActions is EconomicsCore {

    error TransferInFailed();
    error TransferOutFailed();

    function doTransferIn(address asset, address from, uint amount) internal returns (uint) {
        uint256 preTransferBalance = IERC20NonStandard(asset).balanceOf(address(this));
        IERC20NonStandard(asset).transferFrom(from, address(this), amount);
        bool success;
        assembly ("memory-safe") {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of override external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        if (!success) revert TransferInFailed();
        return IERC20NonStandard(asset).balanceOf(address(this)) - preTransferBalance;
    }

    function doTransferOut(address asset, address to, uint amount) internal {
        IERC20NonStandard(asset).transfer(to, amount);
        bool success;
        assembly ("memory-safe") {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of override external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        if (!success) revert TransferOutFailed();
    }
}
