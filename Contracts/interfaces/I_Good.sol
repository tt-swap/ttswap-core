// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {S_GoodKey, S_Ralate} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";


/// @title 商品接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_Good {
    /// @notice emitted when good's user tranfer the good to another 商品拥有者转移关系给另一人
    /// @param _goodid good number,商品编号
    /// @param _owner the older owner,原拥有者
    /// @param _to the new owner,新拥有者
    event e_changeOwner(uint256 indexed _goodid, address _owner, address _to);

    /// @notice Returns the config of the market 返回市场的配置
    /// @dev Can be changed by the marketmanager
    /// @return marketconfig_ The address of the factory owner
    function marketconfig() external view returns (uint256 marketconfig_);

    /// @notice Returns the manger of market 返回市场管理者 返回市场商品总数
    /// @return marketcreator_ The address of the factory manager
    function marketcreator() external view returns (address marketcreator_);

    /// @notice Returns the good's total number of the market 返回市场商品总数
    /// @return goodnum_ The address of the factory owner
    function goodnum() external view returns (uint256 goodnum_);

    /// @notice Returns the address's status 查询地址是否被禁止提手续费
    /// @param _user 用户地址
    /// @return _isban The address of the factory owner
    function check_banlist(address _user) external view returns (bool _isban);

    /// @notice config market config 设置市场中市场配置
    /// @param _marketconfig   seller address 卖家地址
    function setMarketConfig(uint256 _marketconfig) external returns (bool);

    /// @notice get seller's good 获取卖家的商品列表
    /// @param _owner   seller address 卖家地址
    /// @param _seq   seller address 第几个商品
    /// @return  goods list 商品编号列表
    function getGoodIdByAddress(
        address _owner,
        uint256 _seq
    ) external view returns (uint256);

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
        address payable _recipent
    ) external payable returns (bool);

    /// @notice set good's Owner 改变商品的拥有者
    /// @param _goodid  good's id 商品的商品ID
    /// @param _to  recipent 接收者
    /// @return the result
    function changeGoodOwner(
        uint256 _goodid,
        address _to
    ) external returns (bool);
    /// @notice collect protocalFee 收益协议手续费
    /// @param _goodid  good's id 商品的商品ID
    /// @return the result 手续费数量
    function collectProtocolFee(
        uint256 _goodid
    ) external payable returns (uint256);
    /// @notice add ban list  增加禁止名单
    /// @param _user  address 地址
    /// @return is_success_ 是否成功
    function addbanlist(address _user) external returns (bool is_success_);
    /// @notice  rm ban list  移除禁止名单
    /// @param _user  address 地址
    /// @return is_success_ 是否成功
    function removebanlist(address _user) external returns (bool is_success_);

    /// @notice 获取商品的用户协议手续费
    /// @param _goodid   商品编号
    /// @param _user   用户地址
    /// @return fee_ 是否成功
    function getGoodsFee(
        uint256 _goodid,
        address _user
    ) external view returns (uint256 fee_);
}
