
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

interface IERC20NonStandard {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    function balanceOf(address account) external view returns (uint256);
}
