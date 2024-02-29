// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

type T_GoodId is bytes32;

using {equal as ==, unequal as !=} for T_GoodId global;

import {S_GoodKey} from "./S_GoodKey.sol";

function equal(T_GoodId a, T_GoodId b) pure returns (bool) {
    if (T_GoodId.unwrap(a) == T_GoodId.unwrap(b)) {
        return true;
    } else {
        return false;
    }
}

function unequal(T_GoodId a, T_GoodId b) pure returns (bool) {
    if (T_GoodId.unwrap(a) != T_GoodId.unwrap(b)) {
        return true;
    } else {
        return false;
    }
}

/// @notice Library for computing the ID of a pool
library L_GoodIdLibrary {
    function toId(S_GoodKey memory goodKey) internal pure returns (T_GoodId) {
        return T_GoodId.wrap(keccak256(abi.encode(goodKey)));
    }
}
