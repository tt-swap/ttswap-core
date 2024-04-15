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

    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodConfig
    ) external payable override onlyMarketCreator returns (uint256, uint256) {
        require(_goodConfig.isvaluegood(), "M02");

        _erc20address.transferFrom(msg.sender, _initial.amount1());

        goodnum += 1;

        goodseq[S_GoodKey(_erc20address, msg.sender).toId()] = goodnum;

        goods[goodnum].init(_initial, _erc20address, _goodConfig);
        goods[goodnum].updateToValueGood();
        ownergoods[msg.sender].push(goodnum);

        bytes32 normalproof = S_ProofKey(msg.sender, goodnum, 0).toId();
        proofnum += 1;
        proofseq[normalproof] = proofnum;
        proofs[proofnum].updateValueInvest(
            goodnum,
            toBalanceUINT256(_initial.amount0(), 0),
            toBalanceUINT256(0, _initial.amount1())
        );
        // emit e_initMetaGood(
        //     goodnum,
        //     _initial,
        //     _goodConfig,
        //     _erc20address,
        //     msg.sender
        // );
        return (goodnum, proofnum);
    }

    function initNormalGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        address _gater
    ) external payable override noReentrant returns (uint256, uint256) {
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
        ownergoods[msg.sender].push(goodnum);
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
        proofnum += 1;
        proofseq[normalproof] = proofnum;
        proofs[proofnum] = L_Proof.S_ProofState(
            msg.sender,
            goodnum,
            _valuegood,
            toBalanceUINT256(value, 0),
            toBalanceUINT256(0, _initial.amount0()),
            toBalanceUINT256(0, _initial.amount1())
        );
        _ownerproofs[msg.sender].push(proofnum);
        emit e_initNormalGood(
            _valuegood,
            goodnum,
            _initial,
            _goodConfig,
            _erc20address,
            msg.sender
        );
        return (goodnum, proofnum);
    }
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        bool _istotal,
        address _gater
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid2Quanitity_, uint128 goodid2FeeQuanitity_)
    {
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity,
            outputQuanitity: 0,
            feeQuanitity: 0,
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

        goods[_goodid2].erc20address.transfer(msg.sender, goodid2Quanitity_);
        emit e_buyGood(
            _goodid1,
            _goodid2,
            msg.sender,
            _swapQuanitity,
            toBalanceUINT256(
                _swapQuanitity - swapcache.remainQuanitity,
                swapcache.feeQuanitity
            ),
            toBalanceUINT256(goodid2Quanitity_, goodid2FeeQuanitity_)
        );
    }

    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        address _recipent,
        address _gater
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid1Quanitity_, uint128 goodid1FeeQuanitity_)
    {
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity,
            outputQuanitity: 0,
            feeQuanitity: 0,
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
        goods[_goodid2].erc20address.transfer(
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
            _swapQuanitity,
            toBalanceUINT256(
                _swapQuanitity - swapcache.remainQuanitity,
                swapcache.feeQuanitity
            ),
            toBalanceUINT256(goodid1Quanitity_, goodid1FeeQuanitity_)
        );
    }

    function investValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
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
            proofnum += 1;
            proofseq[S_ProofKey(msg.sender, _goodid, 0).toId()] = proofnum;
            proofno = proofnum;
        }

        proofs[proofno].updateValueInvest(
            _goodid,
            toBalanceUINT256(valueInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                valueInvest_.contructFeeQuantity,
                valueInvest_.actualInvestQuantity
            )
        );
        emit e_investGood(proofno);
    }

    function disinvestValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
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
        goods[_goodid].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.profit -
                disinvestResult_.actual_fee
        );
    }

    function investNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quanitity,
        address _gater
    )
        external
        payable
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
            proofnum += 1;
            proofseq[
                S_ProofKey(msg.sender, _togood, _valuegood).toId()
            ] = proofnum;
            proofno = proofnum;
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

        emit e_investGood(proofno);
    }
    function disinvestNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        override
        noReentrant
        returns (
            T_BalanceUINT256 disinvestResult1_,
            T_BalanceUINT256 disinvestResult2_
        )
    {
        uint256 _normalproofNo = proofseq[
            S_ProofKey(msg.sender, _togood, _valuegood).toId()
        ];
        require(
            _normalproofNo > 0 && proofs[_normalproofNo].owner == msg.sender,
            "M04"
        );
        uint256 currentgood = proofs[_normalproofNo].currentgood;
        uint256 valuegood = proofs[_normalproofNo].valuegood;
        uint128 valequanity;

        (disinvestResult1_, disinvestResult2_, valequanity) = goods[currentgood]
            .disinvestNormalGood(
                goods[valuegood],
                proofs[_normalproofNo],
                _goodQuanitity,
                marketconfig,
                S_Ralate(_gater, relations[msg.sender])
            );
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult1_.amount0()
        );
        goods[currentgood].fees[marketcreator] += protocalfee;
        goods[currentgood].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult1_.amount0() -
                disinvestResult1_.amount1() -
                protocalfee
        );
        protocalfee = marketconfig.getPlatFee128(disinvestResult2_.amount0());
        goods[valuegood].fees[marketcreator] += protocalfee;
        goods[valuegood].erc20address.transfer(
            msg.sender,
            valequanity +
                disinvestResult2_.amount0() -
                disinvestResult2_.amount1() -
                protocalfee
        );
        emit e_disinvestGood(_normalproofNo);
    }

    function disinvestValueProof(
        uint256 _valueproofid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
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
        goods[goodid1].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.profit -
                disinvestResult_.actual_fee
        );
        emit e_disinvestGood(_valueproofid);
    }
    function disinvestNormalProof(
        uint256 _normalProof,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        payable
        override
        noReentrant
        returns (
            T_BalanceUINT256 disinvestNormalResult1_,
            T_BalanceUINT256 disinvestValueResult2_
        )
    {
        uint256 valuegood = proofs[_normalProof].valuegood;
        require(
            proofs[_normalProof].owner == msg.sender && valuegood != 0,
            "M09"
        );
        uint256 currentgood = proofs[_normalProof].currentgood;
        uint128 valuequanity;

        (disinvestNormalResult1_, disinvestValueResult2_, valuequanity) = goods[
            currentgood
        ].disinvestNormalGood(
                goods[valuegood],
                proofs[_normalProof],
                _goodQuanitity,
                marketconfig,
                S_Ralate(_gater, relations[msg.sender])
            );

        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestNormalResult1_.amount0()
        );

        goods[currentgood].fees[marketcreator] += protocalfee;

        goods[currentgood].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestNormalResult1_.amount0() -
                disinvestNormalResult1_.amount1() -
                protocalfee
        );

        protocalfee = marketconfig.getPlatFee128(
            disinvestValueResult2_.amount0()
        );
        goods[valuegood].fees[marketcreator] += protocalfee;

        goods[valuegood].erc20address.transfer(
            msg.sender,
            valuequanity +
                disinvestValueResult2_.amount0() -
                disinvestValueResult2_.amount1() -
                protocalfee
        );
        emit e_disinvestGood(_normalProof);
    }
}
