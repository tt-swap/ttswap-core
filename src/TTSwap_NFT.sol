// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_TTSwap_NFT} from "./interfaces/I_TTSwap_NFT.sol";
import {I_TTSwap_Token} from "./interfaces/I_TTSwap_Token.sol";
import {I_TTSwap_Market} from "./interfaces/I_TTSwap_Market.sol";
import {ERC721Permit} from "@erc721permit/ERC721Permit.sol";
import {L_TTSwapUINT256Library} from "./libraries/L_TTSwapUINT256.sol";

/**
 * @title ProofManage
 * @dev Abstract contract for managing proofs as ERC721 tokens with additional functionality.
 * Inherits from I_Proof and ERC721Permit.
 */
contract TTSwap_NFT is I_TTSwap_NFT, ERC721Permit {
    using L_TTSwapUINT256Library for uint256;

    mapping(uint256 => address) internal proofsource;

    address internal immutable officialTokenContract;

    /**
     * @dev Constructor to initialize the ProofManage contract.
     */
    constructor(
        address _officialTokenContract
    ) ERC721Permit("TTSwap NFT", "TTS") {
        officialTokenContract = _officialTokenContract;
    }

    /**
     * @dev Returns the base URI for computing {tokenURI}.
     * @return string The base URI string.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "http://www.ttswap.io/nft?proofid=";
    }

    /**
     * @dev Transfers ownership of a token from one address to another address.
     * @param from The current owner of the token.
     * @param to The new owner.
     * @param tokenId The ID of the token being transferred.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _transfer(from, to, tokenId);
        I_TTSwap_Market(proofsource[tokenId]).delproofdata(tokenId, from, to);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address.
     * @param from The current owner of the token.
     * @param to The new owner.
     * @param tokenId The ID of the token to be transferred.
     * @param data Additional data with no specified format.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );

        _safeTransfer(from, to, tokenId, data);
        I_TTSwap_Market(proofsource[tokenId]).delproofdata(tokenId, from, to);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address with a permit.
     * @param from The current owner of the token.
     * @param to The new owner.
     * @param tokenId The ID of the token to be transferred.
     * @param _data Additional data with no specified format.
     * @param deadline The time at which the signature expires.
     * @param signature A valid EIP712 signature.
     */
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external {
        _permit(msg.sender, tokenId, deadline, signature);
        safeTransferFrom(from, to, tokenId, _data);
    }

    function mint(address recipent, uint256 tokenid) external override {
        require(I_TTSwap_Token(officialTokenContract).isauths(msg.sender) == 1);
        proofsource[tokenid] = msg.sender;
        _mint(recipent, tokenid);
    }

    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external view override returns (bool) {
        return _isApprovedOrOwner(spender, tokenId);
    }

    function burn(uint256 tokenId) external override {
        require(I_TTSwap_Token(officialTokenContract).isauths(msg.sender) == 1);
        _burn(tokenId);
    }
}
