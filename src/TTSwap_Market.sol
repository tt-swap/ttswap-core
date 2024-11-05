// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_TTSwap_Market, S_ProofState, S_GoodState, S_ProofKey, S_GoodKey, S_GoodTmpState} from "./interfaces/I_TTSwap_Market.sol";
import {I_TTSwap_LimitOrderTaker, S_takeGoodInputPrams} from "./interfaces/I_TTSwap_LimitOrderTaker.sol";
import {L_Good, L_GoodIdLibrary} from "./libraries/L_Good.sol";
import {L_TakeLimitPriceOrder} from "./libraries/L_TakeLimitPriceOrder.sol";
import {L_Lock} from "./libraries/L_Lock.sol";
import {L_Proof, L_ProofIdLibrary, L_ProofKeyLibrary} from "./libraries/L_Proof.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {I_TTSwap_Token} from "./interfaces/I_TTSwap_Token.sol";
import {I_TTSwap_NFT} from "./interfaces/I_TTSwap_NFT.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, add, sub, addsub, subadd, lowerprice, toInt128} from "./libraries/L_TTSwapUINT256.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

/**
 * @title TTSwap_Market
 * @dev Manages the market operations for goods and proofs.
 * @notice This contract handles initialization, buying, selling, investing, and disinvesting of goods and proofs.
 */
contract TTSwap_Market is
    I_TTSwap_Market,
    I_TTSwap_LimitOrderTaker,
    IERC3156FlashLender
{
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofKeyLibrary for S_ProofKey;
    using L_ProofIdLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_Good for S_GoodState;
    using L_Proof for S_ProofState;
    using L_CurrencyLibrary for address;
    using L_MarketConfigLibrary for uint256;
    using L_TakeLimitPriceOrder for L_TakeLimitPriceOrder.S_takeGoodCache;
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

    bytes32 private constant RETURN_VALUE =
        keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 public override marketconfig;

    mapping(address goodid => S_GoodState) internal goods;
    mapping(uint256 proofkey => uint256 proofid) public proofmapping;
    mapping(uint256 proofid => S_ProofState) internal proofs;
    mapping(address => uint256) public banlist;
    mapping(address => mapping(address => uint256)) public loanproofs;
    mapping(address => uint256) auths;
    address public marketcreator;

    address internal immutable officialTokenContract;
    address internal immutable officialNFTContract;
    address internal immutable officelimitorder;

    /**
     * @dev Constructor for TTSwap_Market
     * @param _marketconfig The market configuration
     * @param _officialTokenContract The address of the official contract
     */
    constructor(
        uint256 _marketconfig,
        address _officialTokenContract,
        address _officialNFTContract,
        address _officelimitorder,
        address _marketcreator
    ) {
        officialTokenContract = _officialTokenContract;
        officialNFTContract = _officialNFTContract;
        marketconfig = _marketconfig;
        officelimitorder = _officelimitorder;
        marketcreator = _marketcreator;
    }

    modifier onlyDAOadmin() {
        require(marketcreator == msg.sender);
        _;
    }
    modifier onlyMarketor() {
        require(auths[msg.sender] == 1);
        _;
    }
    function changemarketor(address _newmarketor) external {
        require(msg.sender == marketcreator);
        marketcreator = _newmarketor;
    }

    function addauths(address _newmarketor, uint256 _auths) external {
        require(msg.sender == marketcreator);
        auths[_newmarketor] = _auths;
    }

    function removeauths(address _newmarketor) external {
        require(msg.sender == marketcreator);
        delete auths[_newmarketor];
    }
    modifier noReentrant() {
        require(L_Lock.get() == address(0));
        L_Lock.set(msg.sender);
        _;
        L_Lock.set(address(0));
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
        uint256 _goodConfig
    ) external payable override onlyDAOadmin returns (bool) {
        require(_goodConfig.isvaluegood());
        _erc20address.transferFrom(msg.sender, _initial.amount1());
        goods[_erc20address].init(_initial, _goodConfig);
        goods[_erc20address].modifyGoodConfig(4294967296); //2**32

        uint256 proofKey = S_ProofKey(msg.sender, _erc20address, address(0))
            .toKey();

        uint256 proofid = proofKey.toId();
        proofmapping[proofKey] = proofid;
        I_TTSwap_NFT(officialNFTContract).mint(msg.sender, proofid);
        proofs[proofid].updateInvest(
            _erc20address,
            address(0),
            toTTSwapUINT256(_initial.amount0(), 0),
            _initial.amount1(),
            0
        );
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
     * @param _initial The initial balance
     * @param _erc20address The address of the ERC20 token
     * @param _goodConfig The good configuration
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function initGood(
        address _valuegood,
        uint256 _initial,
        address _erc20address,
        uint256 _goodConfig
    ) external payable override noReentrant returns (bool) {
        require(
            goods[_erc20address].owner == address(0) &&
                goods[_valuegood].goodConfig.isvaluegood()
        );
        _erc20address.transferFrom(msg.sender, _initial.amount0());
        _valuegood.transferFrom(msg.sender, _initial.amount1());
        L_Good.S_GoodInvestReturn memory investResult;
        goods[_valuegood].investGood(_initial.amount1(), investResult);
        goods[_erc20address].init(
            toTTSwapUINT256(investResult.actualInvestValue, _initial.amount0()),
            _goodConfig
        );

        uint256 proofKey = S_ProofKey(msg.sender, _erc20address, _valuegood)
            .toKey();
        //   uint256 proofid = proofKey.toId();
        proofmapping[proofKey] = proofKey.toId();
        I_TTSwap_NFT(officialNFTContract).mint(
            msg.sender,
            proofmapping[proofKey]
        );
        proofs[proofmapping[proofKey]] = S_ProofState(
            _erc20address,
            _valuegood,
            toTTSwapUINT256(investResult.actualInvestValue, 0),
            _initial.amount0(),
            toTTSwapUINT256(
                investResult.constructFeeQuantity,
                investResult.actualInvestQuantity
            )
        );

        emit e_initGood(
            proofmapping[proofKey],
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
     * @param _limitPrice The limit price
     * @param _istotal Whether it's a total swap
     * @param _referal The referral address
     * @return goodid2Quantity_ The quantity of the second good received
     * @return goodid2FeeQuantity_ The fee quantity for the second good
     */
    /// @inheritdoc I_TTSwap_Market
    function buyGood(
        address _goodid1,
        address _goodid2,
        uint128 _swapQuantity,
        uint256 _limitPrice,
        bool _istotal,
        address _referal
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_)
    {
        if (_referal != address(0))
            I_TTSwap_Token(officialTokenContract).addreferral(
                msg.sender,
                _referal
            );
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
        L_Good.swapCompute1(swapcache, _limitPrice);
        require(
            _swapQuantity > 0 &&
                swapcache.remainQuantity != _swapQuantity &&
                _goodid1 != _goodid2 &&
                !(_istotal == true && swapcache.remainQuantity > 0)
        );

        goodid2FeeQuantity_ = swapcache.good2config.getBuyFee(
            swapcache.outputQuantity
        );
        goodid2Quantity_ = swapcache.outputQuantity - goodid2FeeQuantity_;
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            swapcache.feeQuantity
        );
        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            goodid2FeeQuantity_
        );
        _goodid1.transferFrom(
            msg.sender,
            _swapQuantity - swapcache.remainQuantity
        );

        _goodid2.safeTransfer(msg.sender, goodid2Quantity_);

        emit e_buyGood(
            _goodid1,
            _goodid2,
            msg.sender,
            swapcache.swapvalue,
            toTTSwapUINT256(
                _swapQuantity - swapcache.remainQuantity,
                swapcache.feeQuantity
            ),
            toTTSwapUINT256(goodid2Quantity_, goodid2FeeQuantity_)
        );
    }

    function takeLimitOrder(
        bytes calldata _inputData,
        uint96 _tolerance,
        address _takecaller
    ) public payable override noReentrant returns (bool _isSuccess) {
        S_takeGoodInputPrams memory _inputParams = abi.decode(
            _inputData,
            (S_takeGoodInputPrams)
        );
        L_TakeLimitPriceOrder.S_takeGoodCache memory takeCache;
        takeCache.init_takeGoodCache(
            _inputParams,
            goods[_inputParams._goodid1].currentState,
            goods[_inputParams._goodid1].goodConfig,
            goods[_inputParams._goodid2].currentState,
            goods[_inputParams._goodid2].goodConfig,
            _tolerance
        );
        takeCache.takeGoodCompute();
        require(
            msg.sender == officelimitorder &&
                _inputParams._swapQuantity.amount0() > 0 &&
                takeCache.remainQuantity == 0 &&
                _inputParams._goodid1 != _inputParams._goodid2
        );

        if (takeCache.goodid2Quantity_ <= _inputParams._swapQuantity.amount1())
            revert noEnoughOutputError();

        _inputParams._goodid2.safeTransfer(
            _inputParams._orderowner,
            _inputParams._swapQuantity.amount1()
        );
        uint128 profit = takeCache.goodid2Quantity_ -
            _inputParams._swapQuantity.amount1();
        _inputParams._goodid2.safeTransfer(_takecaller, profit / 2);
        takeCache.goodid2FeeQuantity_ =
            takeCache.goodid2FeeQuantity_ +
            profit /
            2;
        goods[_inputParams._goodid1].swapCommit(
            takeCache.good1currentState,
            takeCache.feeQuantity
        );
        goods[_inputParams._goodid2].swapCommit(
            takeCache.good2currentState,
            takeCache.goodid2FeeQuantity_
        );
        emit e_buyGood(
            _inputParams._goodid1,
            _inputParams._goodid2,
            _inputParams._orderowner,
            takeCache.swapvalue,
            toTTSwapUINT256(
                _inputParams._swapQuantity.amount0(),
                takeCache.feeQuantity
            ),
            toTTSwapUINT256(
                takeCache.goodid2Quantity_,
                takeCache.goodid2FeeQuantity_
            )
        );
        return true;
    }

    function batchTakelimitOrder(
        bytes[] calldata _inputData,
        uint96 _tolerance,
        address _takecaller
    ) external payable returns (bool[] memory result) {
        for (uint256 i = 0; i < _inputData.length; i++) {
            result[i] = takeLimitOrder(_inputData[i], _tolerance, _takecaller);
        }
    }
    /**
     * @dev Buys a good for pay
     * @param _goodid1 The ID of the first good
     * @param _goodid2 The ID of the second good
     * @param _swapQuantity The quantity to swap
     * @param _limitPrice The limit price
     * @param _recipient The recipient address
     * @return goodid1Quantity_ The quantity of the first good received
     * @return goodid1FeeQuantity_ The fee quantity for the first good
     */
    /// @inheritdoc I_TTSwap_Market
    function buyGoodForPay(
        address _goodid1,
        address _goodid2,
        uint128 _swapQuantity,
        uint256 _limitPrice,
        address _recipient
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_)
    {
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
        L_Good.swapCompute2(swapcache, _limitPrice);
        require(
            _swapQuantity >= 0 &&
                _goodid1 != _goodid2 &&
                swapcache.remainQuantity == 0
        );

        goodid1FeeQuantity_ = swapcache.good1config.getSellFee(
            swapcache.outputQuantity
        );
        goodid1Quantity_ = swapcache.outputQuantity + goodid1FeeQuantity_;

        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            swapcache.feeQuantity
        );
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            goodid1FeeQuantity_
        );
        _goodid2.safeTransfer(
            _recipient,
            _swapQuantity - swapcache.feeQuantity
        );
        _goodid1.transferFrom(msg.sender, goodid1Quantity_);
        emit e_buyGoodForPay(
            _goodid1,
            _goodid2,
            msg.sender,
            _recipient,
            swapcache.swapvalue,
            toTTSwapUINT256(_swapQuantity, swapcache.feeQuantity),
            toTTSwapUINT256(goodid1Quantity_, goodid1FeeQuantity_)
        );
    }
    event debuggg(bool, bool);
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
        uint128 _quantity
    ) external payable override noReentrant returns (bool) {
        L_Good.S_GoodInvestReturn memory normalInvest_;
        L_Good.S_GoodInvestReturn memory valueInvest_;
        emit debuggg(
            goods[_togood].goodConfig.isvaluegood(),
            goods[_valuegood].goodConfig.isvaluegood()
        );
        require(
            goods[_togood].currentState.amount1() + _quantity <= 2 ** 109 &&
                _togood != _valuegood &&
                (goods[_togood].goodConfig.isvaluegood() ||
                    goods[_valuegood].goodConfig.isvaluegood())
        );
        goods[_togood].investGood(_quantity, normalInvest_);
        _togood.transferFrom(msg.sender, _quantity);
        if (_valuegood != address(0)) {
            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .currentState
                .getamount1fromamount0(normalInvest_.actualInvestValue);

            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .goodConfig
                .getInvestFullFee(valueInvest_.actualInvestQuantity);

            _valuegood.transferFrom(
                msg.sender,
                valueInvest_.actualInvestQuantity
            );
            goods[_valuegood].investGood(
                valueInvest_.actualInvestQuantity,
                valueInvest_
            );
        }

        uint256 proofKey = S_ProofKey(msg.sender, _togood, _valuegood).toKey();
        uint256 proofNo = proofmapping[proofKey];

        if (proofNo == 0) {
            proofNo = proofKey.toId();
            I_TTSwap_NFT(officialNFTContract).mint(msg.sender, proofNo);
            proofmapping[proofKey] = proofNo;
        }
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
    ) public override noReentrant returns (bool) {
        require(
            I_TTSwap_NFT(officialNFTContract).isApprovedOrOwner(
                msg.sender,
                _proofid
            )
        );
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_;
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_;
        address normalgood = proofs[_proofid].currentgood;
        address valuegood = proofs[_proofid].valuegood;

        uint128 divestvalue;
        (address dao_admin, address referal) = I_TTSwap_Token(
            officialTokenContract
        ).getreferralanddaoadmin(msg.sender);
        _gater = banlist[_gater] == 1 ? _gater : dao_admin;
        referal = _gater == referal ? dao_admin : referal;
        referal = banlist[referal] == 1 ? referal : dao_admin;
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
            normalgood.safeTransfer(msg.sender, tranferamount - 1);
        }
        if (valuegood != address(0)) {
            tranferamount = goods[valuegood].commission[msg.sender];
            if (tranferamount > 1) {
                goods[valuegood].commission[msg.sender] = 1;
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
        return true;
    }

    /**
     * @dev Collects the fee of a proof
     * @param _proofid The ID of the proof
     * @param _gater The gater address
     * @return profit_ The collected profit
     */
    /// @inheritdoc I_TTSwap_Market
    function collectProof(
        uint256 _proofid,
        address _gater
    ) external override noReentrant returns (uint256 profit_) {
        require(
            I_TTSwap_NFT(officialNFTContract).isApprovedOrOwner(
                msg.sender,
                _proofid
            )
        );
        address valuegood = proofs[_proofid].valuegood;
        address currentgood = proofs[_proofid].currentgood;
        (address dao_admin, address referal) = I_TTSwap_Token(
            officialTokenContract
        ).getreferralanddaoadmin(msg.sender);
        _gater = banlist[_gater] == 1 ? dao_admin : _gater;
        referal = _gater == referal ? dao_admin : referal;
        referal = banlist[referal] == 1 ? referal : dao_admin;
        profit_ = goods[currentgood].collectGoodFee(
            goods[valuegood],
            proofs[_proofid],
            _gater,
            referal,
            marketconfig,
            dao_admin
        );
        uint256 tranferamount = goods[currentgood].commission[msg.sender];

        if (tranferamount > 1) {
            goods[currentgood].commission[msg.sender] = 1;
            currentgood.safeTransfer(msg.sender, tranferamount - 1);
        }
        if (valuegood != address(0)) {
            tranferamount = goods[valuegood].commission[msg.sender];
            if (tranferamount > 1) {
                goods[valuegood].commission[msg.sender] = 1;
                valuegood.safeTransfer(msg.sender, tranferamount - 1);
            }
        }
        emit e_collectProof(_proofid, currentgood, valuegood, profit_);
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
        require(msg.sender == goods[_goodid].owner);
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
    function payGood(
        address _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable override returns (bool) {
        if (_goodid == address(1)) {
            _goodid.safeTransfer(_recipent, _payquanity);
        } else {
            _goodid.transferFrom(msg.sender, _recipent, _payquanity);
        }
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
    function collectCommission(address[] memory _goodid) external override {
        require(_goodid.length < 100);
        uint256[] memory commissionamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
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
        require(_goodid.length < 100);
        uint256[] memory feeamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
            feeamount[i] = goods[_goodid[i]].commission[_recipent];
        }
        return feeamount;
    }

    /// @inheritdoc I_TTSwap_Market
    function goodWelfare(
        address goodid,
        uint128 welfare
    ) external payable override noReentrant {
        require(goods[goodid].feeQuantityState.amount0() + welfare <= 2 ** 109);
        goodid.transferFrom(msg.sender, welfare);
        goods[goodid].feeQuantityState = add(
            goods[goodid].feeQuantityState,
            toTTSwapUINT256(uint128(welfare), 0)
        );
        emit e_goodWelfare(goodid, welfare);
    }

    /// @inheritdoc I_TTSwap_Market
    function addbanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 1;
        emit e_addbanlist(_user);
        return true;
    }

    /// @inheritdoc I_TTSwap_Market
    function removebanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 0;
        emit e_removebanlist(_user);
        return true;
    }

    /// @inheritdoc I_TTSwap_Market
    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyDAOadmin returns (bool) {
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    /**
     * @dev Internal function to handle proof data deletion and updates during transfer.
     * @param proofid The ID of the proof being transferred.
     * @param from The address transferring the proof.
     * @param to The address receiving the proof.
     */
    /// @inheritdoc I_TTSwap_Market
    function delproofdata(
        uint256 proofid,
        address from,
        address to
    ) external override {
        require(msg.sender == officialNFTContract);
        L_Proof.unstake(
            officialTokenContract,
            from,
            proofs[proofid].state.amount0()
        );
        S_ProofState memory proofState = proofs[proofid];
        uint256 proofKey1 = S_ProofKey(
            from,
            proofState.currentgood,
            proofState.valuegood
        ).toKey();
        uint256 proofKey2 = S_ProofKey(
            to,
            proofState.currentgood,
            proofState.valuegood
        ).toKey();
        L_Proof.stake(officialTokenContract, to, proofState.state.amount0());
        uint256 existingProofId = proofmapping[proofKey2];
        if (existingProofId == 0) {
            proofmapping[proofKey2] = proofmapping[proofKey1];
        } else {
            proofs[existingProofId].conbine(proofs[proofid]);
            delete proofs[proofid];
            I_TTSwap_NFT(officialNFTContract).burn(proofid);
            emit e_transferdel(proofid, existingProofId);
        }
        delete proofmapping[proofKey1];
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
    ) external override returns (bool) {
        uint256 maxLoan = maxFlashLoan(token);
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
        token.transferFrom(address(receiver), address(this), amount + fee);
        goods[token].fillFee(fee);
        return true;
    }
}
