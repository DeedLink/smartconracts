// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Functions {
    function isInArray(address[] memory arr, address addr, uint256 length) internal pure returns (bool) {
        for (uint256 i = 0; i < length; i++) {
            if (arr[i] == addr) return true;
        }
        return false;
    }
}