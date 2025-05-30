// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.29;

import {I_TTSwap_Market, S_ProofState, S_GoodState, S_ProofKey, S_GoodTmpState} from "./interfaces/I_TTSwap_Market.sol";
import {L_Good} from "./libraries/L_Good.sol";
import {L_Transient} from "./libraries/L_Transient.sol";
import {TTSwapError} from "./libraries/L_Error.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_UserConfigLibrary} from "./libraries/L_UserConfig.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {I_TTSwap_Token} from "./interfaces/I_TTSwap_Token.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, add, sub, addsub, subadd, lowerprice} from "./libraries/L_TTSwapUINT256.sol";
import {IERC3156FlashBorrower} from "./interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "./interfaces/IERC3156FlashLender.sol";
import {IMulticall_v4} from "./interfaces/IMulticall_v4.sol";
import {ERC6909} from "./base/ERC6909.sol";
import {I_TTSwap_StakeETH} from "./interfaces/I_TTSwap_StakeETH.sol";

/**
 * @title TTSwap_Market
 * @dev Manages the market operations for goods and proofs.
 * @notice This contract handles initialization, buying, selling, investing, and disinvesting of goods and proofs.
 */
contract TTSwap_Market is
    I_TTSwap_Market,
    IERC3156FlashLender,
    IMulticall_v4,
    ERC6909
{
    using L_GoodConfigLibrary for uint256;
    using L_UserConfigLibrary for uint256;
    using L_ProofIdLibrary for S_ProofKey;
    using L_TTSwapUINT256Library for uint256;
    using L_Good for S_GoodState;
    using L_Proof for S_ProofState;
    using L_CurrencyLibrary for address;
    using L_MarketConfigLibrary for uint256;
    /**
     * @dev The loan token is not valid.
     */

    error ERC3156UnsupportedToken(address token);

    /**
     * @dev The requested loan exceeds the max loan value for `token`.
     */
    error ERC3156ExceededMaxLoan(uint256 maxLoan);

    /**
     * @dev The receiver of a flashloan is not a valid {IERC3156FlashBorrower-onFlashLoan} implementer.
     */
    error ERC3156InvalidReceiver(address receiver);

    //keccak256("ERC3156FlashBorrower.onFlashLoan");
    bytes32 private constant RETURN_VALUE =
        bytes32(
            0x439148f0bbc682ca079e46d6e2c2f0c1e3b820f1a291b069d8882abf8cf18dd9
        );

    mapping(address goodid => S_GoodState) private goods;
    mapping(uint256 proofid => S_ProofState) private proofs;
    mapping(address => uint256) public override userConfig;
    uint256 restakingamount;

    /// @notice recording the config of commision allocate
    uint256 public override marketconfig;
    /// @notice the deploy of contract
    address public marketcreator;
    /// @notice when  invest, customer can mint tts token
    address private immutable officialTokenContract;
    /// @notice the address will be change to address0 when contract is safe
    address private securitykeeper;

    I_TTSwap_StakeETH private restakeContract;

    /**
     * @dev Constructor for TTSwap_Market
     * @param _marketconfig The market configuration
     * @param _officialTokenContract The address of the official token contract
     * @param _marketcreator The address of the official contract
     */
    constructor(
        uint256 _marketconfig,
        address _officialTokenContract,
        address _marketcreator,
        address _securitykeeper
    ) {
        officialTokenContract = _officialTokenContract;
        marketconfig = _marketconfig;
        marketcreator = _marketcreator;
        securitykeeper = _securitykeeper;
    }

    /// onlydao admin can execute
    modifier onlyDAOadmin() {
        if (marketcreator != msg.sender) revert TTSwapError(1);
        _;
    }
    /// onlydao manager can execute

    modifier onlyMarketor() {
        if (!userConfig[msg.sender].isMarketor()) revert TTSwapError(2);
        _;
    }

    /// run when eth token
    modifier msgValue() {
        L_Transient.checkbefore();
        _;
        L_Transient.checkafter();
    }

    /// @notice This will revert if the contract is locked
    modifier noReentrant() {
        if (L_Transient.get() != address(0)) revert TTSwapError(3);
        L_Transient.set(msg.sender);
        _;
        L_Transient.set(address(0));
    }

    /// @notice Enables calling multiple methods in a single call to the contract
    /// @inheritdoc IMulticall_v4
    function multicall(
        bytes[] calldata data
    ) external payable msgValue returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                // bubble up the revert reason
                assembly {
                    revert(add(result, 0x20), mload(result))
                }
            }

            results[i] = result;
        }
    }
    /// change daoadmin

    function changemarketcreator(address _newmarketor) external onlyDAOadmin {
        marketcreator = _newmarketor;
        emit e_changemarketcreator(_newmarketor);
    }

    function setAuth(address _newmarketor, uint256 auth) external onlyDAOadmin {
        userConfig[_newmarketor] = auth;
        emit e_modifiedUserConfig(_newmarketor, auth);
    }

    /// @inheritdoc I_TTSwap_Market
    function addbanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        userConfig[_user] = userConfig[_user] | 1;
        emit e_modifiedUserConfig(_user, userConfig[_user]);
        return true;
    }

    /// @inheritdoc I_TTSwap_Market
    function removebanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        userConfig[_user] = userConfig[_user] & ~uint256(1);
        emit e_modifiedUserConfig(_user, userConfig[_user]);
        return true;
    }
    /**
     * @dev Initializes a meta good
     * @param _erc20address The address of the ERC20 token
     * @param _initial The initial balance
     * @param _goodConfig The good configuration
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function initMetaGood(
        address _erc20address,
        uint256 _initial,
        uint256 _goodConfig,
        bytes calldata data
    ) external payable onlyDAOadmin msgValue returns (bool) {
        if (
            !_goodConfig.isvaluegood() ||
            goods[_erc20address].owner != address(0)
        ) revert TTSwapError(4);
        _erc20address.transferFrom(msg.sender, _initial.amount1(), data);
        goods[_erc20address].init(_initial, _goodConfig);
        /// update good to value good
        goods[_erc20address].modifyGoodConfig(67108864); //2**26
        uint256 proofid = S_ProofKey(msg.sender, _erc20address, address(0))
            .toId();

        proofs[proofid].updateInvest(
            _erc20address,
            address(0),
            toTTSwapUINT256(_initial.amount0(), 0),
            _initial.amount1(),
            0
        );
        _mint(msg.sender, _erc20address.to_uint256(), _initial.amount1());
        uint128 construct = L_Proof.stake(
            officialTokenContract,
            msg.sender,
            _initial.amount0()
        );
        emit e_initMetaGood(
            proofid,
            _erc20address,
            construct,
            _goodConfig,
            _initial
        );
        return true;
    }

    /**
     * @dev Initializes a good
     * @param _valuegood The value good ID
     * @param _initial The initial balance,amount0 is the amount of the normal good,amount1 is the amount of the value good
     * @param _erc20address The address of the ERC20 token
     * @param _goodConfig The good configuration
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function initGood(
        address _valuegood,
        uint256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        bytes calldata _normaldata,
        bytes calldata _valuedata
    ) external payable override noReentrant msgValue returns (bool) {
        if (
            goods[_erc20address].owner != address(0) ||
            !goods[_valuegood].goodConfig.isvaluegood()
        ) {
            revert TTSwapError(5);
        }
        _erc20address.transferFrom(msg.sender, _initial.amount0(), _normaldata);
        _valuegood.transferFrom(msg.sender, _initial.amount1(), _valuedata);
        L_Good.S_GoodInvestReturn memory investResult;
        goods[_valuegood].investGood(_initial.amount1(), investResult);
        goods[_erc20address].init(
            toTTSwapUINT256(investResult.actualInvestValue, _initial.amount0()),
            _goodConfig
        );

        uint256 proofId = S_ProofKey(msg.sender, _erc20address, _valuegood)
            .toId();

        proofs[proofId] = S_ProofState(
            _erc20address,
            _valuegood,
            toTTSwapUINT256(investResult.actualInvestValue, 0),
            _initial.amount0(),
            toTTSwapUINT256(
                investResult.constructFeeQuantity,
                investResult.actualInvestQuantity
            )
        );

        _mint(msg.sender, _erc20address.to_uint256(), _initial.amount0());
        _mint(msg.sender, _valuegood.to_uint256(), _initial.amount1());

        emit e_initGood(
            proofId,
            _erc20address,
            _valuegood,
            _goodConfig,
            L_Proof.stake(
                officialTokenContract,
                msg.sender,
                investResult.actualInvestValue * 2
            ),
            toTTSwapUINT256(_initial.amount0(), investResult.actualInvestValue),
            toTTSwapUINT256(
                investResult.actualFeeQuantity,
                investResult.actualInvestQuantity
            )
        );
        return true;
    }
    /**
     * @dev Buys a good
     * @param _goodid1 The ID of the first good
     * @param _goodid2 The ID of the second good
     * @param _swapQuantity The quantity to swap
     * @param _tradetimes trade times
     * @param _recipent if The referral address
     * @return good1change amount0() good1tradefee,good1tradeamount
     * @return good2change amount0() good1tradefee,good2tradeamount
     */
    /// @inheritdoc I_TTSwap_Market
    function buyGood(
        address _goodid1,
        address _goodid2,
        uint128 _swapQuantity,
        uint128 _tradetimes,
        address _recipent,
        bytes calldata data
    )
        external
        payable
        noReentrant
        msgValue
        returns (uint256 good1change, uint256 good2change)
    {
        if (
            goods[_goodid1].currentState == 0 ||
            goods[_goodid2].currentState == 0 ||
            _swapQuantity == 0 ||
            _goodid1 == _goodid2 ||
            _tradetimes > 199
        ) revert TTSwapError(35);
        if (_tradetimes < 100) {
            if (_recipent != address(0) && _recipent != msg.sender) {
                I_TTSwap_Token(officialTokenContract).addreferral(
                    msg.sender,
                    _recipent
                );
            }

            L_Good.swapCache memory swapcache = L_Good.swapCache({
                remainQuantity: _swapQuantity,
                outputQuantity: 0,
                feeQuantity: 0,
                swapvalue: 0,
                good1currentState: goods[_goodid1].currentState,
                good1config: goods[_goodid1].goodConfig,
                good2currentState: goods[_goodid2].currentState,
                good2config: goods[_goodid2].goodConfig
            });

            L_Good.swapCompute1(swapcache, _tradetimes);
            if (
                (swapcache.remainQuantity + swapcache.feeQuantity) >=
                _swapQuantity ||
                swapcache.swapvalue < 10_000_000
            ) revert TTSwapError(34);

            good1change = toTTSwapUINT256(
                swapcache.feeQuantity,
                _swapQuantity - swapcache.remainQuantity
            );

            good2change = toTTSwapUINT256(
                swapcache.good2config.getBuyFee(swapcache.outputQuantity),
                swapcache.outputQuantity -
                    swapcache.good2config.getBuyFee(swapcache.outputQuantity)
            );

            _goodid1.transferFrom(msg.sender, good1change.amount1(), data);
            goods[_goodid1].swapCommit(
                swapcache.good1currentState,
                swapcache.feeQuantity
            );
            goods[_goodid2].swapCommit(
                swapcache.good2currentState,
                good2change.amount0()
            );

            _goodid2.safeTransfer(msg.sender, good2change.amount1());
            emit e_buyGood(
                _goodid1,
                _goodid2,
                swapcache.swapvalue,
                good1change,
                good2change
            );
        } else {
            if (_recipent == address(0)) revert TTSwapError(35);
            L_Good.swapCache memory swapcache = L_Good.swapCache({
                remainQuantity: _swapQuantity,
                outputQuantity: 0,
                feeQuantity: 0,
                swapvalue: 0,
                good1currentState: goods[_goodid1].currentState,
                good1config: goods[_goodid1].goodConfig,
                good2currentState: goods[_goodid2].currentState,
                good2config: goods[_goodid2].goodConfig
            });
            L_Good.swapCompute2(swapcache, _tradetimes);

            if (
                swapcache.remainQuantity > 0 || swapcache.swapvalue < 10_000_000
            ) revert TTSwapError(33);

            good1change = toTTSwapUINT256(swapcache.feeQuantity, _swapQuantity);
            good2change = toTTSwapUINT256(
                swapcache.good2config.getBuyFee(swapcache.outputQuantity),
                swapcache.outputQuantity +
                    swapcache.good2config.getBuyFee(swapcache.outputQuantity)
            );

            _goodid2.transferFrom(msg.sender, good2change.amount1(), data);

            goods[_goodid1].swapCommit(
                swapcache.good1currentState,
                swapcache.feeQuantity
            );
            goods[_goodid2].swapCommit(
                swapcache.good2currentState,
                good2change.amount0()
            );

            _goodid1.safeTransfer(_recipent, good1change.amount1());
            emit e_buyGood(
                _goodid1,
                _goodid2,
                uint256(swapcache.swapvalue) * 2 ** 128,
                good1change,
                good2change
            );
        }
    }
    /**
     * @dev Check before a good
     * @param _goodid1 The ID of the first good
     * @param _goodid2 The ID of the second good
     * @param _swapQuantity The quantity to swap
     * @param _tradetimes trade times
     * @return good1change amount0() good1tradefee,good1tradeamount
     * @return good2change amount0() good1tradefee,good2tradeamount
     */
    /// @inheritdoc I_TTSwap_Market
    function buyGoodCheck(
        address _goodid1,
        address _goodid2,
        uint128 _swapQuantity,
        uint128 _tradetimes
    ) external view returns (uint256 good1change, uint256 good2change) {
        if (
            goods[_goodid1].currentState == 0 ||
            goods[_goodid2].currentState == 0 ||
            _swapQuantity == 0 ||
            _goodid1 == _goodid2 ||
            _tradetimes > 200
        ) revert TTSwapError(35);
        if (_tradetimes < 100) {
            L_Good.swapCache memory swapcache = L_Good.swapCache({
                remainQuantity: _swapQuantity,
                outputQuantity: 0,
                feeQuantity: 0,
                swapvalue: 0,
                good1currentState: goods[_goodid1].currentState,
                good1config: goods[_goodid1].goodConfig,
                good2currentState: goods[_goodid2].currentState,
                good2config: goods[_goodid2].goodConfig
            });

            L_Good.swapCompute1(swapcache, _tradetimes);

            if (
                (swapcache.remainQuantity + swapcache.feeQuantity) >=
                _swapQuantity
            ) revert TTSwapError(34);

            good1change = toTTSwapUINT256(
                swapcache.feeQuantity,
                _swapQuantity - swapcache.remainQuantity
            );

            good2change = toTTSwapUINT256(
                swapcache.good2config.getBuyFee(swapcache.outputQuantity),
                swapcache.outputQuantity -
                    swapcache.good2config.getBuyFee(swapcache.outputQuantity)
            );
        } else {
            L_Good.swapCache memory swapcache = L_Good.swapCache({
                remainQuantity: _swapQuantity,
                outputQuantity: 0,
                feeQuantity: 0,
                swapvalue: 0,
                good1currentState: goods[_goodid1].currentState,
                good1config: goods[_goodid1].goodConfig,
                good2currentState: goods[_goodid2].currentState,
                good2config: goods[_goodid2].goodConfig
            });
            L_Good.swapCompute2(swapcache, _tradetimes);
            if (swapcache.remainQuantity > 0) revert TTSwapError(33);
            good1change = toTTSwapUINT256(swapcache.feeQuantity, _swapQuantity);
            good2change = toTTSwapUINT256(
                swapcache.good2config.getBuyFee(swapcache.outputQuantity),
                swapcache.outputQuantity +
                    swapcache.good2config.getBuyFee(swapcache.outputQuantity)
            );
        }
    }

    /**
     * @dev Invests in a good
     * @param _togood The ID of the good to invest in
     * @param _valuegood The ID of the value good
     * @param _quantity The quantity to invest
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function investGood(
        address _togood,
        address _valuegood,
        uint128 _quantity,
        bytes calldata data1,
        bytes calldata data2
    ) external payable override noReentrant msgValue returns (bool) {
        L_Good.S_GoodInvestReturn memory normalInvest_;
        L_Good.S_GoodInvestReturn memory valueInvest_;
        if (
            goods[_togood].currentState.amount1() + _quantity >= 2 ** 109 ||
            _togood == _valuegood ||
            !(goods[_togood].goodConfig.isvaluegood() ||
                goods[_valuegood].goodConfig.isvaluegood())
        ) revert TTSwapError(7);

        goods[_togood].investGood(_quantity, normalInvest_);

        _togood.transferFrom(msg.sender, _quantity, data1);
        _mint(msg.sender, _togood.to_uint256(), _quantity);
        if (_valuegood != address(0)) {
            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .currentState
                .getamount1fromamount0(normalInvest_.actualInvestValue);

            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .goodConfig
                .getInvestFullFee(valueInvest_.actualInvestQuantity);

            _valuegood.transferFrom(
                msg.sender,
                valueInvest_.actualInvestQuantity,
                data2
            );
            _mint(
                msg.sender,
                _valuegood.to_uint256(),
                valueInvest_.actualInvestQuantity
            );
            goods[_valuegood].investGood(
                valueInvest_.actualInvestQuantity,
                valueInvest_
            );
        }

        uint256 proofNo = S_ProofKey(msg.sender, _togood, _valuegood).toId();

        proofs[proofNo].updateInvest(
            _togood,
            _valuegood,
            toTTSwapUINT256(normalInvest_.actualInvestValue, 0),
            toTTSwapUINT256(
                normalInvest_.constructFeeQuantity,
                normalInvest_.actualInvestQuantity
            ),
            toTTSwapUINT256(
                valueInvest_.constructFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        uint128 investvalue = _valuegood == address(0)
            ? normalInvest_.actualInvestValue
            : normalInvest_.actualInvestValue * 2;
        uint128 construct = L_Proof.stake(
            officialTokenContract,
            msg.sender,
            investvalue
        );
        emit e_investGood(
            proofNo,
            _togood,
            _valuegood,
            toTTSwapUINT256(normalInvest_.actualInvestValue, construct),
            toTTSwapUINT256(
                normalInvest_.actualFeeQuantity,
                normalInvest_.actualInvestQuantity
            ),
            toTTSwapUINT256(
                valueInvest_.actualFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        return true;
    }

    /**
     * @dev Disinvests a proof
     * @param _proofid The ID of the proof
     * @param _goodQuantity The quantity of the good to disinvest
     * @param _gater The gater address
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function disinvestProof(
        uint256 _proofid,
        uint128 _goodQuantity,
        address _gater
    ) external override noReentrant msgValue returns (uint128, uint128) {
        if (
            S_ProofKey(
                msg.sender,
                proofs[_proofid].currentgood,
                proofs[_proofid].valuegood
            ).toId() != _proofid
        ) {
            revert TTSwapError(8);
        }
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_;
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_;
        address normalgood = proofs[_proofid].currentgood;
        address valuegood = proofs[_proofid].valuegood;

        uint128 divestvalue;
        (address dao_admin, address referal) = I_TTSwap_Token(
            officialTokenContract
        ).getreferralanddaoadmin(msg.sender);
        _gater = userConfig[_gater].isBan() ? dao_admin : _gater;
        referal = _gater == referal ? dao_admin : referal;
        referal = userConfig[referal].isBan() ? dao_admin : referal;
        (disinvestNormalResult1_, disinvestValueResult2_, divestvalue) = goods[
            normalgood
        ].disinvestGood(
                goods[valuegood],
                proofs[_proofid],
                L_Good.S_GoodDisinvestParam(
                    _goodQuantity,
                    _gater,
                    referal,
                    marketconfig,
                    dao_admin
                )
            );

        uint256 tranferamount = goods[normalgood].commission[msg.sender];

        if (tranferamount > 1) {
            goods[normalgood].commission[msg.sender] = 1;
            _burn(msg.sender, normalgood.to_uint256(), tranferamount - 1);
            normalgood.safeTransfer(msg.sender, tranferamount - 1);
        }
        if (valuegood != address(0)) {
            tranferamount = goods[valuegood].commission[msg.sender];
            if (tranferamount > 1) {
                goods[valuegood].commission[msg.sender] = 1;
                _burn(msg.sender, valuegood.to_uint256(), tranferamount - 1);
                valuegood.safeTransfer(msg.sender, tranferamount - 1);
            }
        }
        L_Proof.unstake(officialTokenContract, msg.sender, divestvalue);

        emit e_disinvestProof(
            _proofid,
            normalgood,
            valuegood,
            toTTSwapUINT256(divestvalue, 0),
            toTTSwapUINT256(
                disinvestNormalResult1_.actual_fee,
                disinvestNormalResult1_.actualDisinvestQuantity
            ),
            toTTSwapUINT256(
                disinvestValueResult2_.actual_fee,
                disinvestValueResult2_.actualDisinvestQuantity
            ),
            toTTSwapUINT256(
                disinvestNormalResult1_.profit,
                disinvestValueResult2_.profit
            )
        );
        return (disinvestNormalResult1_.profit, disinvestValueResult2_.profit);
    }

    /// @inheritdoc I_TTSwap_Market
    function ishigher(
        address goodid,
        address valuegood,
        uint256 compareprice
    ) external view override returns (bool) {
        return
            lowerprice(
                goods[goodid].currentState,
                goods[valuegood].currentState,
                compareprice
            );
    }

    function getRecentGoodState(
        address good1,
        address good2
    ) external view returns (uint256, uint256) {
        return (goods[good1].currentState, goods[good2].currentState);
    }

    /// @inheritdoc I_TTSwap_Market
    function getProofState(
        uint256 proofid
    ) external view override returns (S_ProofState memory) {
        return proofs[proofid];
    }

    /// @inheritdoc I_TTSwap_Market
    function getGoodState(
        address goodkey
    ) external view override returns (S_GoodTmpState memory) {
        return
            S_GoodTmpState(
                goods[goodkey].goodConfig,
                goods[goodkey].owner,
                goods[goodkey].currentState,
                goods[goodkey].investState,
                goods[goodkey].feeQuantityState
            );
    }

    /// @inheritdoc I_TTSwap_Market
    function updateGoodConfig(
        address _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        if (msg.sender != goods[_goodid].owner) revert TTSwapError(10);
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updateGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_TTSwap_Market
    function modifyGoodConfig(
        address _goodid,
        uint256 _goodConfig
    ) external override onlyMarketor returns (bool) {
        goods[_goodid].modifyGoodConfig(_goodConfig);
        emit e_modifyGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_TTSwap_Market
    function changeGoodOwner(
        address _goodid,
        address _to
    ) external override onlyMarketor {
        goods[_goodid].owner = _to;
        emit e_changegoodowner(_goodid, _to);
    }
    /// @inheritdoc I_TTSwap_Market

    function collectCommission(
        address[] memory _goodid
    ) external override noReentrant msgValue {
        if (_goodid.length > 100) revert TTSwapError(11);
        uint256[] memory commissionamount = new uint256[](_goodid.length);
        for (uint256 i = 0; i < _goodid.length; i++) {
            commissionamount[i] = goods[_goodid[i]].commission[msg.sender];
            if (commissionamount[i] < 2) {
                commissionamount[i] = 0;
                continue;
            } else {
                commissionamount[i] = commissionamount[i] - 1;
                goods[_goodid[i]].commission[msg.sender] = 1;
                _goodid[i].safeTransfer(msg.sender, commissionamount[i]);
            }
        }
        emit e_collectcommission(_goodid, commissionamount);
    }

    /// @inheritdoc I_TTSwap_Market
    function queryCommission(
        address[] memory _goodid,
        address _recipent
    ) external view override returns (uint256[] memory) {
        if (_goodid.length >= 100) revert TTSwapError(11);
        uint256[] memory feeamount = new uint256[](_goodid.length);
        for (uint256 i = 0; i < _goodid.length; i++) {
            feeamount[i] = goods[_goodid[i]].commission[_recipent];
        }
        return feeamount;
    }

    /// @inheritdoc I_TTSwap_Market
    function goodWelfare(
        address goodid,
        uint128 welfare,
        bytes calldata data
    ) external payable override noReentrant msgValue {
        if (goods[goodid].feeQuantityState.amount0() + welfare >= 2 ** 109) {
            revert TTSwapError(12);
        }
        goodid.transferFrom(msg.sender, welfare, data);
        goods[goodid].feeQuantityState = add(
            goods[goodid].feeQuantityState,
            toTTSwapUINT256(uint128(welfare), 0)
        );
        emit e_goodWelfare(goodid, welfare);
    }

    /// @inheritdoc I_TTSwap_Market
    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyDAOadmin returns (bool) {
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    /// @inheritdoc IERC3156FlashLender
    function maxFlashLoan(address good) public view override returns (uint256) {
        return good.balanceof(address(this));
    }

    /// @inheritdoc IERC3156FlashLender
    function flashFee(
        address token,
        uint256 amount
    ) public view override returns (uint256) {
        return goods[token].goodConfig.getFlashFee(amount);
    }

    /// @inheritdoc IERC3156FlashLender
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) public override noReentrant returns (bool) {
        if (token.isNative()) revert TTSwapError(29);
        uint256 maxLoan = maxFlashLoan(token);
        maxLoan = maxLoan / 2;
        if (amount > maxLoan) {
            revert ERC3156ExceededMaxLoan(maxLoan);
        }
        uint256 fee = flashFee(token, amount);
        token.safeTransfer(address(receiver), amount);
        if (
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) !=
            RETURN_VALUE
        ) {
            revert ERC3156InvalidReceiver(address(receiver));
        }
        token.transferFrom(
            address(receiver),
            address(this),
            uint128(amount + fee)
        );
        goods[token].fillFee(fee);
        return true;
    }

    /// For protect user asset when bug happen
    function securityKeeper(address token) external msgValue {
        require(msg.sender == securitykeeper);
        uint256 amount = token.balanceof(address(this));
        goods[token].feeQuantityState = 0;
        goods[token].currentState = 0;
        token.safeTransfer(securitykeeper, amount);
    }
    /// will be remove when contract excute for one year

    function removeSecurityKeeper() external onlyDAOadmin {
        securitykeeper = address(0);
    }
    function stakeETH(address token, uint128 amount) external override {
        if (goods[token].owner != msg.sender || !token.canRestake())
            revert TTSwapError(36);
        if (token.isNative()) {
            restakingamount = add(restakingamount, toTTSwapUINT256(0, amount));
            restakeContract.stakeEth{value: amount}(token, amount);
        } else {
            restakingamount = add(restakingamount, toTTSwapUINT256(amount, 0));
            token.approve(address(restakeContract), amount);
            restakeContract.stakeEth(token, amount);
        }
    }

    function unstakeETH(address token, uint128 amount) external override {
        if (goods[token].owner != msg.sender || !token.canRestake())
            revert TTSwapError(36);
        uint128 fee = restakeContract.unstakeEthSome(token, amount);
        if (token.isNative()) {
            restakingamount = sub(restakingamount, toTTSwapUINT256(0, amount));
        } else {
            restakingamount = sub(restakingamount, toTTSwapUINT256(amount, 0));
        }
        goods[token].feeQuantityState = sub(
            goods[token].feeQuantityState,
            toTTSwapUINT256(fee, 0)
        );
    }
    function syncReward(address token) external override {
        uint128 fee = restakeContract.syncReward(token);
        goods[token].feeQuantityState = sub(
            goods[token].feeQuantityState,
            toTTSwapUINT256(fee, 0)
        );
    }

    function changeReStakingContrat(
        address _target
    ) external override onlyDAOadmin {
        restakeContract = I_TTSwap_StakeETH(_target);
    }

    receive() external payable {}
}
