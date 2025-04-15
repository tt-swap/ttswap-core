// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_StakeETH {
    event e_stakeRocketPoolETH(uint128, uint256);
    event e_Received(uint256);
    event e_rocketpoolUnstaked(uint256, uint256);
    event e_stakeeth_invest(uint128 _goodQuantity);
    event e_stakeeth_devest(uint128 _goodQuantity);
    event e_collecttts(uint256 amount);

    function TotalState() external returns (uint256); //amount0:totalShare, amount1:totalETHQuantity
    function ethShare() external returns (uint256); // amount0:share amount1:quantity
    function wethShare() external returns (uint256); // amount0:share amount1:quantity
    function TotalStake() external returns (uint256); // amount0:stakingAmount amount1:currentBalance
    function reth_staking() external returns (uint256);

    function stakeEth(address token, uint128 _stakeamount) external payable;
    function unstakeEthSome(
        address token,
        uint128 amount
    ) external returns (uint128 reward);

    function syncReward(address token) external returns (uint128 reward);
    function stakeRocketPoolETH(uint128 stakeamount) external payable;
    function unstakeRocketPoolETH(uint256 rethAmount) external;
    function invest(uint128 _goodQuantity, bytes calldata data1) external;
    function divest(uint128 _goodQuantity) external;
    function collectTTS() external;
}
