// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";

/// @title 投资证明接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Proof is IERC721, IERC721Metadata, IERC721Permit {
    /// @notice Returns the total number of market's proof 返回市场证明总数
    /// @return proofnum_ The address of the factory manager
    function totalSupply() external view returns (uint256 proofnum_);

    /// @notice get the invest proof'id ~ 获取投资证明ID
    /// @param _investproofkey   生成投资证明的参数据
    /// @return proof_ 投资证明的ID
    function getProofId(
        S_ProofKey calldata _investproofkey
    ) external view returns (uint256 proof_);

    /// @notice get the invest proof'id 获取投资证明ID详情
    /// @param _proof   证明编号
    /// @return proof_  证明信息
    function getProofState(
        uint256 _proof
    ) external view returns (L_Proof.S_ProofState memory proof_);

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;
}
