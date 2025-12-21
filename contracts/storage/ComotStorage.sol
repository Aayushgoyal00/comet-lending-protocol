// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

contract CometStorage {

    uint64 internal baseSupplyIndex;
    uint64 internal baseBorrowIndex;
    uint64 internal trackingSupplyIndex;
    uint64 internal trackingBorrowIndex;
    uint104 internal totalSupplyBase;
    uint104 internal totalBorrowBase;
    uint40 internal lastAccrualTime;

    struct TotalsCollateral {
        uint128 totalSupplyAsset;
    }

    mapping(address => TotalsCollateral) public totalsCollateral;

    struct UserBasic {
        int104 principal;
        uint64 baseTrackingIndex;
        uint64 baseTrackingAccrued;
        uint16 assetsIn;
    }

    mapping(address => UserBasic) public userBasic;

    struct UserCollateral {
        uint128 balance;
    }

    mapping(address => mapping(address => UserCollateral)) public userCollateral;

    mapping(address => mapping(address => bool)) public isAllowed;

    mapping(address => uint256) public userNonce;
}
