// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {T_BalanceUINT256} from "./L_BalanceUINT256.sol";

struct S_GoodKey {
    address erc20address;
    address owner;
}

struct S_GoodInvestReturn {
    uint128 actualFeeQuantity; //实际手续费
    uint128 contructFeeQuantity; //构建手续费
    uint128 actualInvestValue; //实际投资价值
    uint128 actualInvestQuantity; //实际投资数量
}

struct S_GoodTmpState {
    uint256 goodConfig; //商品配置refer to goodConfig
    address owner; //商品创建者 good's creator
    address erc20address; //商品的erc20合约地址good's erc20address
    T_BalanceUINT256 currentState; //前128位表示商品的价值,后128位表示商品数量 amount0:the good's total value ,amount1:the good's quantity
    T_BalanceUINT256 investState; //前128位表示商品的投资总价值,后128位表示商品投资总数量 amount0:the good's total invest value,amount1:the good's total invest quantity
    T_BalanceUINT256 feeQunitityState; //前128位表示商品的手续费总额(包含构建手续费),后128位表示商品的构建手续费总额 amount0:the good's total fee quantity which contain contruct fee,amount1:the good's total contruct fee.
}

struct S_GoodState {
    uint256 goodConfig; //商品配置refer to goodConfig
    address owner; //商品创建者 good's creator
    address erc20address; //商品的erc20合约地址good's erc20address
    T_BalanceUINT256 currentState; //前128位表示商品的价值,后128位表示商品数量 amount0:the good's total value ,amount1:the good's quantity
    T_BalanceUINT256 investState; //前128位表示商品的投资总价值,后128位表示商品投资总数量 amount0:the good's total invest value,amount1:the good's total invest quantity
    T_BalanceUINT256 feeQunitityState; //前128位表示商品的手续费总额(包含构建手续费),后128位表示商品的构建手续费总额 amount0:the good's total fee quantity which contain contruct fee,amount1:the good's total contruct fee.
    mapping(address => uint256) fees;
}

struct S_ProofKey {
    address owner;
    uint256 currentgood;
    uint256 valuegood;
}

struct S_ProofState {
    address owner;
    uint256 currentgood;
    uint256 valuegood;
    T_BalanceUINT256 state; //amount0:value amount1:null
    T_BalanceUINT256 invest; //normalgood   contruct:investquanity
    T_BalanceUINT256 valueinvest; //valuegood contruct:investquanity
}

struct S_Ralate {
    address gater;
    address refer;
}
