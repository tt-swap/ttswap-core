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
    uint256 public override totalStake; // amount0:stakingAmount amount1:getRethAmount
    uint256 public override rethStaking; // amount0:reth invest amount,amount1: reward
    address internal protocolCreator;
    address internal protocolManager;

    // rocket pool token  address
    IRocketTokenRETH internal immutable ROCKET_TOKEN_RETH;
    // rocket storge contract address
    IRocketStorage internal immutable rocketstorage;
    // ttswap market contract address
    I_TTSwap_Market internal immutable TTSWAP_MARKET;
    // ttswap token address
    IERC20 internal immutable tts_token;
    // address(2) stand for the pool of eth can restaking to rocketpool
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

    /// @notice change by creator
    /// @param _manager new manager's address
    function changeManager(address _manager) external onlyCreator {
        protocolManager = _manager;
    }

    /// @inheritdoc I_TTSwap_StakeETH
    function stakeEth(
        address token,
        uint128 _stakeamount
    ) external payable override noReentrant {
        if (!token.canRestake() || address(TTSWAP_MARKET) != msg.sender)
            revert TTSwapError(37);
        token.transferFrom(address(TTSWAP_MARKET), address(this), _stakeamount);
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

    /// @inheritdoc I_TTSwap_StakeETH
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
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward + amount);
            emit e_unstakeSETH(
                totalStake,
                totalState,
                sethState,
                rethStaking,
                toTTSwapUINT256(reward, amount)
            );
        } else {
            unstakeshare = swethState.getamount0fromamount1(amount);
            reward = totalState.getamount1fromamount0(unstakeshare);
            swethState = sub(swethState, toTTSwapUINT256(unstakeshare, reward));
            totalState = sub(totalState, toTTSwapUINT256(unstakeshare, reward));
            token.deposit(amount + reward);
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward + amount);
            emit e_unstakeSWETH(
                totalStake,
                totalState,
                swethState,
                rethStaking,
                toTTSwapUINT256(reward, amount)
            );
        }
    }

    /// @inheritdoc I_TTSwap_StakeETH
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

            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward);
            emit e_unstakeSETH(
                totalStake,
                totalState,
                sethState,
                rethStaking,
                toTTSwapUINT256(reward, 0)
            );
        } else {
            reward =
                totalState.getamount1fromamount0(swethState.amount0()) -
                swethState.amount1();

            share = totalState.getamount0fromamount1(reward);
            totalState = sub(totalState, toTTSwapUINT256(share, reward));
            swethState = sub(swethState, toTTSwapUINT256(share, 0));
            token.deposit(reward);
            token.safeTransfer(protocolManager, reward / 9);
            reward = reward - reward / 9;
            token.safeTransfer(msg.sender, reward);
            emit e_unstakeSWETH(
                totalStake,
                totalState,
                swethState,
                rethStaking,
                toTTSwapUINT256(reward, 0)
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
        if (reward > 0) {
            totalStake = add(totalStake, toTTSwapUINT256(reward, 0));
            totalState = add(totalState, toTTSwapUINT256(0, reward));
            rethStaking = add(rethStaking, toTTSwapUINT256(0, reward));
        }
    }

    /// @inheritdoc I_TTSwap_StakeETH
    function stakeRocketPoolETH(
        uint128 stakeamount
    ) external override onlyManager returns (uint128 rethAmount) {
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

        rethAmount = uint128(ROCKET_TOKEN_RETH.getRethValue(stakeamount));
        address(ROCKET_DEPOSIT_POOL).deposit(stakeamount);

        totalStake = add(totalStake, toTTSwapUINT256(stakeamount, rethAmount));

        emit e_stakeRocketPoolETH(totalStake);
    }

    /// @inheritdoc I_TTSwap_StakeETH
    function unstakeRocketPoolETH(
        uint128 rethAmount
    ) external override onlyManager {
        require(rethAmount > 0, "Amount must be greater than 0");
        uint128 ethAmount = totalStake.getamount0fromamount1(rethAmount);
        uint128 unstakeeth = uint128(ROCKET_TOKEN_RETH.getEthValue(rethAmount));
        require(
            IERC20(address(ROCKET_TOKEN_RETH)).balanceOf(address(this)) >=
                rethAmount,
            "Insufficient rETH balance"
        );
        uint128 reward = unstakeeth - ethAmount;
        ROCKET_TOKEN_RETH.burn(rethAmount);
        totalState = add(totalState, toTTSwapUINT256(0, unstakeeth));
        totalStake = sub(totalStake, toTTSwapUINT256(ethAmount, rethAmount));
        emit e_rocketpoolUnstaked(totalStake, totalState, reward);
    }

    receive() external payable {
        emit e_Received(msg.value);
    }

    /// @inheritdoc I_TTSwap_StakeETH
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

    /// @inheritdoc I_TTSwap_StakeETH
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

        TTSWAP_MARKET.disinvestProof(proofid, _goodQuantity, protocolManager);

        rethStaking = subadd(rethStaking, toTTSwapUINT256(_goodQuantity, 0));
        emit e_stakeeth_devest(rethStaking);
    }

    /// @inheritdoc I_TTSwap_StakeETH
    function collectTTSReward() external override onlyManager {
        uint128 amount = uint128(tts_token.balanceOf(address(this)));
        if (amount > 0) {
            tts_token.approve(address(TTSWAP_MARKET), amount);
            (, uint256 getamount) = TTSWAP_MARKET.buyGood(
                address(tts_token),
                address(ROCKET_TOKEN_RETH),
                amount,
                1,
                address(0),
                ""
            );
            emit e_collecttts(toTTSwapUINT256(amount, getamount.amount1()));
        }
    }
}
