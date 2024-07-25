// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./GoodManage.sol";
import "./ProofManage.sol";

import "./interfaces/I_MarketManage.sol";
import {L_Good, L_GoodIdLibrary} from "./libraries/L_Good.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {Multicall} from "./Multicall.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {S_ProofKey, S_GoodKey} from "./libraries/L_Struct.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";

contract MarketManager is Multicall, GoodManage, ProofManage, I_MarketManage {
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    using L_Good for L_Good.S_GoodState;
    using L_Proof for L_Proof.S_ProofState;
    using L_CurrencyLibrary for address;
    using L_MarketConfigLibrary for uint256;
    constructor(
        address _marketcreator,
        uint256 _marketconfig
    ) GoodManage(_marketcreator, _marketconfig) {}

    /// @inheritdoc I_MarketManage
    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodConfig
    ) external payable override returns (bool) {
        require(
            msg.sender == marketcreator && _goodConfig.isvaluegood(),
            "G02"
        );
        _erc20address.transferFrom(msg.sender, _initial.amount1());
        goodNum += 1;
        uint256 togood = S_GoodKey(msg.sender, _erc20address).toId();
        goods[togood].init(_initial, _erc20address, _goodConfig);
        goods[togood].modifyGoodConfig(8);
        totalSupply += 1;
        uint256 proofKey = S_ProofKey(msg.sender, togood, 0).toId();
        proofmapping[proofKey] = totalSupply;
        _mint(msg.sender, totalSupply);
        proofs[totalSupply].updateInvest(
            togood,
            0,
            toBalanceUINT256(_initial.amount0(), 0),
            toBalanceUINT256(0, _initial.amount1()),
            toBalanceUINT256(0, 0)
        );
        emit e_initMetaGood(
            totalSupply,
            togood,
            _erc20address,
            _goodConfig,
            _initial
        );
        return true;
    }

    /// @inheritdoc I_MarketManage
    function initGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig
    ) external payable override noReentrant returns (bool) {
        uint256 togood = S_GoodKey(msg.sender, _erc20address).toId();
        require(
            goods[togood].owner == address(0) &&
                goods[_valuegood].goodConfig.isvaluegood(),
            "M02"
        );
        _erc20address.transferFrom(msg.sender, _initial.amount0());
        goods[_valuegood].erc20address.transferFrom(
            msg.sender,
            _initial.amount1()
        );

        L_Good.S_GoodInvestReturn memory investResult = goods[_valuegood]
            .investGood(_initial.amount1());
        goodNum += 1;
        goods[togood].init(
            toBalanceUINT256(
                investResult.actualInvestValue,
                _initial.amount0()
            ),
            _erc20address,
            _goodConfig
        );
        totalSupply += 1;
        uint256 proofKey = S_ProofKey(msg.sender, togood, _valuegood).toId();

        proofmapping[proofKey] = totalSupply;
        _mint(msg.sender, totalSupply);
        proofs[totalSupply] = L_Proof.S_ProofState(
            togood,
            _valuegood,
            toBalanceUINT256(investResult.actualInvestValue, 0),
            toBalanceUINT256(0, _initial.amount0()),
            toBalanceUINT256(
                investResult.contructFeeQuantity,
                investResult.actualInvestQuantity
            ),
            address(0)
        );
        emit e_initGood(
            totalSupply,
            togood,
            _valuegood,
            _erc20address,
            _goodConfig,
            toBalanceUINT256(
                _initial.amount0(),
                investResult.actualInvestValue
            ),
            toBalanceUINT256(
                investResult.actualFeeQuantity,
                investResult.actualInvestQuantity
            )
        );
        return true;
    }
    /// @inheritdoc I_MarketManage
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuantity,
        T_BalanceUINT256 _limitPrice,
        bool _istotal
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_)
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
        swapcache = L_Good.swapCompute1(swapcache, _limitPrice);
        if (_istotal == true && swapcache.remainQuantity > 0)
            revert err_total();
        goodid2FeeQuantity_ = goods[_goodid2].goodConfig.getBuyFee(
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
            toBalanceUINT256(
                _swapQuantity - swapcache.remainQuantity,
                swapcache.feeQuantity
            ),
            toBalanceUINT256(goodid2Quantity_, goodid2FeeQuantity_)
        );
    }

    /// @inheritdoc I_MarketManage
    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuantity,
        T_BalanceUINT256 _limitPrice,
        address _recipent
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

        swapcache = L_Good.swapCompute2(swapcache, _limitPrice);

        if (swapcache.remainQuantity > 0) revert err_total();
        goodid1FeeQuantity_ = goods[_goodid1].goodConfig.getSellFee(
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
            _recipent,
            _swapQuantity - swapcache.feeQuantity
        );
        goods[_goodid1].erc20address.transferFrom(msg.sender, goodid1Quantity_);
        emit e_buyGoodForPay(
            _goodid1,
            _goodid2,
            msg.sender,
            _recipent,
            swapcache.swapvalue,
            toBalanceUINT256(_swapQuantity, swapcache.feeQuantity),
            toBalanceUINT256(goodid1Quantity_, goodid1FeeQuantity_)
        );
    }

    /// @inheritdoc I_MarketManage
    function investGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quantity
    ) external payable override noReentrant returns (bool) {
        L_Good.S_GoodInvestReturn memory normalInvest_;
        L_Good.S_GoodInvestReturn memory valueInvest_;
        require(
            goods[_togood].currentState.amount1() + _quantity <= 2 ** 109,
            "M02"
        );
        require(
            goods[_togood].goodConfig.isvaluegood() ||
                goods[_valuegood].goodConfig.isvaluegood(),
            "M02"
        );
        normalInvest_ = goods[_togood].investGood(_quantity);
        goods[_togood].erc20address.transferFrom(msg.sender, _quantity);
        if (_valuegood != 0) {
            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .currentState
                .getamount1fromamount0(normalInvest_.actualInvestValue);

            valueInvest_.actualInvestQuantity = goods[_valuegood]
                .goodConfig
                .getInvestFulFee(valueInvest_.actualInvestQuantity);
            goods[_valuegood].erc20address.transferFrom(
                msg.sender,
                valueInvest_.actualInvestQuantity
            );
            valueInvest_ = goods[_valuegood].investGood(
                valueInvest_.actualInvestQuantity
            );
        }

        uint256 proofKey = S_ProofKey(msg.sender, _togood, _valuegood).toId();
        uint256 proofNo = proofmapping[proofKey];

        if (proofNo == 0) {
            totalSupply += 1;
            _mint(msg.sender, totalSupply);
            proofmapping[proofKey] = totalSupply;
            proofNo = totalSupply;
        }
        proofs[proofNo].updateInvest(
            _togood,
            _valuegood,
            toBalanceUINT256(normalInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                normalInvest_.contructFeeQuantity,
                normalInvest_.actualInvestQuantity
            ),
            toBalanceUINT256(
                valueInvest_.contructFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        emit e_investGood(
            proofNo,
            _togood,
            _valuegood,
            toBalanceUINT256(normalInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                normalInvest_.actualFeeQuantity,
                normalInvest_.actualInvestQuantity
            ),
            toBalanceUINT256(
                valueInvest_.actualFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        return true;
    }

    /// @inheritdoc I_MarketManage
    function disinvestProof(
        uint256 _proofid,
        uint128 _goodQuantity,
        address _gater,
        address _referal
    ) public override noReentrant returns (bool) {
        require(_isApprovedOrOwner(msg.sender, _proofid), "M05");
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_;
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_;
        uint256 normalgood = proofs[_proofid].currentgood;
        uint256 valuegood = proofs[_proofid].valuegood;
        uint128 devestvalue;
        _gater = banlist[_gater] == 1 ? _gater : marketcreator;
        if (referals[msg.sender] == address(0)) {
            referals[msg.sender] = _referal;
        } else {
            _referal = referals[msg.sender];
            emit e_addreferal(_referal);
        }
        _referal = _gater == _referal ? marketcreator : _referal;
        _referal = banlist[_referal] == 1 ? _referal : marketcreator;
        (disinvestNormalResult1_, disinvestValueResult2_, devestvalue) = goods[
            normalgood
        ].disinvestGood(
                goods[valuegood],
                proofs[_proofid],
                L_Good.S_GoodDisinvestParam(
                    _goodQuantity,
                    _gater,
                    _referal,
                    marketconfig,
                    marketcreator
                )
            );
        if (valuegood != 0) devestvalue = devestvalue * 2;
        emit e_disinvestProof(
            _proofid,
            normalgood,
            valuegood,
            devestvalue,
            toBalanceUINT256(
                disinvestNormalResult1_.actual_fee,
                disinvestNormalResult1_.actualDisinvestQuantity
            ),
            toBalanceUINT256(
                disinvestValueResult2_.actual_fee,
                disinvestValueResult2_.actualDisinvestQuantity
            ),
            toBalanceUINT256(
                disinvestNormalResult1_.profit,
                disinvestValueResult2_.profit
            )
        );
        return true;
    }
    /// @inheritdoc I_MarketManage
    function collectProof(
        uint256 _proofid,
        address _gater,
        address _referal
    ) external override noReentrant returns (T_BalanceUINT256 profit_) {
        require(
            _isApprovedOrOwner(msg.sender, _proofid) ||
                proofs[_proofid].beneficiary == msg.sender,
            "M09"
        );
        uint256 valuegood = proofs[_proofid].valuegood;
        uint256 currentgood = proofs[_proofid].currentgood;
        _gater = banlist[_gater] == 1 ? marketcreator : _gater;
        if (referals[msg.sender] == address(0)) {
            referals[msg.sender] = _referal;
        } else {
            _referal = referals[msg.sender];
            emit e_addreferal(_referal);
        }
        _referal = _gater == _referal ? marketcreator : _referal;
        _referal = banlist[_referal] == 1 ? _referal : marketcreator;
        profit_ = goods[currentgood].collectGoodFee(
            goods[valuegood],
            proofs[_proofid],
            _gater,
            _referal,
            marketconfig,
            marketcreator
        );
        emit e_collectProof(_proofid, currentgood, valuegood, profit_);
    }

    function enpower(
        uint256 goodid,
        uint256 valuegood,
        uint128 quantity
    ) external payable override noReentrant returns (bool) {
        require(goods[valuegood].goodConfig.isvaluegood(), "M2");
        goods[valuegood].erc20address.transferFrom(msg.sender, quantity);
        uint128 value = goods[valuegood].currentState.getamount0fromamount1(
            quantity
        );
        goods[valuegood].currentState =
            goods[valuegood].currentState +
            toBalanceUINT256(0, quantity);
        goods[goodid].currentState =
            goods[goodid].currentState +
            toBalanceUINT256(value, 0);
        emit e_enpower(goodid, valuegood, quantity);
        return true;
    }
    function getState(
        uint256 goodid,
        uint256 valuegood
    ) external view returns (T_BalanceUINT256, T_BalanceUINT256) {
        return (goods[goodid].currentState, goods[valuegood].currentState);
    }
}
