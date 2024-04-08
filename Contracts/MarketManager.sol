// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./GoodManage.sol";
import "./ProofManage.sol";

import "./interfaces/I_MarketManage.sol";
import {L_Good, L_GoodIdLibrary} from "./libraries/L_Good.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {Multicall} from "./libraries/Multicall.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {S_ProofKey, S_ProofState, S_GoodKey, S_GoodState, S_Ralate} from "./libraries/L_Struct.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_CHECK} from "./libraries/L_CHECK.sol";

contract MarketManager is Multicall, GoodManage, ProofManage, I_MarketManage {
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    using L_Good for S_GoodState;
    using L_Proof for S_ProofState;
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
    ) external payable override onlyMarketCreator returns (uint256) {
        require(_goodConfig.isvaluegood() && goodnum == 0, "M002");

        _erc20address.transferFrom(msg.sender, _initial.amount1());

        goodnum += 1;

        goodseq[S_GoodKey(_erc20address, msg.sender).toId()] = goodnum;

        goods[goodnum].init(_initial, _erc20address, _goodConfig);

        _ownergoods[msg.sender].push(goodnum);

        bytes32 normalproof = S_ProofKey(msg.sender, goodnum, 0).toId();
        proofnum += 1;
        proofseq[normalproof] = proofnum;
        proofs[proofnum].updateValueInvest(
            goodnum,
            toBalanceUINT256(_initial.amount0(), 0),
            toBalanceUINT256(0, _initial.amount1())
        );
        emit e_initMetaGood(
            goodnum,
            _initial,
            _goodConfig,
            _erc20address,
            msg.sender
        );
        return goodnum;
    }

    function initNormalGood(
        uint256 valuegood,
        T_BalanceUINT256 initial,
        address _erc20address,
        uint256 _goodConfig,
        address _gater
    ) external payable override noReentrant returns (uint256, uint256) {
        L_CHECK.checkinitNormalGoodParas(
            goods[valuegood].goodConfig,
            _erc20address,
            _goodConfig
        );
        bytes32 togood = S_GoodKey(_erc20address, msg.sender).toId();
        require(goodseq[togood] == 0, "M001");

        _erc20address.transferFrom(msg.sender, initial.amount0());
        goods[valuegood].erc20address.transferFrom(
            msg.sender,
            initial.amount1()
        );
        uint128 value = goods[valuegood].currentState.getamount0fromamount1(
            initial.amount1()
        );
        goodnum += 1;
        goodseq[togood] = goodnum;
        _ownergoods[msg.sender].push(goodnum);
        goods[goodnum].init(
            toBalanceUINT256(value, initial.amount0()),
            _erc20address,
            _goodConfig
        );

        goods[valuegood].investGood(
            initial.amount1(),
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        bytes32 normalproof = S_ProofKey(msg.sender, goodnum, valuegood).toId();
        proofnum += 1;
        proofseq[normalproof] = proofnum;
        proofs[proofnum] = S_ProofState(
            msg.sender,
            goodnum,
            valuegood,
            toBalanceUINT256(value, 0),
            toBalanceUINT256(0, initial.amount0()),
            toBalanceUINT256(0, initial.amount1())
        );
        _ownerproofs[msg.sender].push(proofnum);
        emit e_initNormalGood(
            valuegood,
            goodnum,
            initial,
            _goodConfig,
            _erc20address,
            msg.sender
        );
        return (goodnum, proofnum);
    }
    event debugg(uint256, uint256);
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        bool istotal,
        address _gater
    )
        external
        payable
        override
        noReentrant
        returns (uint128 goodid2Quanitity_, uint128 goodid2FeeQuanitity_)
    {
        emit debugg(1, gasleft());
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity,
            outputQuanitity: 0,
            feeQuanitity: 0,
            good1currentState: goods[_goodid1].currentState,
            good1config: goods[_goodid1].goodConfig,
            good2currentState: goods[_goodid2].currentState,
            good2config: goods[_goodid2].goodConfig
        });
        emit debugg(2, gasleft());
        swapcache = L_Good.swapCompute1(
            swapcache,
            T_BalanceUINT256.wrap(_limitPrice)
        );
        emit debugg(3, gasleft());
        if (istotal == true && swapcache.remainQuanitity > 0)
            revert err_total();
        goodid2FeeQuanitity_ = goods[_goodid2].goodConfig.getBuyFee(
            swapcache.outputQuanitity
        );
        goodid2Quanitity_ = swapcache.outputQuanitity - goodid2FeeQuanitity_;
        emit debugg(4, gasleft());
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            swapcache.feeQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        emit debugg(5, gasleft());
        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            goodid2FeeQuanitity_,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        emit debugg(6, gasleft());
        goods[_goodid1].erc20address.transferFrom(
            msg.sender,
            _swapQuanitity - swapcache.remainQuanitity
        );

        emit debugg(7, gasleft());
        goods[_goodid2].erc20address.transfer(msg.sender, goodid2Quanitity_);
        emit debugg(8, gasleft());
        goods[_goodid2].erc20address.transfer(msg.sender, goodid2Quanitity_);
        emit debugg(9, gasleft());
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
        address recipent,
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
            recipent,
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
        returns (S_GoodInvestReturn memory normalInvest_)
    {
        require(goods[_goodid].goodConfig.isvaluegood(), "M006");
        goods[_goodid].erc20address.transferFrom(msg.sender, _goodQuanitity);

        normalInvest_ = goods[_goodid].investGood(
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
            toBalanceUINT256(normalInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                normalInvest_.contructFeeQuantity,
                normalInvest_.actualInvestQuantity
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
        returns (T_BalanceUINT256 disinvestResult_)
    {
        uint256 proofno = proofseq[S_ProofKey(msg.sender, _goodid, 0).toId()];

        require(proofs[proofno].owner == msg.sender, "is not yours");
        uint128 remainquanitity = _goodQuanitity;
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult_.amount0()
        );
        goods[_goodid].fees[marketcreator] += protocalfee;
        disinvestResult_ = goods[_goodid].disinvestValueGood(
            proofs[proofno],
            remainquanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );

        goods[_goodid].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.amount0() -
                disinvestResult_.amount1() -
                protocalfee
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
            S_GoodInvestReturn memory normalInvest,
            S_GoodInvestReturn memory valueInvest
        )
    {
        require(goods[_valuegood].goodConfig.isvaluegood(), "M002");

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
            "M007"
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
        returns (T_BalanceUINT256 disinvestResult_)
    {
        uint256 goodid1 = proofs[_valueproofid].currentgood;
        require(
            proofs[_valueproofid].owner == msg.sender &&
                proofs[_valueproofid].valuegood == 0,
            "M008"
        );
        disinvestResult_ = goods[goodid1].disinvestValueGood(
            proofs[_valueproofid],
            _goodQuanitity,
            marketconfig,
            S_Ralate(_gater, relations[msg.sender])
        );
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult_.amount0()
        );
        goods[goodid1].fees[marketcreator] += protocalfee;
        goods[goodid1].erc20address.transfer(
            msg.sender,
            _goodQuanitity +
                disinvestResult_.amount0() -
                disinvestResult_.amount1() -
                protocalfee
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
            "M009"
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
