// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.29;

import {TTSwapError} from "./libraries/L_Error.sol";
import {toTTSwapUINT256, L_TTSwapUINT256Library, add, sub, subadd, addsub, mulDiv} from "./libraries/L_TTSwapUINT256.sol";
import {L_Strings} from "./libraries/L_Strings.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_Transient} from "./libraries/L_Transient2.sol";
import {IRocketDepositPool} from "./interfaces/IRocketDepositPool.sol";
import {IRocketTokenRETH} from "./interfaces/IRocketTokenRETH.sol";
import {IRocketDAOProtocolSettingsDeposit} from "./interfaces/IRocketDAOProtocolSettingsDeposit.sol";
import {I_TTSwap_Market, S_ProofKey} from "./interfaces/I_TTSwap_Market.sol";
import {I_TTSwap_StakeETH} from "./interfaces/I_TTSwap_StakeETH.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {L_ProofIdLibrary} from "./libraries/L_Proof.sol";

contract TTSwap_StakeETH is I_TTSwap_StakeETH {
    using L_TTSwapUINT256Library for uint256;
    using L_Strings for address;
    using L_CurrencyLibrary for address;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 public override TotalState; //amount0:totalShare, amount1:totalETHQuantity
    uint256 public override ethShare; // amount0:share amount1:quantity
    uint256 public override wethShare; // amount0:share amount1:quantity
    uint256 public override TotalStake; // amount0:stakingAmount amount1:currentBalance
    uint256 public override reth_staking; // amount0:reth invest amount,amount1:total reward
    address internal protocolCreator;
    address internal protocolManager;

    // Rocket Pool 主网合约地址
    IRocketDepositPool internal constant ROCKET_DEPOSIT_POOL =
        IRocketDepositPool(0x2cac916b2A963Bf162f076C0a8a4a8200BCFBfb4);
    IRocketTokenRETH internal constant ROCKET_TOKEN_RETH =
        IRocketTokenRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IRocketDAOProtocolSettingsDeposit
        internal constant ROCKET_DAO_SETTINGS_DEPOSIT =
        IRocketDAOProtocolSettingsDeposit(
            0xac2245BE4C2C1E9752499Bcd34861B761d62fC27
        );

    I_TTSwap_Market internal immutable TTSWAP_MARKET;
    IERC20 internal immutable tts_token;
    address internal constant eth = address(2);

    constructor(
        address _creator,
        I_TTSwap_Market _ttswap_market,
        IERC20 _ttswap_token
    ) {
        protocolCreator = _creator;
        protocolManager = msg.sender;
        TTSWAP_MARKET = _ttswap_market;
        tts_token = _ttswap_token;
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

    /// run when eth token
    modifier msgValue() {
        L_Transient.checkbefore();
        _;
        L_Transient.checkafter();
    }

    function changeManager(address _manager) external onlyCreator {
        protocolManager = _manager;
    }

    function stakeEth(
        address token,
        uint128 _stakeamount
    ) external payable override noReentrant msgValue {
        require(token.canRestake() && address(TTSWAP_MARKET) == msg.sender);
        token.transferFrom(address(TTSWAP_MARKET), address(this), _stakeamount);
        TotalStake = add(TotalStake, toTTSwapUINT256(0, _stakeamount));
        uint128 _stakeshare = TotalState != 0
            ? TotalState.getamount0fromamount1(_stakeamount)
            : _stakeamount;

        TotalState = add(
            TotalState,
            toTTSwapUINT256(_stakeshare, _stakeamount)
        );
        if (token == eth) {
            ethShare = add(
                ethShare,
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
        } else {
            wethShare = add(
                wethShare,
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
            token.withdraw(_stakeamount);
        }
    }

    function unstakeEthSome(
        address token,
        uint128 amount
    ) external override noReentrant returns (uint128 reward) {
        require(token.canRestake() && address(TTSWAP_MARKET) == msg.sender);
        internalReward();
        uint128 unstakeshare;
        if (token == eth) {
            unstakeshare = ethShare.getamount0fromamount1(amount);
            reward = TotalState.getamount1fromamount0(unstakeshare);
            ethShare = sub(ethShare, toTTSwapUINT256(unstakeshare, reward));
        } else {
            unstakeshare = wethShare.getamount0fromamount1(amount);
            reward = TotalState.getamount1fromamount0(unstakeshare);
            wethShare = sub(wethShare, toTTSwapUINT256(unstakeshare, reward));
        }
        TotalState = sub(TotalState, toTTSwapUINT256(unstakeshare, reward));
        TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward + amount));
        reward -= amount;
        token.safeTransfer(protocolManager, reward / 9);
        reward = reward - reward / 9;
        token.safeTransfer(msg.sender, reward + amount);
    }

    function syncReward(
        address token
    ) external override noReentrant returns (uint128 reward) {
        internalReward();
        uint128 share;
        if (token == eth) {
            reward =
                TotalState.getamount1fromamount0(ethShare.amount0()) -
                ethShare.amount1();
            share = TotalState.getamount0fromamount1(reward);
            TotalState = sub(TotalState, toTTSwapUINT256(share, reward));
            ethShare = sub(ethShare, toTTSwapUINT256(share, 0));
            TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward));
        } else {
            reward =
                TotalState.getamount1fromamount0(wethShare.amount0()) -
                wethShare.amount1();
            TotalState = sub(TotalState, toTTSwapUINT256(share, reward));
            wethShare = sub(wethShare, toTTSwapUINT256(share, 0));
            TotalStake = sub(TotalStake, toTTSwapUINT256(0, reward));
        }
        token.safeTransfer(protocolManager, reward / 9);
        reward = reward - reward / 9;
        token.safeTransfer(msg.sender, reward);
    }

    function internalReward() internal {
        uint128 reth = uint128(
            ROCKET_TOKEN_RETH.balanceOf(msg.sender) + reth_staking.amount0()
        );
        uint128 eth1 = uint128(ROCKET_TOKEN_RETH.getEthValue(reth));
        uint128 reward = eth1 >= TotalStake.amount0()
            ? eth1 - TotalStake.amount0()
            : 0;
        TotalStake = add(TotalStake, toTTSwapUINT256(reward, 0));
        TotalState = add(TotalState, toTTSwapUINT256(0, reward));
    }

    // 质押ETH，接收rETH
    function stakeRocketPoolETH(uint128 stakeamount) external payable {
        require(
            msg.value > 0 && stakeamount == msg.value,
            "Must send ETH to stake"
        );
        require(
            ROCKET_DAO_SETTINGS_DEPOSIT.getDepositEnabled(),
            "Rocket Pool deposits are currently disabled"
        );

        uint256 depositPoolBalance = ROCKET_DEPOSIT_POOL.getBalance();
        uint256 maxDepositPoolSize = ROCKET_DAO_SETTINGS_DEPOSIT
            .getMaximumDepositPoolSize();
        require(
            depositPoolBalance + msg.value <= maxDepositPoolSize,
            "Deposit pool size exceeded"
        );

        // 质押ETH到Rocket Pool
        ROCKET_DEPOSIT_POOL.deposit{value: msg.value}();

        TotalStake = addsub(
            TotalStake,
            toTTSwapUINT256(stakeamount, stakeamount)
        );

        // 计算获得的rETH数量
        uint256 rethAmount = ROCKET_TOKEN_RETH.getRethValue(msg.value);

        emit e_stakeRocketPoolETH(stakeamount, rethAmount);
    }

    // 取消质押rETH，取回ETH
    function unstakeRocketPoolETH(uint256 rethAmount) external {
        require(rethAmount > 0, "Amount must be greater than 0");
        require(
            ROCKET_TOKEN_RETH.balanceOf(msg.sender) >= rethAmount,
            "Insufficient rETH balance"
        );

        // 计算将获得的ETH数量
        uint128 ethAmount = uint128(ROCKET_TOKEN_RETH.getEthValue(rethAmount));

        // 销毁rETH并取回ETH
        ROCKET_TOKEN_RETH.burn(rethAmount);

        TotalStake = subadd(TotalStake, toTTSwapUINT256(ethAmount, ethAmount));

        emit e_rocketpoolUnstaked(rethAmount, ethAmount);
    }

    // 接收ETH的回退函数
    receive() external payable {
        emit e_Received(msg.value);
    }

    // 投资rETH到流动性产生流动性收益
    function invest(
        uint128 _goodQuantity,
        bytes calldata data1
    ) external override {
        uint256 proofid = S_ProofKey(
            address(this),
            address(ROCKET_TOKEN_RETH),
            address(0)
        ).toId();
        require(
            (_goodQuantity >=
                (
                    TTSWAP_MARKET.getProofState(proofid).invest.amount0() == 0
                        ? 0
                        : (TTSWAP_MARKET
                            .getProofState(proofid)
                            .invest
                            .amount0() * 2) / 10
                )) &&
                (_goodQuantity <=
                    (uint128(ROCKET_TOKEN_RETH.balanceOf(address(this))) * 8) /
                        10)
        );
        reth_staking = add(reth_staking, toTTSwapUINT256(_goodQuantity, 0));
        TTSWAP_MARKET.investGood(
            address(ROCKET_TOKEN_RETH),
            address(0),
            _goodQuantity,
            data1,
            "0x"
        );
        emit e_stakeeth_invest(_goodQuantity);
    }
    // 撤资rETH以供赎回

    function divest(uint128 _goodQuantity) external override {
        uint256 proofid = S_ProofKey(
            address(this),
            address(ROCKET_TOKEN_RETH),
            address(0)
        ).toId();
        require(
            _goodQuantity <=
                TTSWAP_MARKET.getProofState(proofid).invest.amount0()
        );

        (uint128 reward, ) = TTSWAP_MARKET.disinvestProof(
            proofid,
            _goodQuantity,
            protocolManager
        );
        _goodQuantity += reward;
        reth_staking = add(reth_staking, toTTSwapUINT256(0, _goodQuantity));

        emit e_stakeeth_devest(_goodQuantity);
    }

    function collectTTS() external override {
        require(msg.sender == protocolManager);
        uint256 amount = tts_token.balanceOf(address(this));
        address(tts_token).safeTransfer(protocolCreator, amount);
        emit e_collecttts(amount);
    }
}
