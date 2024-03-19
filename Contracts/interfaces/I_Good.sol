// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {L_Ralate} from "../libraries/L_Ralate.sol";
import {T_GoodId} from "../types/T_GoodId.sol";
import {S_GoodKey, S_GoodState} from "../types/S_GoodKey.sol";
import {T_Currency} from "../types/T_Currency.sol";
import {T_BalanceUINT256} from "../types/T_BalanceUINT256.sol";

/// @title 商品接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Good {
    event e_updategoodconfig(T_GoodId indexed, uint256, uint256);
    event e_updateGood(T_GoodId indexed, uint8);
    event e_changeOwner(T_GoodId indexed, address, address);
    event e_changeOwnerByMarketor(T_GoodId indexed, address, address, address);
    event e_collectProtocolFee(T_GoodId indexed, address, uint256);
    event e_initMarket(address, uint256);
    function setMarketConfig(uint256 _marketconfig) external returns (bool);

    function marketconfig() external view returns (uint256);
    function getGoodIdByAddress(
        address _owner
    ) external view returns (T_GoodId[] memory);

    /// @notice 获取商品状态 get good's state
    /// @param _goodid   商品的商品ID good's id
    /// @return good 商品的状态信息
    function getGoodState(
        T_GoodId _goodid
    ) external view returns (S_GoodState memory good);

    /// @notice 更新商品配置 update good's config
    /// @param _goodid   商品的商品ID good's id
    /// @param _goodConfig   商品配置
    /// @return the result  更新结果
    function updateGoodConfig(
        T_GoodId _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    function updatetoValueGood(T_GoodId goodid) external returns (bool);

    function updatetoNormalGood(T_GoodId goodid) external returns (bool);

    /// @notice 改变商品的拥有者 set good's Owner
    /// @param goodid   商品的商品ID good's id
    /// @param to   接收者
    /// @return the result
    function changeOwner(T_GoodId goodid, address to) external returns (bool);

    function collectProtocolFee(
        T_GoodId goodid
    ) external payable returns (uint256);
}
