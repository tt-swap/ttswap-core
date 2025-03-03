// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

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

/**
 * @title TTSwap_Market
 * @dev Manages the market operations for goods and proofs.
 * @notice This contract handles initialization, buying, selling, investing, and disinvesting of goods and proofs.
 */
contract TTSwap_Market is I_TTSwap_Market, IERC3156FlashLender, IMulticall_v4 {
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

    /// @notice recording the config of commision allocate
    uint256 public override marketconfig;
    /// @notice the deploy of contract
    address public marketcreator;
    /// @notice when  invest, customer can mint tts token
    address private immutable officialTokenContract;
    /// @notice the address will be change to address0 when contract is safe
    address private securitykeeper;

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

    /// @inheritdoc I_TTSwap_Market
    function setMarketor(address _newmarketor) external override onlyDAOadmin {
        userConfig[_newmarketor] = userConfig[_newmarketor] | 2;
        emit e_modifiedUserConfig(_newmarketor, userConfig[_newmarketor]);
    }

    /// @inheritdoc I_TTSwap_Market
    function removeMarketor(address _user) external override onlyDAOadmin {
        userConfig[_user] = userConfig[_user] & ~uint256(2);
        emit e_modifiedUserConfig(_user, userConfig[_user]);
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
        if (!_goodConfig.isvaluegood()) revert TTSwapError(4);
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
        ) revert TTSwapError(5);
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
        address _referal,
        bytes calldata data
    )
        external
        payable
        noReentrant
        msgValue
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

        if (
            _swapQuantity == 0 ||
            (swapcache.remainQuantity + swapcache.feeQuantity) >=
            _swapQuantity ||
            _goodid1 == _goodid2 ||
            (_istotal == true && swapcache.remainQuantity > 0)
        ) revert TTSwapError(6);

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
            _swapQuantity - swapcache.remainQuantity,
            data
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
    ) public payable override noReentrant msgValue returns (bool) {
        if (
            S_ProofKey(
                msg.sender,
                proofs[_proofid].currentgood,
                proofs[_proofid].valuegood
            ).toId() != _proofid
        ) revert TTSwapError(8);
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_;
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_;
        address normalgood = proofs[_proofid].currentgood;
        address valuegood = proofs[_proofid].valuegood;

        uint128 divestvalue;
        (address dao_admin, address referal) = I_TTSwap_Token(
            officialTokenContract
        ).getreferralanddaoadmin(msg.sender);
        _gater = userConfig[_gater].isBan() ? _gater : dao_admin;
        referal = _gater == referal ? dao_admin : referal;
        referal = userConfig[referal].isBan() ? referal : dao_admin;
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
    ) external payable override noReentrant msgValue returns (uint256 profit_) {
        if (
            S_ProofKey(
                msg.sender,
                proofs[_proofid].currentgood,
                proofs[_proofid].valuegood
            ).toId() != _proofid
        ) revert TTSwapError(9);
        address valuegood = proofs[_proofid].valuegood;
        address currentgood = proofs[_proofid].currentgood;
        (address dao_admin, address referal) = I_TTSwap_Token(
            officialTokenContract
        ).getreferralanddaoadmin(msg.sender);
        _gater = userConfig[_gater].isBan() ? dao_admin : _gater;
        referal = _gater == referal ? dao_admin : referal;
        referal = userConfig[referal].isBan() ? referal : dao_admin;
        profit_ = goods[currentgood].collectGoodFee(
            goods[valuegood],
            proofs[_proofid],
            _gater,
            referal,
            marketconfig,
            dao_admin
        );
        uint256 tranferamount = goods[currentgood].commission[msg.sender];

        if (tranferamount > 2) {
            goods[currentgood].commission[msg.sender] = 1;
            currentgood.safeTransfer(msg.sender, tranferamount - 1);
        }
        if (valuegood != address(0)) {
            tranferamount = goods[valuegood].commission[msg.sender];
            if (tranferamount > 2) {
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
    ) external payable override noReentrant msgValue {
        if (_goodid.length > 100) revert TTSwapError(11);
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
        if (_goodid.length >= 100) revert TTSwapError(11);
        uint256[] memory feeamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
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
        if (goods[goodid].feeQuantityState.amount0() + welfare >= 2 ** 109)
            revert TTSwapError(12);
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
    ) public override returns (bool) {
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
    function securityKeeper(address token) external payable msgValue {
        require(msg.sender == securitykeeper);
        uint256 amount = goods[token].feeQuantityState.amount0() -
            goods[token].feeQuantityState.amount1();
        goods[token].feeQuantityState = 0;
        amount += goods[token].currentState.amount1();
        goods[token].currentState = 0;
        token.safeTransfer(securitykeeper, amount);
    }
    /// will be remove when contract excute for one year
    function removeSecurityKeeper() external {
        if (msg.sender != marketcreator) revert TTSwapError(14);
        securitykeeper = address(0);
    }
}
