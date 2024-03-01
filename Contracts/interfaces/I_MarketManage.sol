// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./I_Proof.sol";
import "./I_Good.sol";

import {L_Ralate} from "../libraries/L_Ralate.sol";

import {S_ProofKey} from "../types/S_ProofKey.sol";
import {S_GoodKey, S_GoodInvestReturn} from "../types/S_GoodKey.sol";

import {T_ProofId} from "../types/T_ProofId.sol";
import {T_GoodId} from "../types/T_GoodId.sol";
import {T_Currency} from "../types/T_Currency.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "../types/T_BalanceUINT256.sol";

/// @title 市场管理接口 market manage interface
/// @notice 市场管理接口 market manage interface
interface I_MarketManage is I_Good, I_Proof {
    event e_initNormalGood();
    event e_updateNormalGood(bytes32);
    event e_updateValueGood(bytes32);

    event e_initNormalGood(T_GoodId indexed);
    event e_buyGood(
        T_GoodId indexed,
        T_GoodId indexed,
        address,
        uint128,
        T_BalanceUINT256,
        T_BalanceUINT256
    );
    event e_investGood(
        T_ProofId indexed
    );
    event e_disinvestGood(
        T_ProofId indexed
    );
   
    

    /// @notice 获取商品状态 get good's state
    /// @param _goodkey1   商品的商品ID good's id
    /// @param _initial   初始化的商品的参数,前128位为价值,后128位为数量.initial good,amount0:value,amount1:quantity
    /// @param _goodconfig   初始化的商品的参数,前128位为价值,后128位为数量.initial good,amount0:value,amount1:quantity
    /// @return 是否初始化成功
    function initMetaGood(
        S_GoodKey calldata _goodkey1,
        T_BalanceUINT256 _initial,
        uint256 _goodconfig
    ) external returns (bool);

    /// @notice 获取商品状态 get good's state
    /// @param _valuegood   使用什么价值物品度量普通物品的价值  use which value good to measure the normal good
    /// @param _initial   普通物品的初始化参数
    /// @param _erc20address  普通物品对应的ERC20代币合约地址
    /// @param _goodConfig   普通物品的配置信息
    /// @return T_ProofId 初始化普通物品后的证明 the proof of initial good
    function initNormalGood(
        T_GoodId _valuegood,
        T_BalanceUINT256 _initial,
        T_Currency _erc20address,
        uint256 _goodConfig
    ) external payable returns (T_ProofId);

    /// @notice 出售商品1购买商品2
    /// @dev 如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1
    /// @param _goodid1   商品1的ID
    /// @param _goodid2   商品2的ID
    /// @param _swapQuanitity  出售商品1的数量
    /// @param _limitprice   在不高于某价值出售
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return goodid2_quanitity_ 商品2获得的数量(不包含手续费)
    /// @return goodid1_fee_quanitity_ 商品1的手续费
    /// @return goodid2_fee_quanitity_ 商品2的手续费
    function buyGood(
        T_GoodId _goodid1,
        T_GoodId _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitprice,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        returns (
            uint128 goodid2_quanitity_,
            uint128 goodid1_fee_quanitity_,
            uint128 goodid2_fee_quanitity_
        );

    /// @notice 投资价值商品
    /// @param _goodid   价值商品的ID
    /// @param _goodQuanitity   投资价值商品的数量
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return normalinvest
    /// struct S_GoodinvestReturn {
    /// uint128 actualFeeQuantity; //实际手续费
    /// uint128 contructFeeQuantity; //构建手续费
    /// uint128 actualinvestValue; //实际投资价值
    /// uint128 actualinvestQuantity; //实际投资数量
    /// }

    function investValueGood(
        T_GoodId _goodid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    ) external payable returns (S_GoodInvestReturn calldata normalinvest);

    /// @notice 撤资价值商品
    /// @param _goodid   价值商品的ID
    /// @param _goodQuanitity   取消价值商品的数量
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return disinvestResult_   amount0 为投资收益 amount1为实际产生手续费
    function disinvestValueGood(
        T_GoodId _goodid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    ) external payable returns (T_BalanceUINT256 disinvestResult_);

    /// @notice 投资普通商品
    /// @param _togood   普通商品的ID
    /// @param _valuegood   价值商品的ID
    /// @param _quanitity   投资普通商品的数量
    /// @param _ralate   用户的关系,推荐人和门户地址
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
        T_GoodId _togood,
        T_GoodId _valuegood,
        uint128 _quanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        returns (
            S_GoodInvestReturn calldata normalinvest,
            S_GoodInvestReturn calldata valueinvest
        );

    /// @notice 撤资普通商品
    /// @param _togood   普通商品id
    /// @param _valuegood   投资ID
    /// @param _goodQuanitity   取消普通商品投资数量
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return disinvestResult1_   普通商品:amount0 为投资收益 amount1为实际产生手续费
    /// @return disinvestResult2_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestNormalGood(
        T_GoodId _togood,
        T_GoodId _valuegood,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        returns (
            T_BalanceUINT256 disinvestResult1_,
            T_BalanceUINT256 disinvestResult2_
        );

    /// @notice 撤资价值商品证明
    /// @param _valueproofid   投资ID
    /// @param _goodQuanitity   取消价值商品数量
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return disinvestResult_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestValueProof(
        T_ProofId _valueproofid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    ) external payable returns (T_BalanceUINT256 disinvestResult_);

    /// @notice 撤资普通商品证明
    /// @param _normalProof   投资ID
    /// @param _goodQuanitity   取消普通商品数量
    /// @param _ralate   用户的关系,推荐人和门户地址
    /// @return disinvestResult1_   普通商品:amount0 为投资收益 amount1为实际产生手续费
    /// @return disinvestResult2_   价值商品:amount0 为投资收益 amount1为实际产生手续费
    function disinvestNormalProof(
        T_ProofId _normalProof,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        returns (
            T_BalanceUINT256 disinvestResult1_,
            T_BalanceUINT256 disinvestResult2_
        );

    /// @notice 价值商品证明的收益
    /// @param _investproofid   价值商品的证明
    /// @return profit   收益
    function profitInvestValueProof(
        T_ProofId _investproofid
    ) external view returns (uint128 profit);

    /// @notice 普通商品证明的收益
    /// @param _investproofid   普通商品的证明
    /// @return result   amount0为普通商品的收益,amount1为价值商品的收益
    function profitInvestNormalProof(
        T_ProofId _investproofid
    ) external view returns (T_BalanceUINT256 result);
}
