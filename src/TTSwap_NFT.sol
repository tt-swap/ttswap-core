// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_Proof} from "./interfaces/I_Proof.sol";
import {I_TTSwap_NFT} from "./interfaces/I_TTSwap_NFT.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {ERC721Permit} from "@erc721permit/ERC721Permit.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library} from "./libraries/L_BalanceUINT256.sol";

/**
 * @title ProofManage
 * @dev Abstract contract for managing proofs as ERC721 tokens with additional functionality.
 * Inherits from I_Proof and ERC721Permit.
 */
contract TTSwap_NFT is ERC721Permit, I_TTSwap_NFT {
    using L_Proof for *;
    using L_ProofIdLibrary for S_ProofKey;
    using L_BalanceUINT256Library for T_BalanceUINT256;

    mapping(uint256 => address) internal proofsource;

    /**
     * @dev Constructor to initialize the ProofManage contract.
     */
    constructor() ERC721Permit("TTSwap NFT", "TTS") {}

    /**
     * @dev Returns the base URI for computing {tokenURI}.
     * @return string The base URI string.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "http://www.ttswap.io/nft?proofid=";
    }

    // /**
    //  * @dev Transfers ownership of a token from one address to another address.
    //  * @param from The current owner of the token.
    //  * @param to The new owner.
    //  * @param tokenId The ID of the token being transferred.
    //  */
    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) public override {
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ERC721: caller is not token owner or approved"
    //     );

    //     L_Proof.unstake(
    //         officialContract,
    //         from,
    //         proofs[tokenId].state.amount0()
    //     );
    //     _transfer(from, to, tokenId);
    //     delproofdata(tokenId, from, to);
    // }

    // /**
    //  * @dev Safely transfers the ownership of a given token ID to another address.
    //  * @param from The current owner of the token.
    //  * @param to The new owner.
    //  * @param tokenId The ID of the token to be transferred.
    //  * @param data Additional data with no specified format.
    //  */
    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory data
    // ) public override {
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ERC721: caller is not token owner or approved"
    //     );
    //     L_Proof.unstake(
    //         officialContract,
    //         from,
    //         proofs[tokenId].state.amount0()
    //     );
    //     _safeTransfer(from, to, tokenId, data);
    //     delproofdata(tokenId, from, to);
    // }

    // /**
    //  * @dev Internal function to handle proof data deletion and updates during transfer.
    //  * @param proofid The ID of the proof being transferred.
    //  * @param from The address transferring the proof.
    //  * @param to The address receiving the proof.
    //  */
    // function delproofdata(uint256 proofid, address from, address to) private {
    //     L_Proof.S_ProofState memory proofState = proofs[proofid];
    //     uint256 proofKey1 = S_ProofKey(
    //         from,
    //         proofState.currentgood,
    //         proofState.valuegood
    //     ).toId();
    //     uint256 proofKey2 = S_ProofKey(
    //         to,
    //         proofState.currentgood,
    //         proofState.valuegood
    //     ).toId();
    //     L_Proof.stake(officialContract, to, proofState.state.amount0());
    //     uint256 existingProofId = proofmapping[proofKey2];
    //     if (existingProofId == 0) {
    //         proofmapping[proofKey2] = proofmapping[proofKey1];
    //     } else {
    //         proofs[existingProofId].conbine(proofs[proofid]);
    //         delete proofs[proofid];
    //         _burn(proofid);
    //     }
    //     delete proofmapping[proofKey1];
    // }

    // /**
    //  * @dev Safely transfers the ownership of a given token ID to another address with a permit.
    //  * @param from The current owner of the token.
    //  * @param to The new owner.
    //  * @param tokenId The ID of the token to be transferred.
    //  * @param _data Additional data with no specified format.
    //  * @param deadline The time at which the signature expires.
    //  * @param signature A valid EIP712 signature.
    //  */
    // function safeTransferFromWithPermit(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory _data,
    //     uint256 deadline,
    //     bytes memory signature
    // ) external override {
    //     _permit(msg.sender, tokenId, deadline, signature);
    //     safeTransferFrom(from, to, tokenId, _data);
    // }

    function mint(address recipent, uint256 tokenid) external override {
        _mint(recipent, tokenid);
    }

    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external override returns (bool) {
        return _isApprovedOrOwner(spender, tokenId);
    }
}
