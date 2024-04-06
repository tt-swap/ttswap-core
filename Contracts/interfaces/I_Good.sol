// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {S_GoodKey, S_GoodTmpState, S_Ralate} from "../libraries/L_Struct.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";

/// @title 商品接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Good {
    event e_updategoodconfig(uint256 indexed, uint256, uint256);
    event e_updateGood(uint256 indexed, uint8);
    event e_changeOwner(uint256 indexed, address, address);
    event e_changeOwnerByMarketor(uint256 indexed, address, address, address);
    event e_collectProtocolFee(uint256 indexed, address, uint256);
    event e_initMarket(address, uint256);
    function setMarketConfig(uint256 _marketconfig) external returns (bool);

    function marketconfig() external view returns (uint256);
    function getGoodIdByAddress(
        address _owner
    ) external view returns (uint256[] memory);

    /// @notice 获取商品状态 get good's state
    /// @param _goodid   商品的商品ID good's id
    /// @return good 商品的状态信息
    function getGoodState(
        uint256 _goodid
    ) external view returns (S_GoodTmpState memory good);

    /// @notice 更新商品配置 update good's config
    /// @param _goodid   商品的商品ID good's id
    /// @param _goodConfig   商品配置
    /// @return the result  更新结果
    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    function updatetoValueGood(uint256 goodid) external returns (bool);

    function updatetoNormalGood(uint256 goodid) external returns (bool);

    /// @notice 改变商品的拥有者 set good's Owner
    /// @param goodid   商品的商品ID good's id
    /// @param to   接收者
    /// @return the result
    function changeOwner(uint256 goodid, address to) external returns (bool);

    function collectProtocolFee(
        uint256 goodid
    ) external payable returns (uint256);
}
