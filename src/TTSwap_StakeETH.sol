// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {TTSwapError} from "./libraries/L_Error.sol";
import {toTTSwapUINT256, L_TTSwapUINT256Library, add, sub, subadd, addsub, mulDiv} from "./libraries/L_TTSwapUINT256.sol";
import {L_Strings} from "./libraries/L_Strings.sol";
import {L_ETHLibrary} from "./libraries/L_ETH.sol";
import {L_Transient} from "./libraries/L_Transient.sol";
import {IRocketDepositPool} from "./interfaces/IRocketDepositPool.sol";
import {IRocketTokenRETH} from "./interfaces/IRocketTokenRETH.sol";
import {IRocketDAOProtocolSettingsDeposit} from "./interfaces/IRocketDAOProtocolSettingsDeposit.sol";

contract TTSwap_StakeETH {
    using L_TTSwapUINT256Library for uint256;
    using L_Strings for address;

    uint256 TotalState; //amount0:totalShare, amount1:totalETHQuantity
    uint256 TotalStake; // amount0:stakingAmount amount1:currentBalance
    mapping(address => uint256) userStakeState; //amount0:share,amount1:stakeeth
    address protocolCreator;
    address protocolManager;
    event e_stakeRocketPoolETH(uint128, uint256);
    event e_Received(uint256);
    event e_rocketpoolUnstaked(uint256, uint256);

    // Rocket Pool 主网合约地址
    address public constant ROCKET_DEPOSIT_POOL =
        0x2cac916b2A963Bf162f076C0a8a4a8200BCFBfb4;
    address public constant ROCKET_TOKEN_RETH =
        0xae78736Cd615f374D3085123A210448E74Fc6393;
    address public constant ROCKET_DAO_SETTINGS_DEPOSIT =
        0xac2245BE4C2C1E9752499Bcd34861B761d62fC27;

    IRocketDepositPool public rocketDepositPool;
    IRocketTokenRETH public rocketTokenRETH;
    IRocketDAOProtocolSettingsDeposit public rocketDAOSettingsDeposit;

    address internal constant eth = address(2);
    constructor(address _creator) {
        protocolCreator = _creator;
        protocolManager = msg.sender;
    }

    modifier onlyCreator() {
        require(msg.sender == protocolCreator);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == protocolManager);
        _;
    }

    modifier noReentrant() {
        if (L_Transient.get() != address(0)) revert TTSwapError(3);
        L_Transient.set(msg.sender);
        _;
        L_Transient.set(address(0));
    }

    function changeManager(address _manager) external onlyCreator {
        protocolManager = _manager;
    }

    function stakeEth(uint128 _stakeamount) external payable noReentrant {
        L_ETHLibrary.transferFrom(_stakeamount);
        TotalStake = add(TotalStake, toTTSwapUINT256(0, _stakeamount));
        uint128 _stakeshare;
        if (TotalState != 0) {
            _stakeshare = TotalState.getamount0fromamount1(_stakeamount);
            TotalState = add(
                TotalState,
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
            TotalStake = add(TotalStake, toTTSwapUINT256(0, _stakeamount));
            userStakeState[msg.sender] = add(
                userStakeState[msg.sender],
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
        } else {
            TotalState = add(
                TotalState,
                toTTSwapUINT256(_stakeamount, _stakeamount)
            );
            TotalStake = add(TotalStake, toTTSwapUINT256(0, _stakeamount));
            userStakeState[msg.sender] = add(
                userStakeState[msg.sender],
                toTTSwapUINT256(_stakeamount, _stakeamount)
            );
        }
    }

    function unstakeEthSome(
        uint128 amount
    ) external noReentrant returns (uint128 reward) {
        internalReward();
        require(TotalStake.amount1() >= amount);
        uint128 unstakeshare = userStakeState[msg.sender].getamount0fromamount1(
            amount
        );
        userStakeState[msg.sender] = sub(
            userStakeState[msg.sender],
            toTTSwapUINT256(unstakeshare, amount)
        );
        reward = TotalState.getamount1fromamount0(unstakeshare);
        TotalState = sub(TotalState, toTTSwapUINT256(unstakeshare, reward));
        TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward));
        reward = reward - amount;
        L_ETHLibrary.transfer(protocolManager, reward / 9);
        reward = reward - reward / 9;
        L_ETHLibrary.transfer(msg.sender, amount + reward);
    }

    function unstakeETHAll()
        external
        noReentrant
        returns (uint128 reward, uint128 amount)
    {
        internalReward();
        uint256 unstakeshare = userStakeState[msg.sender];
        amount = unstakeshare.amount1();
        delete userStakeState[msg.sender];
        reward = TotalState.getamount1fromamount0(unstakeshare.amount0());
        TotalState = sub(
            TotalState,
            toTTSwapUINT256(unstakeshare.amount0(), reward)
        );
        TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward));
        reward = reward - amount;
        L_ETHLibrary.transfer(protocolManager, reward / 9);
        reward = reward - reward / 9;
        L_ETHLibrary.transfer(msg.sender, amount + reward);
    }

    function syncReward() external noReentrant returns (uint128 reward) {
        internalReward();
        uint256 stakeState = userStakeState[msg.sender];
        reward =
            TotalState.getamount1fromamount0(stakeState.amount0()) -
            stakeState.amount1();
        uint128 share = TotalState.getamount0fromamount1(reward);
        userStakeState[msg.sender] = sub(stakeState, toTTSwapUINT256(share, 0));
        TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward));
        TotalState = sub(TotalState, toTTSwapUINT256(share, reward));
        L_ETHLibrary.transfer(protocolManager, reward / 9);
        reward = reward - reward / 9;
        L_ETHLibrary.transfer(msg.sender, reward);
    }

    function internalReward() internal {
        uint128 reth = uint128(rocketTokenRETH.balanceOf(msg.sender));
        uint128 eth1 = uint128(rocketTokenRETH.getEthValue(reth));
        uint128 reward = eth1 >= TotalStake.amount0()
            ? eth1 - TotalStake.amount0()
            : 0;
        TotalStake = add(TotalStake, toTTSwapUINT256(reward, 0));
        TotalState = add(TotalStake, toTTSwapUINT256(0, reward));
    }

    // 质押ETH，接收rETH
    function stakeRocketPoolETH(uint128 stakeamount) external payable {
        require(
            msg.value > 0 && stakeamount == msg.value,
            "Must send ETH to stake"
        );
        require(
            rocketDAOSettingsDeposit.getDepositEnabled(),
            "Rocket Pool deposits are currently disabled"
        );

        uint256 depositPoolBalance = rocketDepositPool.getBalance();
        uint256 maxDepositPoolSize = rocketDAOSettingsDeposit
            .getMaximumDepositPoolSize();
        require(
            depositPoolBalance + msg.value <= maxDepositPoolSize,
            "Deposit pool size exceeded"
        );

        // 质押ETH到Rocket Pool
        rocketDepositPool.deposit{value: msg.value}();

        TotalStake = addsub(
            TotalStake,
            toTTSwapUINT256(stakeamount, stakeamount)
        );

        // 计算获得的rETH数量
        uint256 rethAmount = rocketTokenRETH.getRethValue(msg.value);

        emit e_stakeRocketPoolETH(stakeamount, rethAmount);
    }

    // 取消质押rETH，取回ETH
    function unstakeRocketPoolETH(uint256 rethAmount) external {
        require(rethAmount > 0, "Amount must be greater than 0");
        require(
            rocketTokenRETH.balanceOf(msg.sender) >= rethAmount,
            "Insufficient rETH balance"
        );

        // 计算将获得的ETH数量
        uint128 ethAmount = uint128(rocketTokenRETH.getEthValue(rethAmount));

        // 销毁rETH并取回ETH
        rocketTokenRETH.burn(rethAmount);

        TotalStake = subadd(TotalStake, toTTSwapUINT256(ethAmount, ethAmount));

        emit e_rocketpoolUnstaked(rethAmount, ethAmount);
    }

    // 查询用户的rETH余额
    function getRETHBalance(address user) external view returns (uint256) {
        return rocketTokenRETH.balanceOf(user);
    }

    // 查询rETH对应的ETH价值
    function getETHValue(uint256 rethAmount) external view returns (uint256) {
        return rocketTokenRETH.getEthValue(rethAmount);
    }

    // 检查存款是否启用
    function isDepositEnabled() external view returns (bool) {
        return rocketDAOSettingsDeposit.getDepositEnabled();
    }

    // 接收ETH的回退函数
    receive() external payable {
        emit e_Received(msg.value);
    }
}
