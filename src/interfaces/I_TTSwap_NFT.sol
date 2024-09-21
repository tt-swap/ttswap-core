// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_NFT is IERC721 {
    function mint(address recipent, uint256 tokenid) external;
    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external returns (bool);
}
