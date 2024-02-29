// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library SafeCast {
    function toUInt128(uint256 y) internal pure returns (uint128 z) {
        require(y <= type(uint128).max);
        z = uint128(y);
    }
}
