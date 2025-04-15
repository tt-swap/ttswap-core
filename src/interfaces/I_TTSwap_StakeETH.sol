// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_StakeETH {
    function stakeEth(address token, uint128 _stakeamount) external payable;
    function unstakeEthSome(
        address token,
        uint128 amount
    ) external returns (uint128 reward);

    function unstakeETHAll(
        address token
    ) external returns (uint128 reward, uint128 amount);

    function syncReward(address token) external returns (uint128 reward);
}
