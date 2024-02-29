// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {T_GoodId} from "../types/T_GoodId.sol";
import {T_ProofId} from "../types/T_ProofId.sol";
import {S_ProofKey, S_ProofState} from "../types/S_ProofKey.sol";

import "./ERC721/IERC721.sol";
import "./ERC721/IERC721Metadata.sol";
import "./ERC721/IERC721Receiver.sol";
import {T_BalanceUINT256} from "../types/T_BalanceUINT256.sol";

/// @title 投资证明接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Proof is IERC165, IERC721, IERC721Metadata {
    /// @notice 获取投资证明ID get the invest proof'id
    /// @param _investproofkey   生成投资证明的参数据
    /// @return proof_ 投资证明的ID
    function getProofId(
        S_ProofKey calldata _investproofkey
    ) external pure returns (T_ProofId proof_);

    /// @notice 改变投资证明的拥有者
    /// @param _proofid   生成投资证明的参数据
    /// @param _to   生成投资证明的参数据
    /// @return proof_ 投资证明的ID
    function changeProofOwner(
        T_ProofId _proofid,
        address _to
    ) external returns (bool);

    /// @notice 改变投资证明的拥有者
    function changeProofOwnerWithPermit() external;

    function getProofState(
        T_ProofId _proof
    ) external view returns (S_ProofState memory proof_);
}
