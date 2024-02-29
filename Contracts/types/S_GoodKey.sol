// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {T_Currency} from "./T_Currency.sol";
import {T_BalanceUINT256} from "./T_BalanceUINT256.sol";

struct S_GoodKey {
    T_Currency erc20address;
    address owner;
}

struct S_GoodInvestReturn {
    uint128 actualFeeQuantity; //实际手续费
    uint128 contructFeeQuantity; //构建手续费
    uint128 actualInvestValue; //实际投资价值
    uint128 actualInvestQuantity; //实际投资数量
}

struct S_GoodState {
    uint256 goodConfig; //商品配置refer to goodConfig
    address owner; //商品创建者 good's creator
    T_Currency erc20address; //商品的erc20合约地址good's erc20address
    T_BalanceUINT256 currentState; //前128位表示商品的价值,后128位表示商品数量 amount0:the good's total value ,amount1:the good's quantity
    T_BalanceUINT256 investState; //前128位表示商品的投资总价值,后128位表示商品投资总数量 amount0:the good's total invest value,amount1:the good's total invest quantity
    T_BalanceUINT256 feeQunitityState; //前128位表示商品的手续费总额(包含构建手续费),后128位表示商品的构建手续费总额 amount0:the good's total fee quantity which contain contruct fee,amount1:the good's total contruct fee.
}
