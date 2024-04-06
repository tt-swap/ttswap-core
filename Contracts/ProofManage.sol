// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./interfaces/I_Proof.sol";
import {S_ProofKey, S_ProofState} from "./libraries/L_Struct.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {Strings} from "./libraries/Strings.sol";
import {Address} from "./libraries/Address.sol";

abstract contract ProofManage is I_Proof {
    using L_Proof for *;
    using Strings for uint256;
    using Address for address;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 proofnum;
    mapping(uint256 => S_ProofState) public proofs;
    mapping(address => uint256[]) public _ownerproofs;
    mapping(bytes32 => uint256) public proofseq;

    constructor() {}

    function getProofId(
        S_ProofKey calldata investproofkey
    ) external view returns (uint256 _proof) {
        _proof = proofseq[investproofkey.toId()];
    }

    function getProofState(
        uint256 _proof
    ) external view override returns (S_ProofState memory proof_) {
        proof_.owner = proofs[_proof].owner;
        proof_.currentgood = proofs[_proof].currentgood;
        proof_.valuegood = proofs[_proof].valuegood;
        proof_.state = proofs[_proof].state;
        proof_.invest = proofs[_proof].invest;
        proof_.valueinvest = proofs[_proof].valueinvest;
    }

    function changeProofOwner(
        uint256 _proofid,
        address to
    ) external override returns (bool) {
        require(msg.sender == proofs[_proofid].owner, "");
        proofs[_proofid].owner = to;
        return true;
    }
}
