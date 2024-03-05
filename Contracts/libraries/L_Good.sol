// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import {L_Proof} from "./L_Proof.sol";
import {SafeCast} from "./SafeCast.sol";
import {L_MarketConfigLibrary} from "./L_MarketConfig.sol";
import {L_Ralate} from "./L_Ralate.sol";
import {L_GoodConfigLibrary} from "./L_GoodConfig.sol";

import {T_GoodId, L_GoodIdLibrary} from "../types/T_GoodId.sol";
import {S_GoodInvestReturn} from "../types/S_GoodKey.sol";
import {T_ProofId} from "../types/T_ProofId.sol";
import {S_ProofState} from "../types/S_ProofKey.sol";

import {T_Currency} from "../types/T_Currency.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd, getprice} from "../types/T_BalanceUINT256.sol";

library L_Good {
    using SafeCast for *;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_BalanceUINT256Library for uint256;
    using L_Proof for S_ProofState;

    struct S_State {
        address owner;
        T_Currency erc20address;
        uint256 goodConfig; //商品配置 refer to goodConfig 物品的配置信息
        T_BalanceUINT256 currentState; // value: quantity: 记录物品当前的数量与当前的价值
        T_BalanceUINT256 investState; // investvalue invest_quantity 记录投资的总价值和数量
        T_BalanceUINT256 feeQunitityState; //fee contruct记录物品的当前手续费与构建手续费
        mapping(address => uint256) fees;
    }

    function getMaxTradeValue(
        S_State storage self
    ) internal view returns (uint128) {
        return self.goodConfig.getSwapChips(self.currentState.amount0());
    }

    function getMaxTradeQunitity(
        S_State storage self
    ) internal view returns (uint128) {
        return self.goodConfig.getSwapChips(self.currentState.amount1());
    }

    function updateToValueGood(S_State storage self) internal {
        require(!self.goodConfig.isvaluegood(), "is valuegood");
        uint256 b = self.goodConfig;
        assembly {
            b := shr(1, shl(1, b))
        }
        self.goodConfig = b + 1 * 2 ** 255;
    }

    function updateToNormalGood(S_State storage self) internal {
        require(self.goodConfig.isvaluegood(), "is normalgood");
        uint256 b = self.goodConfig;
        assembly {
            b := shr(1, shl(1, b))
        }
        self.goodConfig = b;
    }

    function updateGoodConfig(S_State storage _self,uint256 _goodConfig)internal{
        assembly {
            _goodConfig := shr(1, shl(1, _goodConfig))
        }
        _self.goodConfig.isvaluegood()
            ? _self.goodConfig = 1 * 2 ** 255 + _goodConfig
            : _self.goodConfig = _goodConfig;
    }

    function init(
        S_State storage self,
        T_BalanceUINT256 _init,
        T_Currency _erc20address,
        uint256 _goodConfig
    ) internal {
        self.currentState = _init;
        self.investState = _init;
        self.goodConfig = _goodConfig;
        self.erc20address = _erc20address;
        self.owner = msg.sender;
    }

    struct swapCache {
        uint128 remainQuanitity;
        uint128 outputQuanitity;
        uint128 feeQuanitity;
        T_BalanceUINT256 good1currentState;
        uint256 good1config;
        T_BalanceUINT256 good2currentState;
        uint256 good2config;
    }
    function swapCompute(
        swapCache memory stepCache,
        T_BalanceUINT256 limitPrice
    ) internal pure returns (swapCache memory) {
        uint128 minValue;
        uint128 minQuanitity;
        uint128 good1;
        uint128 good2;
        while (
            stepCache.remainQuanitity > 0 &&
            getprice(
                stepCache.good1currentState,
                stepCache.good2currentState,
                limitPrice
            )
        ) { 
            good1 = stepCache.good1config.getSwapChips(
                stepCache.good1currentState.amount0()
            );
            good2 = stepCache.good2config.getSwapChips(
                stepCache.good2currentState.amount0()
            );
            minValue = good1 >= good2 ? good2 : good1;
            minQuanitity = stepCache.good1currentState.getamount1fromamount0(
                minValue
            );

            if (stepCache.remainQuanitity > minQuanitity) {
                stepCache.remainQuanitity -= minQuanitity;
                good1 = stepCache.good1config.getSellFee(minQuanitity);
                stepCache.feeQuanitity += good1;
                minQuanitity -= good1;
                minValue = stepCache.good1currentState.getamount0fromamount1(
                    minQuanitity
                );
                stepCache.outputQuanitity += stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);
                stepCache.good1currentState = subadd(
                    stepCache.good1currentState,
                    toBalanceUINT256(minValue, minQuanitity)
                );
                good2 = stepCache.good2currentState.getamount1fromamount0(
                    minValue
                );
                stepCache.good2currentState = addsub(
                    stepCache.good2currentState,
                    toBalanceUINT256(minValue, good2)
                );
            } else {
                good1 = stepCache.good1config.getSellFee(
                    stepCache.remainQuanitity
                );
                stepCache.feeQuanitity += good1;
                stepCache.remainQuanitity -= good1;

                minValue = stepCache.good1currentState.getamount0fromamount1(
                    stepCache.remainQuanitity
                );
                stepCache.outputQuanitity += stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);
                stepCache.good1currentState = subadd(
                    stepCache.good1currentState,
                    toBalanceUINT256(minValue, stepCache.remainQuanitity)
                );
                good2 = stepCache.good2currentState.getamount1fromamount0(
                    minValue
                );
                stepCache.good2currentState = addsub(
                    stepCache.good2currentState,
                    toBalanceUINT256(minValue, good2)
                );
                stepCache.remainQuanitity = 0;
            }
        }
        return stepCache;
    }
    function swapCommit(
        S_State storage _self,
        T_BalanceUINT256 _swapstate,
        uint128 _fee,
        uint256 _marketconfig,
        L_Ralate.S_Ralate calldata _ralate
    ) internal {
        _self.currentState = _swapstate;
        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(_marketconfig.getLiquidFee(_fee), 0);
        allocateFee(_self, _fee, _marketconfig, _ralate);

    }

    function investGood(
        S_State storage _self,
        uint128 _invest,
        uint256 _marketConfig,
        L_Ralate.S_Ralate calldata _ralate
    ) internal returns (S_GoodInvestReturn memory investResult_) {
        investResult_.actualInvestQuantity =
            _invest -
            _self.goodConfig.getInvestFee(_invest);

        investResult_.actualInvestValue = _self
            .currentState
            .getamount0fromamount1(investResult_.actualInvestQuantity);

        investResult_.contructFeeQuantity = toBalanceUINT256(
            _self.feeQunitityState.amount0(),
            _self.investState.amount1()
        ).getamount0fromamount1(investResult_.actualInvestQuantity);

        investResult_.actualFeeQuantity = _marketConfig.getLiquidFee(
            _invest - investResult_.actualInvestQuantity
        );

        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(
                investResult_.actualFeeQuantity +
                    investResult_.contructFeeQuantity,
                investResult_.contructFeeQuantity
            );
        _self.currentState =
            _self.currentState +
            toBalanceUINT256(
                investResult_.actualInvestValue,
                investResult_.actualInvestQuantity
            );
        _self.investState =
            _self.investState +
            toBalanceUINT256(
                investResult_.actualInvestValue,
                investResult_.actualInvestQuantity
            );
        allocateFee(
            _self,
            _invest - investResult_.actualInvestQuantity,
            _marketConfig,
            _ralate
        );
    }

    //disinvestResult_ amount0为投资收益 amount1为实际产生手续费
    function disinvestValueGood(
        S_State storage _self,
        S_ProofState storage _investProof,
        uint128 _goodQuantity,
        uint256 _marketconfig,
        L_Ralate.S_Ralate calldata _ralate
    ) internal returns (T_BalanceUINT256 disinvestResult_) {
        disinvestResult_ = toBalanceUINT256(
            toBalanceUINT256(
                _investProof.state.amount0(),
                _investProof.invest.amount1()
            ).getamount0fromamount1(_goodQuantity),
            _goodQuantity
        );
        require(
            disinvestResult_.amount0() < _self.goodConfig.getDisinvestChips(_self.currentState.amount0()),
            "value good value not enough"
        );
        require(
            _goodQuantity < _self.goodConfig.getDisinvestChips(_self.currentState.amount1()),
            "value good quantity not enough"
        );
        _self.currentState = _self.currentState - disinvestResult_;

        _self.investState = _self.investState - disinvestResult_;

        _investProof.burnValueProofSome(_goodQuantity);

        disinvestResult_ = toBalanceUINT256(
            toBalanceUINT256(
                _self.feeQunitityState.amount0(),
                _self.investState.amount1()
            ).getamount0fromamount1(_goodQuantity),
            _investProof.invest.getamount0fromamount1(_goodQuantity)
        );

        _self.feeQunitityState = _self.feeQunitityState - disinvestResult_;

        disinvestResult_ = toBalanceUINT256(
            disinvestResult_.amount0() - disinvestResult_.amount1(),
            _self.goodConfig.getDisinvestFee(_goodQuantity)
        );

        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(
                _marketconfig.getLiquidFee(disinvestResult_.amount1()),
                0
            );

        allocateFee(_self, disinvestResult_.amount1(), _marketconfig, _ralate);
    }

    function disinvestNormalGood(
        S_State storage _self,
        S_State storage _valueGoodState,
        S_ProofState storage _investProof,
        uint128 _goodQuantity,
        uint256 _marketconfig,
        L_Ralate.S_Ralate calldata _ralate
    )
        internal
        returns (
            T_BalanceUINT256 NormalGoodResult1_,
            T_BalanceUINT256 ValueGoodResult2_,
            uint128 valequanity_
        )
    {
        NormalGoodResult1_ = toBalanceUINT256(
            toBalanceUINT256(
                _investProof.state.amount0(),
                _investProof.invest.amount1()
            ).getamount0fromamount1(_goodQuantity),
            _goodQuantity
        );
        valequanity_ = toBalanceUINT256(
            _investProof.valueinvest.amount1(),
            _investProof.invest.amount1()
        ).getamount0fromamount1(_goodQuantity);

        require(
            NormalGoodResult1_.amount0() <
                _valueGoodState.goodConfig.getDisinvestChips(_valueGoodState.currentState.amount0()),
            "normal good value not enough"
        );
        require(
            valequanity_ < _valueGoodState.goodConfig.getDisinvestChips(_valueGoodState.currentState.amount1()),
            "value good quantiy not enough"
        );
        require(
            NormalGoodResult1_.amount0() < _self.goodConfig.getDisinvestChips(_self.currentState.amount0()),
            "value good value not enough"
        );
        require(
            NormalGoodResult1_.amount1() < _self.goodConfig.getDisinvestChips(_self.currentState.amount1()),
            "normal good quanity not enough"
        );
        _self.currentState = _self.currentState - NormalGoodResult1_;
        _self.investState = _self.investState - NormalGoodResult1_;

        NormalGoodResult1_ = toBalanceUINT256(
            toBalanceUINT256(
                _self.feeQunitityState.amount0(),
                _self.investState.amount1()
            ).getamount0fromamount1(_goodQuantity),
            _investProof.invest.getamount0fromamount1(_goodQuantity)
        );
        _self.feeQunitityState = _self.feeQunitityState - NormalGoodResult1_;
        NormalGoodResult1_ = toBalanceUINT256(
            NormalGoodResult1_.amount0() - NormalGoodResult1_.amount1(),
            _self.goodConfig.getDisinvestFee(_goodQuantity)
        );

        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(
                _marketconfig.getLiquidFee(NormalGoodResult1_.amount1()),
                0
            );
        allocateFee(
            _valueGoodState,
            NormalGoodResult1_.amount1(),
            _marketconfig,
            _ralate
        );

        ValueGoodResult2_ = toBalanceUINT256(
            toBalanceUINT256(
                _investProof.state.amount0(),
                _investProof.valueinvest.amount1()
            ).getamount0fromamount1(valequanity_),
            _goodQuantity
        );
        _valueGoodState.currentState =
            _valueGoodState.currentState -
            ValueGoodResult2_;
        _valueGoodState.investState =
            _valueGoodState.investState -
            ValueGoodResult2_;

        ValueGoodResult2_ = toBalanceUINT256(
            toBalanceUINT256(
                _valueGoodState.feeQunitityState.amount0(),
                _valueGoodState.investState.amount1()
            ).getamount0fromamount1(valequanity_),
            _investProof.valueinvest.getamount0fromamount1(valequanity_)
        );

        _valueGoodState.feeQunitityState =
            _valueGoodState.feeQunitityState -
            ValueGoodResult2_;
        ValueGoodResult2_ = toBalanceUINT256(
            ValueGoodResult2_.amount0() - ValueGoodResult2_.amount1(),
            _valueGoodState.goodConfig.getDisinvestFee(valequanity_)
        );

        _valueGoodState.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(
                _marketconfig.getLiquidFee(ValueGoodResult2_.amount1()),
                0
            );
        allocateFee(_self, ValueGoodResult2_.amount1(), _marketconfig, _ralate);

        _investProof.burnNormalProofSome(_goodQuantity);
        allocateFee(
            _valueGoodState,
            ValueGoodResult2_.amount1(),
            _marketconfig,
            _ralate
        );
    }

    function allocateFee(
        S_State storage _self,
        uint128 _actualFeeQuantity,
        uint256 _marketconfig,
        L_Ralate.S_Ralate calldata _ralate
    ) private {
        if (_ralate.refer == address(0)) {
            _self.fees[_self.owner] +=
                _marketconfig.getSellerFee(_actualFeeQuantity) +
                _marketconfig.getCustomerFee(_actualFeeQuantity);
            _self.fees[_ralate.gater] +=
                _marketconfig.getGaterFee(_actualFeeQuantity) +
                _marketconfig.getReferFee(_actualFeeQuantity);
        } else {
            _self.fees[_self.owner] += _marketconfig.getSellerFee(
                _actualFeeQuantity
            );

            _self.fees[_ralate.gater] += _marketconfig.getGaterFee(
                _actualFeeQuantity
            );

            _self.fees[_ralate.refer] += _marketconfig.getReferFee(
                _actualFeeQuantity
            );

            _self.fees[msg.sender] += _marketconfig.getCustomerFee(
                _actualFeeQuantity
            );
        }
    }
}
