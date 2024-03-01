// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import "./GoodManage.sol";
import "./ProofManage.sol";

import "./interfaces/I_MarketManage.sol";
import {L_Good} from "./libraries/L_Good.sol";
import {L_Proof} from "./libraries/L_Proof.sol";
import {Multicall} from "./libraries/Multicall.sol";
import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Ralate} from "./libraries/L_Ralate.sol";

import {T_GoodId, L_GoodIdLibrary} from "./types/T_GoodId.sol";
import {S_GoodKey} from "./types/S_GoodKey.sol";
import {T_ProofId, L_ProofIdLibrary} from "./types/T_ProofId.sol";
import {S_ProofKey, S_ProofState} from "./types/S_ProofKey.sol";

import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {T_Currency, L_CurrencyLibrary} from "./types/T_Currency.sol";

contract MarketManager is
    Multicall,
    GoodManage,
    ProofManage,
    I_MarketManage
{
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_Good for L_Good.S_State;
    using L_ProofIdLibrary for S_ProofKey;
    using L_Proof for S_ProofState;
    using L_CurrencyLibrary for T_Currency;
    using L_MarketConfigLibrary for uint256;
    //address public immutable marketaddress;

    constructor(
        address _marketcreator,
        uint256 _marketconfig
    ) GoodManage(_marketcreator, _marketconfig) {}

    //初始化第一个物品
    function initMetaGood(
        S_GoodKey calldata goodkey1,
        T_BalanceUINT256 initial,
        uint256 _goodConfig
    )
        external
        override
        noReentrant
        onlyMarketCreator
        returns (bool)
    {
        require(_goodConfig.isvaluegood(), "need value good");
        goodkey1.erc20address.transferFrom(
            msg.sender,
            uint256(initial.amount1())
        );
        T_GoodId metagood = goodkey1.toId();
        goods[metagood].owner = marketcreator;
        goods[metagood].currentState = initial;
        goods[metagood].investState = initial;
        goods[metagood].goodConfig = _goodConfig;
        goods[metagood].erc20address = goodkey1.erc20address;
        goods[metagood].feeQunitityState = toBalanceUINT256(0, 0);
        T_ProofId normalproof = S_ProofKey(
            msg.sender,
            metagood,
            T_GoodId.wrap(0)
        ).toId();
        proofs[normalproof].owner = msg.sender;
        proofs[normalproof].currentgood = metagood;
        proofs[normalproof].extends = toBalanceUINT256(initial.amount0(), 0);
        proofs[normalproof].invest = toBalanceUINT256(0, initial.amount1());
        proofs[normalproof].valueinvest = toBalanceUINT256(0, 0);
        goodnum += 1;
        goodmapping[goodnum] = metagood;
        _ownergoods[msg.sender].push(metagood);
        return true;
    }

    function initNormalGood(
        T_GoodId valuegood,
        T_BalanceUINT256 initial,
        T_Currency _erc20address,
        uint256 _goodConfig
    ) external payable override noReentrant  returns (T_ProofId) {
        require(goods[valuegood].goodConfig.isvaluegood(), "not value good");
        require(!_goodConfig.isvaluegood(), "normal good config error");
        require(_erc20address.decimals() <= 18, "erc20 decimals to long");
        require(
            _erc20address.totalSupply() <= 2 ** 96,
            "erc20 totalsupply too big"
        );

        T_GoodId togood = S_GoodKey(_erc20address, msg.sender).toId();

        require(
            goods[togood].currentState.amount0() == 0 &&
                goods[togood].currentState.amount1() == 0,
            "normal good inited"
        );
        _erc20address.transferFrom(msg.sender, initial.amount0());
        goods[valuegood].erc20address.transferFrom(
            msg.sender,
            initial.amount1()
        );
        uint128 value = goods[valuegood].currentState.getamount0fromamount1(
            initial.amount1()
        );
        goods[togood].init(
            toBalanceUINT256(value, initial.amount0()),
            _erc20address,
            _goodConfig
        );
        uint128 contruct_fee = toBalanceUINT256(
            goods[valuegood].feeQunitityState.amount0(),
            goods[valuegood].investState.amount1()
        ).getamount0fromamount1(initial.amount1());
        goods[valuegood].currentState =
            goods[valuegood].currentState +
            toBalanceUINT256(value, initial.amount1());

        goods[valuegood].investState =
            goods[valuegood].investState +
            toBalanceUINT256(value, initial.amount1());

        goods[valuegood].feeQunitityState =
            goods[valuegood].feeQunitityState +
            toBalanceUINT256(contruct_fee, contruct_fee);
        T_ProofId normalproof = S_ProofKey(msg.sender, togood, valuegood)
            .toId();
        proofs[normalproof] = S_ProofState(
            msg.sender,
            togood,
            valuegood,
            toBalanceUINT256(value, 0),
            toBalanceUINT256(0, initial.amount0()),
            toBalanceUINT256(0, initial.amount1())
        );
        goodnum += 1;
        goodmapping[goodnum] = togood;
        _ownergoods[msg.sender].push(togood);
        emit e_initNormalGood(togood);
        return normalproof;
    }

    //交易
    //花_swapQuanitity个T_GoodId1买T_GoodId2

    function buyGood(
        T_GoodId _goodid1,
        T_GoodId _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitPrice,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        override
        noReentrant
        
        returns (
            uint128 goodid2Quanitity_,
            uint128 goodid1FeeQuanitity_,
            uint128 goodid2FeeQuanitity_
        )
    {
        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuanitity: _swapQuanitity - goodid1FeeQuanitity_,
            outputQuanitity: 0,
            feeQuanitity: 0,
            good1currentState: goods[_goodid1].currentState,
            good1config: goods[_goodid1].goodConfig,
            good2currentState: goods[_goodid2].currentState,
            good2config: goods[_goodid2].goodConfig
        });
        swapcache = L_Good.swapCompute(
            swapcache,
            T_BalanceUINT256.wrap(_limitPrice)
        );

        goodid1FeeQuanitity_ = swapcache.feeQuanitity;
        goodid2FeeQuanitity_ = goods[_goodid2].goodConfig.getBuyFee(
            swapcache.outputQuanitity
        );
        goodid2Quanitity_ = swapcache.outputQuanitity - goodid2FeeQuanitity_;

        goods[_goodid1].erc20address.transferFrom(
            msg.sender,
            _swapQuanitity - swapcache.remainQuanitity
        );
        goods[_goodid2].erc20address.transfer(msg.sender, goodid2Quanitity_);
        goods[_goodid1].swapCommit(
            swapcache.good1currentState,
            goodid1FeeQuanitity_,
            marketconfig,
            _ralate
        );
        goods[_goodid2].swapCommit(
            swapcache.good2currentState,
            goodid2FeeQuanitity_,
            marketconfig,
            _ralate
        );
        emit e_buyGood(
            msg.sender,
            _goodid1,
            _goodid2,
            _swapQuanitity,
            toBalanceUINT256(
                _swapQuanitity - swapcache.remainQuanitity,
                goodid1FeeQuanitity_
            ),
            toBalanceUINT256(goodid2Quanitity_, goodid2FeeQuanitity_)
        );
    }

    function investValueGood(
        T_GoodId _goodid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        override
        noReentrant
        
        returns (S_GoodInvestReturn memory normalInvest_)
    {
        require(
            goods[_goodid].goodConfig.isvaluegood(),
            "need good total value more than 0"
        );
        goods[_goodid].erc20address.transferFrom(msg.sender, _goodQuanitity);

        normalInvest_ = goods[_goodid].investGood(
            _goodQuanitity,
            marketconfig,
            _ralate
        );

        T_ProofId valueproof = S_ProofKey(msg.sender, _goodid, T_GoodId.wrap(0))
            .toId();
        if (
            proofs[valueproof].invest.amount1() == 0 &&
            proofs[valueproof].owner == address(0)
        ) {
            prooftotal += 1;
            proofnum[prooftotal] = valueproof;
        }

        proofs[valueproof].updateValueInvest(
            _goodid,
            toBalanceUINT256(normalInvest_.actualInvestValue, 0),
            toBalanceUINT256(
                normalInvest_.contructFeeQuantity,
                normalInvest_.actualInvestQuantity
            )
        );

        emit e_investValueGood(msg.sender, _goodid, _goodQuanitity, valueproof);
    }

    function disinvestValueGood(
        T_GoodId _goodid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        override
        noReentrant
        
        returns (T_BalanceUINT256 disinvestResult_)
    {
        T_ProofId investproofid = S_ProofKey(
            msg.sender,
            _goodid,
            T_GoodId.wrap(0)
        ).toId();

        require(proofs[investproofid].owner == msg.sender, "is not yours");
        uint128 remainquanitity = _goodQuanitity;
        uint128 protocalfee = marketconfig.getPlatFee128(
            disinvestResult_.amount0()
        );
        goods[_goodid].fees[marketcreator] += protocalfee;
        disinvestResult_ = goods[_goodid].disinvestValueGood(
            proofs[investproofid],
            remainquanitity,
            marketconfig,
            _ralate
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
        T_GoodId _togood,
        T_GoodId _valuegood,
        uint128 _quanitity,
        L_Ralate.S_Ralate calldata _ralate
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
        require(
            goods[_togood].currentState.amount0() > 0 &&
                goods[_valuegood].goodConfig.isvaluegood(),
            "need good total value more than 0"
        );

        normalInvest = goods[_togood].investGood(
            _quanitity,
            marketconfig,
            _ralate
        );

        valueInvest.actualInvestQuantity = goods[_valuegood]
            .currentState
            .getamount1fromamount0(normalInvest.actualInvestValue);

        valueInvest = goods[_valuegood].investGood(
            valueInvest.actualInvestQuantity,
            marketconfig,
            _ralate
        );

        goods[_togood].erc20address.transferFrom(msg.sender, _quanitity);
        goods[_valuegood].erc20address.transferFrom(
            msg.sender,
            valueInvest.actualFeeQuantity + valueInvest.actualInvestQuantity
        );
        T_ProofId proofid = S_ProofKey(msg.sender, _togood, _valuegood).toId();
        if (
            proofs[proofid].invest.amount1() == 0 &&
            proofs[proofid].owner == address(0)
        ) {
            prooftotal += 1;
            proofnum[prooftotal] = proofid;
        }

        proofs[proofid].updateNormalInvest(
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

        emit e_investNormalGood(
            msg.sender,
            _togood,
            _valuegood,
            _quanitity,
            proofid
        );
    }

    function disinvestNormalGood(
        T_GoodId _togood,
        T_GoodId _valuegood,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
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
        T_ProofId _normalproof = S_ProofKey(msg.sender, _togood, _valuegood)
            .toId();
        require(
            proofs[_normalproof].owner == msg.sender &&
                proofs[_normalproof].valuegood != T_GoodId.wrap("0"),
            ""
        );
        T_GoodId currentgood = proofs[_normalproof].currentgood;
        T_GoodId valuegood = proofs[_normalproof].valuegood;
        uint128 valequanity;

        (disinvestResult1_, disinvestResult2_, valequanity) = goods[currentgood]
            .disinvestNormalGood(
                goods[valuegood],
                proofs[_normalproof],
                _goodQuanitity,
                marketconfig,
                _ralate
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
        emit e_disinvestNormalGood(
            msg.sender,
            _togood,
            _valuegood,
            disinvestResult1_,
            disinvestResult2_
        );
    }

    //disinvestResult_ amount0为投资收益 amount1为实际产生手续费
    function disinvestValueProof(
        T_ProofId _valueproofid,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
    )
        external
        payable
        override
        noReentrant
        
        returns (T_BalanceUINT256 disinvestResult_)
    {
        T_GoodId goodid1 = proofs[_valueproofid].currentgood;
        require(
            proofs[_valueproofid].owner == msg.sender &&
                proofs[_valueproofid].valuegood == T_GoodId.wrap(0),
            "is not yours"
        );
        disinvestResult_ = goods[goodid1].disinvestValueGood(
            proofs[_valueproofid],
            _goodQuanitity,
            marketconfig,
            _ralate
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
        emit e_disinvestValueProof(
            msg.sender,
            _valueproofid,
            _goodQuanitity,
            disinvestResult_
        );
    }

    function disinvestNormalProof(
        T_ProofId _normalProof,
        uint128 _goodQuanitity,
        L_Ralate.S_Ralate calldata _ralate
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
        T_GoodId valuegood = proofs[_normalProof].valuegood;
        require(
            proofs[_normalProof].owner == msg.sender &&
                valuegood != T_GoodId.wrap(0),
            ""
        );
        T_GoodId currentgood = proofs[_normalProof].currentgood;
        uint128 valuequanity;
        (disinvestResult1_, disinvestResult2_, valuequanity) = goods[
            currentgood
        ].disinvestNormalGood(
                goods[valuegood],
                proofs[_normalProof],
                _goodQuanitity,
                marketconfig,
                _ralate
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
        protocalfee = 0;
        protocalfee = marketconfig.getPlatFee128(disinvestResult2_.amount0());
        goods[valuegood].fees[marketcreator] += protocalfee;
        goods[valuegood].erc20address.transfer(
            msg.sender,
            valuequanity +
                disinvestResult2_.amount0() -
                disinvestResult2_.amount1() -
                protocalfee
        );

        emit e_disinvestNormalProof(
            msg.sender,
            _normalProof,
            _goodQuanitity,
            disinvestResult1_,
            disinvestResult2_
        );
    }

    function profitInvestValueProof(
        T_ProofId investproofid
    ) external view override returns (uint128 profit) {
        profit =
            toBalanceUINT256(
                goods[proofs[investproofid].currentgood]
                    .feeQunitityState
                    .amount1(),
                goods[proofs[investproofid].currentgood].investState.amount1()
            ).getamount0fromamount1(proofs[investproofid].invest.amount1()) -
            proofs[investproofid].invest.amount0();
        return profit;
    }

    function profitInvestNormalProof(
        T_ProofId investproofid
    ) external view override returns (T_BalanceUINT256 result) {
        result = toBalanceUINT256(
            toBalanceUINT256(
                goods[proofs[investproofid].currentgood]
                    .feeQunitityState
                    .amount1(),
                goods[proofs[investproofid].currentgood].investState.amount1()
            ).getamount0fromamount1(proofs[investproofid].invest.amount1()) -
                proofs[investproofid].invest.amount0(),
            toBalanceUINT256(
                goods[proofs[investproofid].valuegood]
                    .feeQunitityState
                    .amount1(),
                goods[proofs[investproofid].valuegood].investState.amount1()
            ).getamount0fromamount1(
                    proofs[investproofid].valueinvest.amount1()
                ) - proofs[investproofid].valueinvest.amount0()
        );
    }
}
