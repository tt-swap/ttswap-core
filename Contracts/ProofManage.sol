// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_Proof} from "./interfaces/I_Proof.sol";
import {I_TTS} from "./interfaces/I_TTS.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {ERC721Permit} from "@erc721permit/ERC721Permit.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";

abstract contract ProofManage is I_Proof, ERC721Permit {
    using L_Proof for *;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 public override totalSupply;
    mapping(uint256 => L_Proof.S_ProofState) internal proofs;
    mapping(uint256 => uint256) public proofmapping;

    // solhint-disable-next-line var-name-mixedcase

    address internal immutable officicalContract;
    constructor(address _officialcontract) ERC721Permit("TTS NFT", "TTS") {
        officicalContract = _officialcontract;
    }
    modifier onlyMarketor() {
        require(I_TTS(officicalContract).isauths(msg.sender) == 2);
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "http://www.tt-swap.com/nft?proofid=";
    }

    function getProofState(
        uint256 proofid
    ) external view returns (L_Proof.S_ProofState memory) {
        return proofs[proofid];
    }

<<<<<<< Updated upstream
    function getProofValue(
        uint256 proofid
    ) public view override returns (uint256) {
        return
            proofs[proofid].valuegood == 0
                ? proofs[proofid].state.amount0()
                : proofs[proofid].state.amount0() * 2;
    }

=======
    /**
     * @dev See {IERC721-transferFrom}.
     */
>>>>>>> Stashed changes
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );

        proofs[tokenId].unstake(officicalContract, from);
        _transfer(from, to, tokenId);
        delproofdata(tokenId, from, to);
    }
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
        proofs[tokenId].unstake(officicalContract, from);
        _safeTransfer(from, to, tokenId, data);
        delproofdata(tokenId, from, to);
    }

    function delproofdata(uint256 proofid, address from, address to) private {
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
        proofs[proofmapping[proofkey2]].stake(officicalContract, to);
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
