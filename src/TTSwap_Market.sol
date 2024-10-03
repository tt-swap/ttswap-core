// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_TTSwap_Market, S_ProofState, S_GoodState, S_ProofKey, S_GoodKey, S_GoodTmpState} from "./interfaces/I_TTSwap_Market.sol";
import {L_Good, L_GoodIdLibrary} from "./libraries/L_Good.sol";
import {L_Lock} from "./libraries/L_Lock.sol";
import {L_Proof, L_ProofIdLibrary, L_ProofKeyLibrary} from "./libraries/L_Proof.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {I_TTSwap_Token} from "./interfaces/I_TTSwap_Token.sol";
import {I_TTSwap_NFT} from "./interfaces/I_TTSwap_NFT.sol";
import {I_TTSwap_MainTrigger} from "./interfaces/I_TTSwap_MainTrigger.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, add, sub, addsub, subadd, lowerprice, toInt128} from "./libraries/L_TTSwapUINT256.sol";

/**
 * @title TTSwap_Market
 * @dev Manages the market operations for goods and proofs.
 * @notice This contract handles initialization, buying, selling, investing, and disinvesting of goods and proofs.
 */
contract TTSwap_Market is I_TTSwap_Market {
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofKeyLibrary for S_ProofKey;
    using L_ProofIdLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_Good for S_GoodState;
    using L_Proof for S_ProofState;
    using L_CurrencyLibrary for address;
    using L_MarketConfigLibrary for uint256;

    uint256 public override marketconfig;

    mapping(uint256 goodid => S_GoodState) internal goods;
    mapping(uint256 proofkey => uint256 proofid) public proofmapping;
    mapping(uint256 proofid => S_ProofState) internal proofs;
    mapping(address => uint256) public banlist;

    address internal immutable officialTokenContract;
    address internal immutable officialNFTContract;
    address internal immutable officialTrigger;

    /**
     * @dev Constructor for TTSwap_Market
     * @param _marketconfig The market configuration
     * @param _officialTokenContract The address of the official contract
     */
    constructor(
        uint256 _marketconfig,
        address _officialTokenContract,
        address _officialNFTContract,
        address _officialTrigger
    ) {
        officialTokenContract = _officialTokenContract;
        officialNFTContract = _officialNFTContract;
        marketconfig = _marketconfig;
        officialTrigger = _officialTrigger;
    }
    modifier onlyDAOadmin() {
        require(
            I_TTSwap_Token(officialTokenContract).dao_admin() == msg.sender
        );
        _;
    }
    modifier onlyMarketor() {
        require(I_TTSwap_Token(officialTokenContract).auths(msg.sender) == 3);
        _;
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
        uint256 togood = S_GoodKey(msg.sender, _erc20address).toId();
        goods[togood].init(_initial, _erc20address, _goodConfig);
        goods[togood].modifyGoodConfig(4294967296); //2**32

        uint256 proofKey = S_ProofKey(msg.sender, togood, 0).toKey();

        uint256 proofid = proofKey.toId();
        proofmapping[proofKey] = proofid;
        I_TTSwap_NFT(officialNFTContract).mint(msg.sender, proofid);
        proofs[proofid].updateInvest(
            togood,
            0,
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
            togood,
            construct,
            _erc20address,
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
        uint256 _valuegood,
        uint256 _initial,
        address _erc20address,
        uint256 _goodConfig
    ) external payable override noReentrant returns (bool) {
        uint256 togood = S_GoodKey(msg.sender, _erc20address).toId();
        require(
            goods[togood].owner == address(0) &&
                goods[_valuegood].goodConfig.isvaluegood()
        );
        _erc20address.transferFrom(msg.sender, _initial.amount0());
        goods[_valuegood].erc20address.transferFrom(
            msg.sender,
            _initial.amount1()
        );
        L_Good.S_GoodInvestReturn memory investResult = goods[_valuegood]
            .investGood(_initial.amount1());
        goods[togood].init(
            toTTSwapUINT256(investResult.actualInvestValue, _initial.amount0()),
            _erc20address,
            _goodConfig
        );

        uint256 proofKey = S_ProofKey(msg.sender, togood, _valuegood).toKey();
        //   uint256 proofid = proofKey.toId();
        proofmapping[proofKey] = proofKey.toId();
        I_TTSwap_NFT(officialNFTContract).mint(
            msg.sender,
            proofmapping[proofKey]
        );
        proofs[proofmapping[proofKey]] = S_ProofState(
            togood,
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
            togood,
            _valuegood,
            _erc20address,
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
        uint256 _goodid1,
        uint256 _goodid2,
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
        goods[_goodid1].swaptake(
            officialTrigger,
            _goodid2,
            _swapQuantity,
            goods[_goodid2].currentState,
            msg.sender
        );
        goods[_goodid2].swapmake(
            officialTrigger,
            _goodid1,
            _swapQuantity,
            goods[_goodid1].currentState,
            msg.sender
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
        swapcache = L_Good.swapCompute1(swapcache, _limitPrice);

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
        goods[_goodid1].erc20address.transferFrom(
            msg.sender,
            _swapQuantity - swapcache.remainQuantity
        );

        goods[_goodid2].erc20address.safeTransfer(msg.sender, goodid2Quantity_);

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
        uint256 _goodid1,
        uint256 _goodid2,
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
        goods[_goodid1].swaptake(
            officialTrigger,
            _goodid2,
            _swapQuantity,
            goods[_goodid2].currentState,
            msg.sender
        );
        goods[_goodid2].swapmake(
            officialTrigger,
            _goodid1,
            _swapQuantity,
            goods[_goodid1].currentState,
            msg.sender
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

        swapcache = L_Good.swapCompute2(swapcache, _limitPrice);

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
        goods[_goodid2].erc20address.safeTransfer(
            _recipient,
            _swapQuantity - swapcache.feeQuantity
        );
        goods[_goodid1].erc20address.transferFrom(msg.sender, goodid1Quantity_);
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

    /**
     * @dev Invests in a good
     * @param _togood The ID of the good to invest in
     * @param _valuegood The ID of the value good
     * @param _quantity The quantity to invest
     * @return bool Returns true if successful
     */
    /// @inheritdoc I_TTSwap_Market
    function investGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quantity
    ) external payable override noReentrant returns (bool) {
        goods[_togood].invest(officialTrigger, _quantity, msg.sender);
        L_Good.S_GoodInvestReturn memory normalInvest_;
        L_Good.S_GoodInvestReturn memory valueInvest_;
        require(
            goods[_togood].currentState.amount1() + _quantity <= 2 ** 109 &&
                _togood != _valuegood &&
                (goods[_togood].goodConfig.isvaluegood() ||
                    goods[_valuegood].goodConfig.isvaluegood())
        );
        normalInvest_ = goods[_togood].investGood(_quantity);
        goods[_togood].erc20address.transferFrom(msg.sender, _quantity);
        if (_valuegood != 0) {
            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .currentState
                .getamount1fromamount0(normalInvest_.actualInvestValue);

            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .goodConfig
                .getInvestFullFee(valueInvest_.actualInvestQuantity);
            goods[_valuegood].invest(
                officialTrigger,
                valueInvest_.actualInvestQuantity,
                msg.sender
            );
            goods[_valuegood].erc20address.transferFrom(
                msg.sender,
                valueInvest_.actualInvestQuantity
            );
            valueInvest_ = goods[_valuegood].investGood(
                valueInvest_.actualInvestQuantity
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
        uint128 investvalue = _valuegood == 0
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
        uint256 normalgood = proofs[_proofid].currentgood;
        uint256 valuegood = proofs[_proofid].valuegood;

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
        goods[normalgood].divest(
            officialTokenContract,
            disinvestNormalResult1_.actualDisinvestQuantity,
            msg.sender
        );

        if (valuegood != 0) {
            divestvalue = divestvalue * 2;
            goods[valuegood].divest(
                officialTokenContract,
                disinvestNormalResult1_.actualDisinvestQuantity,
                msg.sender
            );
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
        uint256 valuegood = proofs[_proofid].valuegood;
        uint256 currentgood = proofs[_proofid].currentgood;
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
        emit e_collectProof(_proofid, currentgood, valuegood, profit_);
    }

    function ishigher(
        uint256 goodid,
        uint256 valuegood,
        uint256 compareprice
    ) external view override returns (bool) {
        return
            lowerprice(
                goods[goodid].currentState,
                goods[valuegood].currentState,
                compareprice
            );
    }

    function getProofState(
        uint256 proofid
    ) external view override returns (S_ProofState memory) {
        return proofs[proofid];
    }

    function getGoodState(
        uint256 goodkey
    ) external view override returns (S_GoodTmpState memory) {
        return
            S_GoodTmpState(
                goods[goodkey].goodConfig,
                goods[goodkey].owner,
                goods[goodkey].erc20address,
                goods[goodkey].trigger,
                goods[goodkey].currentState,
                goods[goodkey].investState,
                goods[goodkey].feeQuantityState
            );
    }

    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner);
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updateGoodConfig(_goodid, _goodConfig);
        return true;
    }

    function modifyGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override onlyMarketor returns (bool) {
        goods[_goodid].modifyGoodConfig(_goodConfig);
        emit e_modifyGoodConfig(_goodid, _goodConfig);
        return true;
    }

    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable override returns (bool) {
        if (goods[_goodid].erc20address == address(0)) {
            goods[_goodid].erc20address.safeTransfer(_recipent, _payquanity);
        } else {
            goods[_goodid].erc20address.transferFrom(
                msg.sender,
                _recipent,
                _payquanity
            );
        }
        return true;
    }
    function changeGoodOwner(
        uint256 _goodid,
        address _to
    ) external override onlyMarketor {
        goods[_goodid].owner = _to;
        emit e_changegoodowner(_goodid, _to);
    }
    function collectCommission(uint256[] memory _goodid) external override {
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
                goods[_goodid[i]].erc20address.safeTransfer(
                    msg.sender,
                    commissionamount[i]
                );
            }
        }
        emit e_collectcommission(_goodid, commissionamount);
    }

    function queryCommission(
        uint256[] memory _goodid,
        address _recipent
    ) external view override returns (uint256[] memory) {
        require(_goodid.length < 100);
        uint256[] memory feeamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
            feeamount[i] = goods[_goodid[i]].commission[_recipent];
        }
        return feeamount;
    }

    function goodWelfare(
        uint256 goodid,
        uint128 welfare
    ) external payable override noReentrant {
        require(goods[goodid].feeQuantityState.amount0() + welfare <= 2 ** 109);
        goods[goodid].erc20address.transferFrom(msg.sender, welfare);
        goods[goodid].feeQuantityState = add(
            goods[goodid].feeQuantityState,
            toTTSwapUINT256(uint128(welfare), 0)
        );
        emit e_goodWelfare(goodid, welfare);
    }

    function addbanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 1;
        emit e_addbanlist(_user);
        return true;
    }

    function removebanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 0;
        emit e_removebanlist(_user);
        return true;
    }

    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyDAOadmin returns (bool) {
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    function setGoodTrigger(
        uint256 goodid,
        address apptrigeraddress,
        uint256 config
    ) external override {
        require(msg.sender == goods[goodid].owner);
        uint256 goodconfig = goods[goodid].goodConfig;
        assembly {
            config := shl(223, and(config, 15))
            goodconfig := and(not(shl(223, 15)), goodconfig)
            goodconfig := add(config, goodconfig)
        }
        goods[goodid].goodConfig = goodconfig;
        goods[goodid].trigger = apptrigeraddress;
        emit e_setGoodTrigger(
            goodid,
            apptrigeraddress,
            goods[goodid].goodConfig
        );
    }

    /**
     * @dev Internal function to handle proof data deletion and updates during transfer.
     * @param proofid The ID of the proof being transferred.
     * @param from The address transferring the proof.
     * @param to The address receiving the proof.
     */
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
}
