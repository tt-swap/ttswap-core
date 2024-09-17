// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";

/// @title Proof Interface
/// @notice Contains interfaces for proof-related operations
interface I_Proof {
    /// @notice Returns the total number of proofs in the market
    /// @return proofnum_ The total number of proofs
    function totalSupply() external view returns (uint256 proofnum_);

    /// @notice Transfers a token with a permit
    /// @param from The current owner of the token
    /// @param to The new owner of the token
    /// @param tokenId The ID of the token being transferred
    /// @param _data Additional data with no specified format
    /// @param deadline The timestamp by which the signature must be submitted
    /// @param signature The signature for the permit
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;
}
