// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {S_GoodKey, S_Ralate} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";

/// @title 商品接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Good {
    event e_updategoodconfig(uint256 indexed, uint256, uint256);
    event e_updateGood(uint256 indexed, uint256);
    event e_changeOwner(uint256 indexed, address, address);
    // event e_initMarket(address, uint256);
    event e_collectProtocolFee(uint256 indexed, address, uint256);

    /// @notice config market config 设置市场中市场配置
    /// @param _marketconfig   seller address 卖家地址
    function setMarketConfig(uint256 _marketconfig) external;

    /// @notice get seller's good 获取卖家的商品列表
    /// @param _owner   seller address 卖家地址
    /// @return  goods list 商品编号列表
    function getGoodIdByAddress(
        address _owner
    ) external view returns (uint256[] memory);

    /// @notice get good's state 获取商品状态
    /// @param _goodid  good's id  商品的商品ID
    /// @return good goodinfo 商品的状态信息
    function getGoodState(
        uint256 _goodid
    ) external view returns (L_Good.S_GoodTmpState memory good);

    /// @notice  update good's config 更新商品配置
    /// @param _goodid   good's id 商品的商品ID
    /// @param _goodConfig   商品配置
    /// @return the result  更新结果
    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice  update normal good to value good 更新普通商品为价值商品
    /// @param _goodid   good's id 商品的商品ID
    /// @return the result  更新结果
    function updatetoValueGood(uint256 _goodid) external returns (bool);

    /// @notice  update normal good to value good 更新价值商品为普通商品
    /// @param _goodid   good's id 商品的商品ID
    /// @return the result  更新结果
    function updatetoNormalGood(uint256 _goodid) external returns (bool);
    /// @notice pay good to  转给
    /// @param _goodid   商品的商品ID
    /// @param _payquanity   数量
    /// @param _recipent   接收者
    /// @return the result
    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external returns (bool);

    /// @notice set good's Owner 改变商品的拥有者
    /// @param _goodid  good's id 商品的商品ID
    /// @param _to  recipent 接收者
    /// @return the result
    function changeOwner(uint256 _goodid, address _to) external returns (bool);
    /// @notice collect protocalFee 收益协议手续费
    /// @param _goodid  good's id 商品的商品ID
    /// @return the result 手续费数量
    function collectProtocolFee(
        uint256 _goodid
    ) external payable returns (uint256);
    /// @notice add ban list  增加禁止名单
    /// @param _user  address 地址
    function addbanlist(address _user) external;
    /// @notice  rm ban list  移除禁止名单
    /// @param _user  address 地址
    function removebanlist(address _user) external;
}
