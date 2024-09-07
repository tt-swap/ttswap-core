// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_GoodKey} from "../libraries/L_Struct.sol";
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

    /// @notice Config Market Config~ 进行市场配置
    /// @param _marketconfig 市场配置
    event e_setMarketConfig(uint256 _marketconfig);

    /// @notice Config good 商品配置
    /// @param _goodid Good No,商品编号
    /// @param _goodConfig Good config 市场配置
    event e_updateGoodConfig(uint256 _goodid, uint256 _goodConfig);

    /// @notice 市场管理员更新商品的分类
    /// @param _goodid good No,商品编号配
    event e_modifyGoodConfig(uint256 _goodid, uint256 _goodconfig);

    /// @notice 修改商品拥有者
    /// @param goodid goodid
    /// @param to  address
    event e_changegoodowner(uint256 goodid, address to);

    /// @notice 提取市场佣金
    /// @param _gooid good No,商品编号配
    /// @param _commisionamount amount commision amount,
    event e_collectcommission(uint256[] _gooid, uint256[] _commisionamount);

    /// @notice add ban list~添加黑名单
    /// @param _user  address ~用户地址
    event e_addbanlist(address _user);
    /// @notice remove  out address from banlist~ 移出黑名单
    /// @param _user user address ~用户地址
    event e_removebanlist(address _user);
    /// @notice preject or seller deliver welfare to investor
    /// @param goodid 商品编号
    /// @param welfare 福利数量
    event e_goodWelfare(uint256 goodid, uint128 welfare);
    /// @notice collect fee
    /// @param goodid 商品编号
    /// @param feeamount 福利数量
    event e_collectProtocolFee(uint256 goodid, uint256 feeamount);

    event e_addreferal(address referals);

    /// @notice Returns the config of the market~返回市场的配置
    /// @dev Can be changed by the marketmanager~可以被管理员调整
    /// @return marketconfig_ the config of market(according the white paper)~市场配置(参见白皮书)
    function marketconfig() external view returns (uint256 marketconfig_);

    /// @notice Returns the good's total number of the market 返回市场商品总数
    /// @return goodNum_ the good number of the market~市场商品总数
    function goodNum() external view returns (uint256 goodNum_);

    /// @notice config market config 设置市场中市场配置
    /// @param _marketconfig   the market config ~市场配置
    /// @return 是否成功
    function setMarketConfig(uint256 _marketconfig) external returns (bool);

    /// @notice  update good's config 更新商品配置
    /// @param _goodid   good's id 商品的商品ID
    /// @param _goodConfig   商品配置
    /// @return the result  更新结果
    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice 市场管理员修改商品的属性
    /// @param _goodid   商品的商品ID
    /// @param _goodConfig   商品配置
    /// @return the result
    function modifyGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);
    /// @notice pay good to  转给
    /// @param _goodid   商品的商品ID
    /// @param _payquanity   数量
    /// @param _recipent   接收者
    /// @return the result
    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable returns (bool);

    /// @notice set good's Owner 改变商品的拥有者
    /// @param _goodid  good's id 商品的商品ID
    /// @param _to  recipent 接收者
    function changeGoodOwner(uint256 _goodid, address _to) external;
    /// @notice collect Commission 归集佣金
    /// @param _goodid  good's id 商品的商品ID
    function collectCommission(uint256[] memory _goodid) external;

    /// @notice query commission 查询佣金
    /// @param _goodid  good's id 商品的商品ID
    /// @param _recipent   customer 用户
    /// @return the result 手续费数量
    function queryCommission(
        uint256[] memory _goodid,
        address _recipent
    ) external returns (uint256[] memory);
    /// @notice add ban list  增加禁止名单
    /// @param _user  address 地址
    /// @return is_success_ 是否成功
    function addbanlist(address _user) external returns (bool is_success_);
    /// @notice  rm ban list  移除禁止名单
    /// @param _user  address 地址
    /// @return is_success_ 是否成功
    function removebanlist(address _user) external returns (bool is_success_);

    /// @notice 为投资者发福利
    /// @param goodid   商品编号
    /// @param welfare   用户地址
    function goodWelfare(uint256 goodid, uint128 welfare) external payable;
}
