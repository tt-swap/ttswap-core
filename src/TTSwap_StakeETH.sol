// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.29;

import {TTSwapError} from "./libraries/L_Error.sol";
import {toTTSwapUINT256, L_TTSwapUINT256Library, add, sub, subadd, addsub, mulDiv} from "./libraries/L_TTSwapUINT256.sol";
import {L_Strings} from "./libraries/L_Strings.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency_Stake.sol";
import {L_Transient} from "./libraries/L_Transient_Stake.sol";
import {IRocketDepositPool} from "./interfaces/IRocketDepositPool.sol";
import {IRocketTokenRETH} from "./interfaces/IRocketTokenRETH.sol";
import {IRocketDAOProtocolSettingsDeposit} from "./interfaces/IRocketDAOProtocolSettingsDeposit.sol";
import {IRocketStorage} from "./interfaces/IRocketStorage.sol";
import {I_TTSwap_Market, S_ProofKey} from "./interfaces/I_TTSwap_Market.sol";
import {I_TTSwap_StakeETH} from "./interfaces/I_TTSwap_StakeETH.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {L_ProofIdLibrary} from "./libraries/L_Proof.sol";

contract TTSwap_StakeETH is I_TTSwap_StakeETH {
    using L_TTSwapUINT256Library for uint256;
    using L_Strings for address;
    using L_CurrencyLibrary for address;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 public override totalState; //amount0:totalShare, amount1:totalETHQuantity
    uint256 public override sethState; // amount0:share amount1:quantity
    uint256 public override swethState; // amount0:share amount1:quantity
    uint256 public override totalStake; // amount0:stakingAmount amount1:currentBalance
    uint256 public override rethStaking; // amount0:reth invest amount,amount1: reward
    address internal protocolCreator;
    address internal protocolManager;

    // Rocket Pool 主网合约地址]
    IRocketTokenRETH internal immutable ROCKET_TOKEN_RETH;
    IRocketStorage internal immutable rocketstorage;
    I_TTSwap_Market internal immutable TTSWAP_MARKET;
    IERC20 internal immutable tts_token;
    address internal constant seth = address(2);

    constructor(
        address _creator,
        I_TTSwap_Market _ttswap_market,
        IERC20 _ttswap_token,
        IRocketTokenRETH _ROCKET_TOKEN_RETH,
        IRocketStorage _rocketstorage
    ) {
        protocolCreator = _creator;
        protocolManager = msg.sender;
        TTSWAP_MARKET = _ttswap_market;
        tts_token = _ttswap_token;
        rocketstorage = _rocketstorage;
        ROCKET_TOKEN_RETH = _ROCKET_TOKEN_RETH;
    }

    modifier onlyCreator() {
        require(msg.sender == protocolCreator);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == protocolManager);
        _;
    }

    /// @notice This will revert if the contract is locked
    modifier noReentrant() {
        if (L_Transient.get() != address(0)) revert TTSwapError(3);
        L_Transient.set(msg.sender);
        _;
        L_Transient.set(address(0));
    }

    function changeManager(address _manager) external onlyCreator {
        protocolManager = _manager;
    }

    function stakeEth(
        address token,
        uint128 _stakeamount
    ) external payable override noReentrant {
        if (!token.canRestake() || address(TTSWAP_MARKET) != msg.sender)
            revert TTSwapError(37);
        token.transferFrom(address(TTSWAP_MARKET), address(this), _stakeamount);
        totalStake = add(totalStake, toTTSwapUINT256(0, _stakeamount));
        uint128 _stakeshare = totalState != 0
            ? totalState.getamount0fromamount1(_stakeamount)
            : _stakeamount;

        totalState = add(
            totalState,
            toTTSwapUINT256(_stakeshare, _stakeamount)
        );
        if (token == seth) {
            sethState = add(
                sethState,
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
            emit e_stakeSETH(
                totalStake,
                totalState,
                sethState,
                rethStaking,
                _stakeamount
            );
        } else {
            swethState = add(
                swethState,
                toTTSwapUINT256(_stakeshare, _stakeamount)
            );
            token.withdraw(_stakeamount);
            emit e_stakeSWETH(
                totalStake,
                totalState,
                swethState,
                rethStaking,
                _stakeamount
            );
        }
    }

    function unstakeEthSome(
        address token,
        uint128 amount
    ) external override noReentrant returns (uint128 reward) {
        if (!token.canRestake() || address(TTSWAP_MARKET) != msg.sender)
            revert TTSwapError(37);
        internalReward();
        uint128 unstakeshare;
        if (token == seth) {
            unstakeshare = sethState.getamount0fromamount1(amount);
            reward = totalState.getamount1fromamount0(unstakeshare);
            sethState = sub(sethState, toTTSwapUINT256(unstakeshare, reward));
            totalState = sub(totalState, toTTSwapUINT256(unstakeshare, reward));
            totalStake = sub(totalStake, toTTSwapUINT256(0, reward + amount));
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward + amount);
            emit e_unstakeSETH(
                totalStake,
                totalState,
                sethState,
                rethStaking,
                reward
            );
        } else {
            unstakeshare = swethState.getamount0fromamount1(amount);
            reward = totalState.getamount1fromamount0(unstakeshare);
            swethState = sub(swethState, toTTSwapUINT256(unstakeshare, reward));
            totalState = sub(totalState, toTTSwapUINT256(unstakeshare, reward));
            totalStake = sub(totalStake, toTTSwapUINT256(0, reward + amount));
            token.deposit(amount + reward);
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward + amount);
            emit e_unstakeSWETH(
                totalStake,
                totalState,
                swethState,
                rethStaking,
                reward
            );
        }
    }

    function syncReward(
        address token
    ) external override noReentrant returns (uint128 reward) {
        if (!token.canRestake() || address(TTSWAP_MARKET) != msg.sender)
            revert TTSwapError(37);
        internalReward();
        uint128 share;
        if (token == seth) {
            reward =
                totalState.getamount1fromamount0(sethState.amount0()) -
                sethState.amount1();
            share = totalState.getamount0fromamount1(reward);
            totalState = sub(totalState, toTTSwapUINT256(share, reward));
            sethState = sub(sethState, toTTSwapUINT256(share, 0));
            totalStake = sub(totalStake, toTTSwapUINT256(0, reward));
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward);
            emit e_unstakeSETH(
                totalStake,
                totalState,
                sethState,
                rethStaking,
                reward
            );
        } else {
            reward =
                totalState.getamount1fromamount0(swethState.amount0()) -
                swethState.amount1();

            share = totalState.getamount0fromamount1(reward);
            totalState = sub(totalState, toTTSwapUINT256(share, reward));
            swethState = sub(swethState, toTTSwapUINT256(share, 0));
            totalStake = sub(totalStake, toTTSwapUINT256(0, reward));
            token.deposit(reward);
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward);
            emit e_unstakeSWETH(
                totalStake,
                totalState,
                swethState,
                rethStaking,
                reward
            );
        }
    }

    function internalReward() internal {
        uint128 reth = uint128(
            IERC20(address(ROCKET_TOKEN_RETH)).balanceOf(address(this)) +
                rethStaking.amount0()
        );
        uint128 eth1 = uint128(ROCKET_TOKEN_RETH.getEthValue(reth));
        uint128 reward = eth1 >= totalStake.amount0()
            ? eth1 - totalStake.amount0()
            : 0;
        totalStake = add(totalStake, toTTSwapUINT256(reward, 0));
        totalState = add(totalState, toTTSwapUINT256(0, reward));
        rethStaking = toTTSwapUINT256(rethStaking.amount0(), 0);
    }

    // 质押ETH，接收rETH
    function stakeRocketPoolETH(
        uint128 stakeamount
    ) external override onlyManager returns (uint256 rethAmount) {
        IRocketDAOProtocolSettingsDeposit ROCKET_DAO_SETTINGS_DEPOSIT = IRocketDAOProtocolSettingsDeposit(
                rocketstorage.getAddress(
                    keccak256(
                        abi.encodePacked(
                            "contract.address",
                            "rocketDAOProtocolSettingsDeposit"
                        )
                    )
                )
            );
        IRocketDepositPool ROCKET_DEPOSIT_POOL = IRocketDepositPool(
            rocketstorage.getAddress(
                keccak256(
                    abi.encodePacked("contract.address", "rocketDepositPool")
                )
            )
        );
        require(
            ROCKET_DAO_SETTINGS_DEPOSIT.getDepositEnabled(),
            "Rocket Pool deposits are currently disabled"
        );

        uint256 depositPoolBalance = ROCKET_DEPOSIT_POOL.getBalance();
        uint256 maxDepositPoolSize = ROCKET_DAO_SETTINGS_DEPOSIT
            .getMaximumDepositPoolSize();

        require(
            depositPoolBalance + stakeamount <= maxDepositPoolSize,
            "Deposit pool size exceeded"
        );

        // 质押ETH到Rocket Pool
        // ROCKET_DEPOSIT_POOL.deposit{value: stakeamount}();
        address(ROCKET_DEPOSIT_POOL).deposit(stakeamount);
        totalStake = addsub(
            totalStake,
            toTTSwapUINT256(stakeamount, stakeamount)
        );

        // 计算获得的rETH数量
        rethAmount = ROCKET_TOKEN_RETH.getRethValue(stakeamount);

        emit e_stakeRocketPoolETH(totalStake);
    }

    // 取消质押rETH，取回ETH
    function unstakeRocketPoolETH(
        uint256 rethAmount
    ) external override onlyManager {
        require(rethAmount > 0, "Amount must be greater than 0");

        require(
            IERC20(address(ROCKET_TOKEN_RETH)).balanceOf(address(this)) >=
                rethAmount,
            "Insufficient rETH balance"
        );

        // 计算将获得的ETH数量
        uint128 ethAmount = uint128(ROCKET_TOKEN_RETH.getEthValue(rethAmount));
        uint128 reward = ethAmount -
            toTTSwapUINT256(totalStake.amount0(), rethStaking.amount0())
                .getamount0fromamount1(uint128(rethAmount));
        rethStaking = sub(rethStaking, toTTSwapUINT256(uint128(rethAmount), 0));

        // 销毁rETH并取回ETH
        ROCKET_TOKEN_RETH.burn(rethAmount);

        totalStake = subadd(totalStake, toTTSwapUINT256(ethAmount, ethAmount));
        totalState = add(totalState, toTTSwapUINT256(0, reward));

        emit e_rocketpoolUnstaked(totalStake, totalState, reward);
    }

    // 接收ETH的回退函数
    receive() external payable {
        emit e_Received(msg.value);
    }

    // 投资rETH到流动性产生流动性收益
    function invest(uint128 _goodQuantity) external override onlyManager {
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
                    (uint128(
                        IERC20(address(ROCKET_TOKEN_RETH)).balanceOf(
                            address(this)
                        )
                    ) * 8) /
                        10)
        );
        rethStaking = add(rethStaking, toTTSwapUINT256(_goodQuantity, 0));
        IERC20(address(ROCKET_TOKEN_RETH)).approve(
            address(TTSWAP_MARKET),
            _goodQuantity
        );
        TTSWAP_MARKET.investGood(
            address(ROCKET_TOKEN_RETH),
            address(0),
            _goodQuantity,
            "",
            ""
        );
        emit e_stakeeth_invest(rethStaking);
    }
    // 撤资rETH以供赎回

    function divest(uint128 _goodQuantity) external override onlyManager {
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
        rethStaking = subadd(
            rethStaking,
            toTTSwapUINT256(_goodQuantity, reward)
        );
        emit e_stakeeth_devest(rethStaking);
    }

    function collectTTSReward() external override onlyManager {
        uint128 amount = uint128(tts_token.balanceOf(address(this)));
        if (amount > 0) {
            tts_token.approve(address(TTSWAP_MARKET), amount);
            TTSWAP_MARKET.buyGood(
                address(tts_token),
                address(ROCKET_TOKEN_RETH),
                amount,
                1,
                address(0),
                ""
            );
            emit e_collecttts(amount);
        }
    }
}
