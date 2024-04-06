// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {S_GoodKey} from "./L_Struct.sol";

/// @notice Library for computing the ID of a pool
library L_GoodIdLibrary {
    function toId(S_GoodKey memory goodKey) internal pure returns (bytes32) {
        return keccak256(abi.encode(goodKey));
    }
}
