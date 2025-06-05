// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_StakeETH {
    /// @notice Emitted when Stake ETH to RocketPool
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    event e_stakeRocketPoolETH(uint256 totalStake);
    /// @notice Emitted when Receive Eth
    /// @param amount the Receive eth amount
    event e_Received(uint256 amount);

    /// @notice Emitted when unStake ETH from RocketPool
    /// @param totalState amount0:represent total share ,amount1:represent totalEth quantity
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    /// @param reward reward of the staking
    event e_rocketpoolUnstaked(uint256 totalStake, uint256 totalState, uint128 reward);
    /// @notice Emitted when invest reth to market
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    event e_stakeeth_invest(uint256 rethStaking);

    /// @notice Emitted when devest reth to market
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    event e_stakeeth_devest(uint256 rethStaking);

    /// @notice Emitted when use tts amount to buy reth
    /// @param amount amount0:represent spend amount of tts, amount1:represent get amount of reth
    event e_collecttts(uint256 amount);

    /// @notice Emitted when user stake eth
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    /// @param totalState amount0:represent total share ,amount1:represent totalEth quantity
    /// @param sethShare amount0:represent share amount ,amount1:represent eth quantitty
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    /// @param stakeamount  represent amount of stake
    event e_stakeSETH(
        uint256 totalStake, uint256 totalState, uint256 sethShare, uint256 rethStaking, uint128 stakeamount
    );

    /// @notice Emitted when user stake weth
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    /// @param totalState amount0:represent total share ,amount1:represent totalEth quantity
    /// @param swethShare amount0:represent share amount ,amount1:represent weth quantitty
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    /// @param stakeamount  represent amount of stake
    event e_stakeSWETH(
        uint256 totalStake, uint256 totalState, uint256 swethShare, uint256 rethStaking, uint128 stakeamount
    );
    /// @notice Emitted when user unstake eth
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    /// @param totalState amount0:represent total share ,amount1:represent totalEth quantity
    /// @param sethShare amount0:represent share amount ,amount1:represent eth quantitty
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    /// @param unstakeAmount amount0:represent amount of reward,amount1 :represent the unstake amount
    event e_unstakeSETH(
        uint256 totalStake, uint256 totalState, uint256 sethShare, uint256 rethStaking, uint256 unstakeAmount
    );

    /// @notice Emitted when user unstake weth
    /// @param totalStake amount0:represent staking amount ,amount1:represent the get amount of reth
    /// @param totalState amount0:represent total share ,amount1:represent totalEth quantity
    /// @param swethShare amount0:represent share amount ,amount1:represent weth quantitty
    /// @param rethStaking amount0:represent investing amount of reth, amount1:represent total reward
    /// @param unstakeAmount amount0:represent amount of reward,amount1 :represent the unstake amount
    event e_unstakeSWETH(
        uint256 totalStake, uint256 totalState, uint256 swethShare, uint256 rethStaking, uint256 unstakeAmount
    );
    /**
     * @notice record the state of staking,
     * @return amount0:represent total share ,amount1:represent totalEth quantity
     */

    function totalState() external returns (uint256);
    /**
     * @notice record the state of stake eth ,
     * @return amount0:represent share amount , amount1:represent eth quantitty
     */
    function sethState() external returns (uint256);
    /**
     * @notice record the state of stake weth
     * @return amount0:represent share amount ,amount1:represent weth quantitty
     */
    function swethState() external returns (uint256);
    /**
     * @notice record the state of staking
     * @return amount0:represent staking amount ,amount1:represent the get amount of reth
     */
    function totalStake() external returns (uint256);
    /**
     * @notice record the state of reth
     * @return amount0:represent investing amount of reth, amount1:represent total reward
     */
    function rethStaking() external returns (uint256);

    /**
     * @notice call when market  stake eth
     * @param token the address of stake(only seth or sweth)
     * @param _stakeamount the amount of stake(only seth or sweth)
     */
    function stakeEth(address token, uint128 _stakeamount) external payable;
    /**
     * @notice call when market  unstake eth
     * @param token the address of unstake(only seth or sweth)
     * @param amount the amount of unstake(only seth or sweth)
     * @return reward the amount of reward
     */
    function unstakeEthSome(address token, uint128 amount) external returns (uint128 reward);

    /**
     * @notice call when market  syncReward info
     * @param token the address (only seth or sweth)
     * @return reward the amount of reward
     */
    function syncReward(address token) external returns (uint128 reward);

    /**
     * @notice call when stake eth to rocketpool
     * @param stakeamount the amount of eth
     * @return rethAmount the amount of reth
     */
    function stakeRocketPoolETH(uint128 stakeamount) external returns (uint128 rethAmount);

    /**
     * @notice call when unstake eth from rocketpool
     * @param rethAmount the amount of reth
     */
    function unstakeRocketPoolETH(uint128 rethAmount) external;

    /**
     * @notice call when invest reth to market
     * @param _goodQuantity the amount of reth
     */
    function invest(uint128 _goodQuantity) external;

    /**
     * @notice call when invest reth to market
     * @param _goodQuantity the amount of reth
     */
    function divest(uint128 _goodQuantity) external;
    /**
     * @notice call when collect tts token
     */
    function collectTTSReward() external;
}
