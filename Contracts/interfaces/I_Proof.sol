// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";

/// @title 投资证明接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Proof {
    /// @notice Returns the total number of market's proof 返回市场证明总数
    /// @return proofnum_ The address of the factory manager
    function totalSupply() external view returns (uint256 proofnum_);

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;
}
