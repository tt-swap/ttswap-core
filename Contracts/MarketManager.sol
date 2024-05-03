// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./GoodManage.sol";
import "./ProofManage.sol";

import "./interfaces/I_MarketManage.sol";
import {L_Good, L_GoodIdLibrary} from "./libraries/L_Good.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {Multicall} from "./libraries/Multicall.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {S_ProofKey, S_GoodKey, S_Ralate} from "./libraries/L_Struct.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_ArrayStorage} from "./libraries/L_ArrayStorage.sol";

contract MarketManager is Multicall, GoodManage, ProofManage, I_MarketManage {
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    using L_Good for L_Good.S_GoodState;
    using L_Proof for L_Proof.S_ProofState;
    using L_CurrencyLibrary for address;
    using L_MarketConfigLibrary for uint256;
    using L_ArrayStorage for L_ArrayStorage.S_ArrayStorage;
    constructor(
        address _marketcreator,
        uint256 _marketconfig
    ) GoodManage(_marketcreator, _marketconfig) {}

    /// @inheritdoc I_MarketManage
    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodConfig
    ) external override onlyMarketCreator returns (uint256, uint256) {
        require(_goodConfig.isvaluegood(), "M02");

        _erc20address.transferFrom(msg.sender, _initial.amount1());

        goodnum += 1;
        goodseq[S_GoodKey(_erc20address, msg.sender).toId()] = goodnum;

        goods[goodnum].init(_initial, _erc20address, _goodConfig);
        goods[goodnum].updateToValueGood();
        ownergoods[msg.sender].addvalue(goodnum);

        bytes32 normalproof = S_ProofKey(msg.sender, goodnum, 0).toId();
        totalSupply += 1;
        proofseq[normalproof] = totalSupply;
        proofs[totalSupply].updateValueInvest(
            goodnum,
            toBalanceUINT256(_initial.amount0(), 0),
            toBalanceUINT256(0, _initial.amount1())
        );
        return (goodnum, totalSupply);
    }

    /// @inheritdoc I_MarketManage
    function initNormalGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        address _gater
    ) external override noReentrant returns (uint256, uint256) {
        require(goods[_valuegood].goodConfig.isvaluegood(), "M02");
        bytes32 togood = S_GoodKey(_erc20address, msg.sender).toId();
        require(goodseq[togood] == 0, "M01");

        _erc20address.transferFrom(msg.sender, _initial.amount0());
        goods[_valuegood].erc20address.transferFrom(
            msg.sender,
            _initial.amount1()
        );
        uint128 value = goods[_valuegood].currentState.getamount0fromamount1(
            _initial.amount1()
        );
        goodnum += 1;
        goodseq[togood] = goodnum;
        ownergoods[msg.sender].addvalue(goodnum);
        goods[goodnum].init(
            toBalanceUINT256(value, _initial.amount0()),
            _erc20address,
            _goodConfig
        );

        goods[_valuegood].investGood(
            _initial.amount1(),
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        bytes32 normalproof = S_ProofKey(msg.sender, goodnum, _valuegood)
            .toId();
        totalSupply += 1;
        proofseq[normalproof] = totalSupply;
        proofs[totalSupply] = L_Proof.S_ProofState(
            msg.sender,
            goodnum,
            _valuegood,
            toBalanceUINT256(value, 0),
            toBalanceUINT256(0, _initial.amount0()),
            toBalanceUINT256(0, _initial.amount1()),
            address(0),
            address(0)
        );
        ownerproofs[msg.sender].addvalue(totalSupply);
        return (goodnum, totalSupply);
    }

    /// @inheritdoc I_MarketManage
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        bool _istotal,
        address _gater
    )
        external
        override
        noReentrant
        returns (uint128 goodid2Quanitity_, uint128 goodid2FeeQuanitity_)
    {
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity,
            outputQuanitity: 0,
            feeQuanitity: 0,
            swapvalue: 0,
            good1currentState: goods[_goodid1].currentState,
            good1config: goods[_goodid1].goodConfig,
            good2currentState: goods[_goodid2].currentState,
            good2config: goods[_goodid2].goodConfig
        });
        swapcache = L_Good.swapCompute1(
            swapcache,
            T_BalanceUINT256.wrap(_limitPrice)
        );
        if (_istotal == true && swapcache.remainQuanitity > 0)
            revert err_total();
        goodid2FeeQuanitity_ = goods[_goodid2].goodConfig.getBuyFee(
            swapcache.outputQuanitity
        );
        goodid2Quanitity_ = swapcache.outputQuanitity - goodid2FeeQuanitity_;
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            swapcache.feeQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            goodid2FeeQuanitity_,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        goods[_goodid1].erc20address.transferFrom(
            msg.sender,
            _swapQuanitity - swapcache.remainQuanitity
        );

        goods[_goodid2].erc20address.safeTransfer(
            msg.sender,
            goodid2Quanitity_
        );
        emit e_buyGood(
            _goodid1,
            _goodid2,
            msg.sender,
            swapcache.swapvalue,
            toBalanceUINT256(
                _swapQuanitity - swapcache.remainQuanitity,
                swapcache.feeQuanitity
            ),
            toBalanceUINT256(goodid2Quanitity_, goodid2FeeQuanitity_)
        );
    }

    /// @inheritdoc I_MarketManage
    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        address _recipent,
        address _gater
    )
        external
        override
        noReentrant
        returns (uint128 goodid1Quanitity_, uint128 goodid1FeeQuanitity_)
    {
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity,
            outputQuanitity: 0,
            feeQuanitity: 0,
            swapvalue: 0,
            good1currentState: goods[_goodid1].currentState,
            good1config: goods[_goodid1].goodConfig,
            good2currentState: goods[_goodid2].currentState,
            good2config: goods[_goodid2].goodConfig
        });

        swapcache = L_Good.swapCompute2(
            swapcache,
            T_BalanceUINT256.wrap(_limitPrice)
        );

        if (swapcache.remainQuanitity > 0) revert err_total();
        goodid1FeeQuanitity_ = goods[_goodid1].goodConfig.getBuyFee(
            swapcache.outputQuanitity
        );
        goodid1Quanitity_ = swapcache.outputQuanitity - goodid1FeeQuanitity_;

        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            swapcache.feeQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            goodid1FeeQuanitity_,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        goods[_goodid2].erc20address.safeTransfer(
            _recipent,
            _swapQuanitity - swapcache.remainQuanitity
        );
        goods[_goodid1].erc20address.transferFrom(
            msg.sender,
            goodid1Quanitity_
        );
        emit e_buyGoodForPay(
            _goodid1,
            _goodid2,
            msg.sender,
            _recipent,
            swapcache.swapvalue,
            toBalanceUINT256(
                _swapQuanitity - swapcache.remainQuanitity,
                swapcache.feeQuanitity
            ),
            toBalanceUINT256(goodid1Quanitity_, goodid1FeeQuanitity_)
        );
    }

    /// @inheritdoc I_MarketManage
    function investValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (L_Good.S_GoodInvestReturn memory valueInvest_)
    {
        require(
            goods[_goodid].goodConfig.isvaluegood() &&
                goods[_goodid].currentState.amount1() <= 2 ** 112 &&
                goods[_goodid].currentState.amount0() <= 2 ** 112,
            "M06"
        );
        goods[_goodid].erc20address.transferFrom(msg.sender, _goodQuanitity);

        valueInvest_ = goods[_goodid].investGood(
            _goodQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );

        uint256 proofno = proofseq[S_ProofKey(msg.sender, _goodid, 0).toId()];
        if (proofno == 0) {
            totalSupply += 1;
            proofseq[S_ProofKey(msg.sender, _goodid, 0).toId()] = totalSupply;
            proofno = totalSupply;
        }

        proofs[proofno].updateValueInvest(
            _goodid,
            toBalanceUINT256(valueInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                valueInvest_.contructFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        emit e_proof(proofno);
    }

    /// @inheritdoc I_MarketManage
    function disinvestValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (L_Good.S_GoodDisinvestReturn memory disinvestResult_)
    {
        uint256 proofno = proofseq[S_ProofKey(msg.sender, _goodid, 0).toId()];
        require(proofs[proofno].owner == msg.sender, "M03");
        uint128 remainquanitity = _goodQuanitity;

        disinvestResult_ = goods[_goodid].disinvestValueGood(
            proofs[proofno],
            remainquanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult_.profit
        );

        goods[_goodid].fees[marketcreator] += protocalfee;
        disinvestResult_.actual_fee = disinvestResult_.actual_fee + protocalfee;
        goods[_goodid].erc20address.safeTransfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.profit -
                disinvestResult_.actual_fee
        );

        emit e_proof(proofno);
    }

    /// @inheritdoc I_MarketManage
    function investNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (
            L_Good.S_GoodInvestReturn memory normalInvest,
            L_Good.S_GoodInvestReturn memory valueInvest
        )
    {
        require(
            goods[_valuegood].goodConfig.isvaluegood() &&
                goods[_togood].currentState.amount1() <= 2 ** 104 &&
                goods[_togood].currentState.amount0() <= 2 ** 104,
            "M02"
        );

        normalInvest = goods[_togood].investGood(
            _quanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );

        valueInvest.actualInvestQuantity = goods[_valuegood]
            .currentState
            .getamount1fromamount0(normalInvest.actualInvestValue);

        valueInvest = goods[_valuegood].investGood(
            valueInvest.actualInvestQuantity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );

        goods[_togood].erc20address.transferFrom(msg.sender, _quanitity);
        goods[_valuegood].erc20address.transferFrom(
            msg.sender,
            valueInvest.actualFeeQuantity + valueInvest.actualInvestQuantity
        );

        uint256 proofno = proofseq[
            S_ProofKey(msg.sender, _togood, _valuegood).toId()
        ];
        if (proofno == 0) {
            totalSupply += 1;
            proofseq[
                S_ProofKey(msg.sender, _togood, _valuegood).toId()
            ] = totalSupply;
            proofno = totalSupply;
        }

        proofs[proofno].updateNormalInvest(
            _togood,
            _valuegood,
            toBalanceUINT256(normalInvest.actualInvestValue, 0),
            toBalanceUINT256(
                normalInvest.contructFeeQuantity,
                normalInvest.actualInvestQuantity
            ),
            toBalanceUINT256(
                valueInvest.contructFeeQuantity,
                valueInvest.actualInvestQuantity
            )
        );

        emit e_proof(proofno);
    }

    /// @inheritdoc I_MarketManage
    function disinvestNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_
        )
    {
        uint256 _normalproofNo = proofseq[
            S_ProofKey(msg.sender, _togood, _valuegood).toId()
        ];
        require(
            _normalproofNo > 0 && proofs[_normalproofNo].owner == msg.sender,
            "M04"
        );

        (disinvestNormalResult1_, disinvestValueResult2_) = goods[_togood]
            .disinvestNormalGood(
                goods[_valuegood],
                proofs[
                    proofseq[S_ProofKey(msg.sender, _togood, _valuegood).toId()]
                ],
                _goodQuanitity,
                marketconfig,
                S_Ralate(_gater, relations[msg.sender])
            );

        T_BalanceUINT256 protocalfee = toBalanceUINT256(
            marketconfig.getPlatFee128(disinvestNormalResult1_.profit),
            marketconfig.getPlatFee128(disinvestValueResult2_.profit)
        );

        disinvestNormalResult1_.actual_fee += protocalfee.amount0();
        disinvestValueResult2_.actual_fee += protocalfee.amount1();
        goods[_togood].fees[marketcreator] += protocalfee.amount0();
        goods[_valuegood].fees[marketcreator] += protocalfee.amount1();

        goods[_togood].erc20address.safeTransfer(
            msg.sender,
            _goodQuanitity +
                disinvestNormalResult1_.profit -
                disinvestNormalResult1_.actual_fee
        );

        goods[_valuegood].erc20address.safeTransfer(
            msg.sender,
            disinvestValueResult2_.actualDisinvestQuantity +
                disinvestValueResult2_.profit -
                disinvestValueResult2_.actual_fee
        );
        emit e_proof(_normalproofNo);
    }

    /// @inheritdoc I_MarketManage
    function disinvestValueProof(
        uint256 _valueproofid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (L_Good.S_GoodDisinvestReturn memory disinvestResult_)
    {
        uint256 goodid1 = proofs[_valueproofid].currentgood;
        require(
            proofs[_valueproofid].owner == msg.sender &&
                proofs[_valueproofid].valuegood == 0,
            "M05"
        );
        disinvestResult_ = goods[goodid1].disinvestValueGood(
            proofs[_valueproofid],
            _goodQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult_.profit
        );
        disinvestResult_.actual_fee += protocalfee;
        goods[goodid1].fees[marketcreator] += protocalfee;
        goods[goodid1].erc20address.safeTransfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.profit -
                disinvestResult_.actual_fee
        );
    }

    /// @inheritdoc I_MarketManage
    function disinvestNormalProof(
        uint256 _normalProof,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        override
        noReentrant
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_
        )
    {
        uint256 valuegood = proofs[_normalProof].valuegood;
        require(
            proofs[_normalProof].owner == msg.sender && valuegood != 0,
            "M09"
        );
        uint256 currentgood = proofs[_normalProof].currentgood;

        (disinvestNormalResult1_, disinvestValueResult2_) = goods[currentgood]
            .disinvestNormalGood(
                goods[valuegood],
                proofs[_normalProof],
                _goodQuanitity,
                marketconfig,
                S_Ralate(_gater, relations[msg.sender])
            );

        T_BalanceUINT256 protocalfee = toBalanceUINT256(
            marketconfig.getPlatFee128(disinvestNormalResult1_.profit),
            marketconfig.getPlatFee128(disinvestValueResult2_.profit)
        );

        disinvestNormalResult1_.actual_fee += protocalfee.amount0();
        disinvestValueResult2_.actual_fee += protocalfee.amount1();
        goods[currentgood].fees[marketcreator] += protocalfee.amount0();
        goods[valuegood].fees[marketcreator] += protocalfee.amount1();

        goods[currentgood].erc20address.safeTransfer(
            msg.sender,
            _goodQuanitity +
                disinvestNormalResult1_.profit -
                disinvestNormalResult1_.actual_fee
        );

        goods[valuegood].erc20address.safeTransfer(
            msg.sender,
            disinvestValueResult2_.actualDisinvestQuantity +
                disinvestValueResult2_.profit -
                disinvestValueResult2_.actual_fee
        );
    }

    function collectValueProofFee(
        uint256 _valueProofid
    ) external override returns (uint128 profit) {
        require(
            (proofs[_valueProofid].owner == msg.sender ||
                proofs[_valueProofid].beneficiary == msg.sender) &&
                proofs[_valueProofid].valuegood == 0,
            "M09"
        );

        uint256 goodid1 = proofs[_valueProofid].currentgood;
        profit = goods[goodid1].collectValueGoodFee(proofs[_valueProofid]);
        uint128 protocalfee = marketconfig.getPlatFee128(profit);
        profit -= protocalfee;
        goods[goodid1].fees[marketcreator] += protocalfee;
        goods[goodid1].erc20address.safeTransfer(msg.sender, profit);
    }

    function collectNormalProofFee(
        uint256 _normalProofid
    ) external override returns (T_BalanceUINT256 profit) {
        require(
            (proofs[_normalProofid].owner == msg.sender ||
                proofs[_normalProofid].beneficiary == msg.sender) &&
                proofs[_normalProofid].valuegood != 0,
            "M09"
        );
        uint256 valuegood = proofs[_normalProofid].valuegood;
        uint256 currentgood = proofs[_normalProofid].currentgood;

        profit = goods[currentgood].collectNormalGoodFee(
            goods[valuegood],
            proofs[_normalProofid]
        );

        T_BalanceUINT256 protocalfee = toBalanceUINT256(
            marketconfig.getPlatFee128(profit.amount0()),
            marketconfig.getPlatFee128(profit.amount1())
        );
        profit = profit - protocalfee;
        goods[currentgood].fees[marketcreator] += protocalfee.amount0();
        goods[valuegood].fees[marketcreator] += protocalfee.amount1();
        goods[currentgood].erc20address.safeTransfer(
            msg.sender,
            profit.amount0()
        );
        goods[valuegood].erc20address.safeTransfer(
            msg.sender,
            profit.amount1()
        );
    }
}
