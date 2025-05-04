// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_StakeETH {
    event e_stakeRocketPoolETH(uint256 totalStake);
    event e_Received(uint256);
    event e_rocketpoolUnstaked(
        uint256 totalStake,
        uint256 totalState,
        uint128 reward
    );
    event e_stakeeth_invest(uint256 rethStaking);
    event e_stakeeth_devest(uint256 rethStaking);
    event e_collecttts(uint256 amount);
    event e_stakeSETH(
        uint256 TotalStake,
        uint256 TotalState,
        uint256 sethShare,
        uint256 rethStaking,
        uint128 stakeamount
    );
    event e_stakeSWETH(
        uint256 TotalStake,
        uint256 TotalState,
        uint256 swethShare,
        uint256 rethStaking,
        uint128 stakeamount
    );
    event e_unstakeSETH(
        uint256 TotalStake,
        uint256 TotalState,
        uint256 sethShare,
        uint256 rethStaking,
        uint128 reward
    );
    event e_unstakeSWETH(
        uint256 TotalStake,
        uint256 TotalState,
        uint256 swethShare,
        uint256 rethStaking,
        uint128 reward
    );

    function totalState() external returns (uint256); //amount0:totalShare, amount1:totalETHQuantity
    function sethState() external returns (uint256); // amount0:share amount1:quantity
    function swethState() external returns (uint256); // amount0:share amount1:quantity
    function totalStake() external returns (uint256); // amount0:stakingAmount amount1:currentBalance
    function rethStaking() external returns (uint256);

    function stakeEth(address token, uint128 _stakeamount) external payable;
    function unstakeEthSome(
        address token,
        uint128 amount
    ) external returns (uint128 reward);

    function syncReward(address token) external returns (uint128 reward);
    function stakeRocketPoolETH(
        uint128 stakeamount
    ) external returns (uint256 rethAmount);
    function unstakeRocketPoolETH(uint256 rethAmount) external;
    function invest(uint128 _goodQuantity) external;
    function divest(uint128 _goodQuantity) external;
    function collectTTSReward() external;
}
