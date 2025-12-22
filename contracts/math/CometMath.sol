// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

contract CometMath {
    
    /** Custom errors **/

    error InvalidUInt64();
    error InvalidUInt104();
    error InvalidUInt128();
    error InvalidInt104();
    error InvalidInt256();
    error NegativeNumber();

    function safe64(uint num) internal pure returns(uint64){
        if(num> type(uint64).max){
            revert InvalidUInt64();
        }
        return uint64(num);
    }

    function safe104(uint num) internal pure returns(uint104){
        if(num> type(uint104).max){
            revert InvalidUInt104();
        }
        return uint104(num);
    }

    function safe128(uint num) internal pure returns(uint128){
        if(num> type(uint128).max){
            revert InvalidUInt128();
        }
        return uint128(num);
    }

    function signed104(uint104 num) internal pure returns(int104){
        if(num> uint104(type(int104).max)){
            revert InvalidInt104();
        }
        return int104(num);
    } 
    function signed256(uint256 num) internal pure returns(int256){
        if(num> uint256(type(int256).max)){
            revert InvalidInt256();
        }
        return int256(num);
    } 
   
    function unsigned104(int104 num) internal pure returns (uint104) {
            if (num < 0) revert NegativeNumber();
            return uint104(num);
    }

    function unsigned256(int256 num) internal pure returns (uint256) {
            if (num < 0) revert NegativeNumber();
            return uint256(num);
    }
    function toUInt8(bool x) internal pure returns (uint8) {
            return x ? 1 : 0;
        }

    function toBool(uint8 x) internal pure returns (bool) {
            return x != 0;
        }   
}

