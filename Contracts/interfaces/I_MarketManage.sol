// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./I_Proof.sol";
import "./I_Good.sol";

import {S_GoodKey, S_ProofKey, S_Ralate} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "../libraries/L_BalanceUINT256.sol";

/// @title 市场管理接口 market manage interface
/// @notice 市场管理接口 market manage interface
interface I_MarketManage is I_Good, I_Proof {
    /// @notice emit when customer buy good :当用户购买商品时触发
    /// @param sellgood good's id  商品的商品ID
    /// @param forgood   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param fromer   seller or buyer address 卖家或买家地址
    /// @param swapvalue   trade value  交易价值
    /// @param sellgoodstate   the sellgood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量
    /// @param forgoodstate   the forgood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量
    event e_buyGood(
        uint256 indexed sellgood,
        uint256 indexed forgood,
        address fromer,
        uint128 swapvalue,
        T_BalanceUINT256 sellgoodstate,
        T_BalanceUINT256 forgoodstate
    );
    /// @notice emit when customer buy good pay to the seller :当用户购买商品支付给卖家时触发
    /// @param buygood good's id  商品的商品ID
    /// @param usegood   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param fromer   seller or buyer address 卖家或买家地址
    /// @param receipt   receipt  收款方
    /// @param swapvalue   trade value  交易价值
    /// @param buygoodstate   the buygood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量
    /// @param usegoodstate   the usegood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量
    event e_buyGoodForPay(
        uint256 indexed buygood,
        uint256 indexed usegood,
        address fromer,
        address receipt,
        uint128 swapvalue,
        T_BalanceUINT256 buygoodstate,
        T_BalanceUINT256 usegoodstate
    );
    event e_proof(uint256 indexed);

    error err_total();
    /// @notice get good's state 获取商品状态
    /// @param _erc20address good's id  商品的商品ID
    /// @param _initial   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param _goodconfig   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @return metagood_no_ 元商品编号
    /// @return proof_no_ 投资证明编号
    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodconfig
    ) external payable returns (uint256 metagood_no_, uint256 proof_no_);

    /// @notice 获取商品状态 get good's state
    /// @param _valuegood   使用什么价值物品度量普通物品的价值  use which value good to measure the normal good
    /// @param _initial   普通物品的初始化参数
    /// @param _erc20address  普通物品对应的ERC20代币合约地址
    /// @param _goodConfig   普通物品的配置信息
    /// @param _gater   门户地址
    /// @return goodNo_ 初始化普通物品后的证明 the proof of initial good
    /// @return proofNo_ 初始化普通物品后的证明 the proof of initial good
    function initNormalGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        address _gater
    ) external payable returns (uint256 goodNo_, uint256 proofNo_);

    /// @notice 出售商品1购买商品2
    /// @dev 如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1
    /// @param _goodid1   商品1的ID
    /// @param _goodid2   商品2的ID
    /// @param _swapQuanitity  出售商品1的数量
    /// @param _limitprice   在不高于某价值出售
    /// @param _istotal 是否允许完全成交
    /// @param _gater   用户地址
    /// @return goodid2Quanitity_ 实际情况
    /// @return goodid2FeeQuanitity_ 实际情况
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitprice,
        bool _istotal,
        address _gater
    )
        external
        payable
        returns (uint128 goodid2Quanitity_, uint128 goodid2FeeQuanitity_);

    /// @notice 出售商品1购买商品2
    /// @dev 如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1
    /// @param _goodid1   商品1的ID
    /// @param _goodid2   商品2的ID
    /// @param _swapQuanitity  出售商品1的数量
    /// @param _limitprice   在不高于某价值出售
    /// @param _recipent   收款方
    /// @param _gater   门户地址
    /// @return goodid2_quanitity_ 商品2获得的数量(不包含手续费)
    /// @return goodid2_fee_quanitity_ 商品2的手续费
    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitprice,
        address _recipent,
        address _gater
    )
        external
        payable
        returns (uint128 goodid2_quanitity_, uint128 goodid2_fee_quanitity_);

    /// @notice 投资价值商品
    /// @param _goodid   价值商品的ID
    /// @param _goodQuanitity   投资价值商品的数量
    /// @param _gater   门户地址
    /// @return valueInvest_
    /// struct S_GoodinvestReturn {
    /// uint128 actualFeeQuantity; //实际手续费
    /// uint128 contructFeeQuantity; //构建手续费
    /// uint128 actualinvestValue; //实际投资价值
    /// uint128 actualinvestQuantity; //实际投资数量
    /// }

    function investValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        returns (L_Good.S_GoodInvestReturn calldata valueInvest_);

    /// @notice 撤资价值商品
    /// @param _goodid   价值商品的ID
    /// @param _goodQuanitity   取消价值商品的数量
    /// @param _gater   门户
    /// @return disinvestResult_   amount0 为投资收益 amount1为实际产生手续费
    function disinvestValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        returns (L_Good.S_GoodDisinvestReturn memory disinvestResult_);

    /// @notice 投资普通商品
    /// @param _togood   普通商品的ID
    /// @param _valuegood   价值商品的ID
    /// @param _quanitity   投资普通商品的数量
    /// @param _gater   门户
    /// @return normalinvest 普通商品
    /// struct S_GoodinvestReturn {
    /// uint128 actualFeeQuantity; //实际手续费
    /// uint128 contructFeeQuantity; //构建手续费
    /// uint128 actualinvestValue; //实际投资价值
    /// uint128 actualinvestQuantity; //实际投资数量
    /// }
    /// @return valueinvest 价值商品
    /// struct S_GoodinvestReturn {
    /// uint128 actualFeeQuantity; //实际手续费
    /// uint128 contructFeeQuantity; //构建手续费
    /// uint128 actualinvestValue; //实际投资价值
    /// uint128 actualinvestQuantity; //实际投资数量
    /// }
    function investNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quanitity,
        address _gater
    )
        external
        payable
        returns (
            L_Good.S_GoodInvestReturn calldata normalinvest,
            L_Good.S_GoodInvestReturn calldata valueinvest
        );

    /// @notice 撤资普通商品
    /// @param _togood   普通商品id
    /// @param _valuegood   投资ID
    /// @param _goodQuanitity   取消普通商品投资数量
    /// @param _gater   门户
    /// @return disinvestResult1_   普通商品:amount0 为投资收益 amount1为实际产生手续费
    /// @return disinvestResult2_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestResult2_
        );

    /// @notice 撤资价值商品证明
    /// @param _valueproofid   投资ID
    /// @param _goodQuanitity   取消价值商品数量
    /// @param _gater   门户
    /// @return disinvestResult_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestValueProof(
        uint256 _valueproofid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        returns (L_Good.S_GoodDisinvestReturn memory disinvestResult_);

    /// @notice 撤资普通商品证明
    /// @param _normalProof   投资ID
    /// @param _goodQuanitity   取消普通商品数量
    /// @param _gater   门户
    /// @return disinvestResult1_   普通商品:amount0 为投资收益 amount1为实际产生手续费
    /// @return disinvestResult2_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestNormalProof(
        uint256 _normalProof,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestResult2_
        );
}
