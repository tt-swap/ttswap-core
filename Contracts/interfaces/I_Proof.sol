// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {S_ProofKey, S_ProofState} from "../libraries/L_Struct.sol";

import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";

/// @title 投资证明接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Proof {
    /// @notice 获取投资证明ID get the invest proof'id
    /// @param _investproofkey   生成投资证明的参数据
    /// @return proof_ 投资证明的ID
    function getProofId(
        S_ProofKey calldata _investproofkey
    ) external view returns (uint256 proof_);

    /// @notice 改变投资证明的拥有者
    /// @param _proofid   生成投资证明的参数据
    /// @param _to   生成投资证明的参数据
    /// @return proof_ 投资证明的ID
    function changeProofOwner(
        uint256 _proofid,
        address _to
    ) external returns (bool);

    function getProofState(
        uint256 _proof
    ) external view returns (S_ProofState memory proof_);
}
