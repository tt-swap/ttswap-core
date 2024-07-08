// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./interfaces/I_Proof.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {ERC721Permit} from "@erc721permit/ERC721Permit.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract ProofManage is I_Proof, ERC721Permit {
    using L_Proof for *;
    using Strings for uint256;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 public override totalSupply;
    mapping(uint256 => L_Proof.S_ProofState) internal proofs;
    mapping(uint256 => uint256) public proofmapping;

    // solhint-disable-next-line var-name-mixedcase

    constructor() ERC721Permit("TTS NFT", "TTS") {}

    function _baseURI() internal pure override returns (string memory) {
        return "http://www.tt-swap.com/nft?proofid=";
    }

    function getProofState(
        uint256 proofid
    ) external view returns (L_Proof.S_ProofState memory _proof) {
        return proofs[proofid];
    }

    function transferFrom(
        address from,
        address to,
        uint256 proofid
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), proofid),
            "ERC721: caller is not token owner or approved"
        );
        _transfer(from, to, proofid);
        proofs[proofid].beneficiary = address(0);
        uint256 proofkey1 = S_ProofKey(
            from,
            proofs[proofid].currentgood,
            proofs[proofid].valuegood
        ).toId();
        uint256 proofkey2 = S_ProofKey(
            to,
            proofs[proofid].currentgood,
            proofs[proofid].valuegood
        ).toId();
        if (proofmapping[proofkey2] == 0) {
            proofmapping[proofkey2] = proofmapping[proofkey1];
        } else {
            proofs[proofmapping[proofkey2]].conbine(proofs[proofid]);
            delete proofs[proofid];
            _burn(proofid);
        }
        delete proofmapping[proofkey1];
        emit Transfer(from, to, proofid);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 proofid,
        bytes memory data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), proofid),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, proofid, data);
        proofs[proofid].beneficiary = address(0);
        uint256 proofkey1 = S_ProofKey(
            from,
            proofs[proofid].currentgood,
            proofs[proofid].valuegood
        ).toId();
        uint256 proofkey2 = S_ProofKey(
            to,
            proofs[proofid].currentgood,
            proofs[proofid].valuegood
        ).toId();
        if (proofmapping[proofkey2] == 0) {
            proofmapping[proofkey2] = proofmapping[proofkey1];
        } else {
            proofs[proofmapping[proofkey2]].conbine(proofs[proofid]);
            delete proofs[proofid];
            _burn(proofid);
        }
        delete proofmapping[proofkey1];
        emit Transfer(from, to, proofid);
    }

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external override {
        _permit(msg.sender, tokenId, deadline, signature);
        safeTransferFrom(from, to, tokenId, _data);
    }
}
