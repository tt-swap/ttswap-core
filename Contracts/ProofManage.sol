// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./interfaces/I_Proof.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";

abstract contract ProofManage is I_Proof {
    using L_Proof for *;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 proofnum;
    mapping(uint256 => L_Proof.S_ProofState) public proofs;
    mapping(address => uint256[]) public _ownerproofs;
    mapping(bytes32 => uint256) public proofseq;
    mapping(uint256 => address) public proof_allownance;

    constructor() {}

    function getProofId(
        S_ProofKey calldata investproofkey
    ) external view returns (uint256 _proof) {
        _proof = proofseq[investproofkey.toId()];
    }

    function getProofState(
        uint256 _proof
    ) external view override returns (L_Proof.S_ProofState memory proof_) {
        proof_.owner = proofs[_proof].owner;
        proof_.currentgood = proofs[_proof].currentgood;
        proof_.valuegood = proofs[_proof].valuegood;
        proof_.state = proofs[_proof].state;
        proof_.invest = proofs[_proof].invest;
        proof_.valueinvest = proofs[_proof].valueinvest;
    }

    function changeProofOwner(
        uint256 _proofid,
        address _to
    ) external override returns (bool) {
        require(msg.sender == proofs[_proofid].owner, "P1");
        proofs[_proofid].owner = _to;
        return true;
    }
}
