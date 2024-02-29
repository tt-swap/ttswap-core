// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {S_ProofKey} from "./S_ProofKey.sol";

type T_ProofId is bytes32;

/// @notice Library for computing the ID of a Good
library L_ProofIdLibrary {
    function toId(S_ProofKey memory proofKey) internal pure returns (T_ProofId) {
        return T_ProofId.wrap(keccak256(abi.encode(proofKey)));
    }
}
