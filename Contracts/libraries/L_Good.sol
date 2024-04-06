// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {L_Proof} from "./L_Proof.sol";
import {SafeCast} from "./SafeCast.sol";
import {L_MarketConfigLibrary} from "./L_MarketConfig.sol";
import {L_GoodConfigLibrary} from "./L_GoodConfig.sol";

import {S_GoodInvestReturn, S_Ralate, S_ProofState, S_GoodState, S_GoodKey} from "./L_Struct.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd, getprice} from "./L_BalanceUINT256.sol";

library L_Good {
    using SafeCast for *;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_BalanceUINT256Library for uint256;
    using L_Proof for S_ProofState;

    function getMaxTradeValue(
        S_GoodState storage self
    ) internal view returns (uint128) {
        return self.goodConfig.getSwapChips(self.currentState.amount0());
    }

    function getMaxTradeQunitity(
        S_GoodState storage self
    ) internal view returns (uint128) {
        return self.goodConfig.getSwapChips(self.currentState.amount1());
    }

    function updateToValueGood(S_GoodState storage self) internal {
        require(!self.goodConfig.isvaluegood(), "is valuegood");
        uint256 b = self.goodConfig;
        assembly {
            b := shr(1, shl(1, b))
        }
        self.goodConfig = b + 1 * 2 ** 255;
    }

    function updateToNormalGood(S_GoodState storage self) internal {
        require(self.goodConfig.isvaluegood(), "is normalgood");
        uint256 b = self.goodConfig;
        assembly {
            b := shr(1, shl(1, b))
        }
        self.goodConfig = b;
    }

    function updateGoodConfig(
        S_GoodState storage _self,
        uint256 _goodConfig
    ) internal {
        assembly {
            _goodConfig := shr(1, shl(1, _goodConfig))
        }
        _self.goodConfig.isvaluegood()
            ? _self.goodConfig = 1 * 2 ** 255 + _goodConfig
            : _self.goodConfig = _goodConfig;
    }

    function init(
        S_GoodState storage self,
        T_BalanceUINT256 _init,
        address _erc20address,
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

    function swapCompute1(
        swapCache memory _stepCache,
        T_BalanceUINT256 _limitPrice
    ) internal pure returns (swapCache memory) {
        uint128 minValue;
        uint128 minQuanitity;
        uint128 good1;
        uint128 good2;
        _stepCache.feeQuanitity = _stepCache.good1config.getSellFee(
            _stepCache.remainQuanitity
        );

        _stepCache.remainQuanitity -= _stepCache.feeQuanitity;
        while (
            _stepCache.remainQuanitity > 0 &&
            getprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) {
            good1 = _stepCache.good1config.getSwapChips(
                _stepCache.good1currentState.amount0()
            );

            good2 = _stepCache.good2config.getSwapChips(
                _stepCache.good2currentState.amount0()
            );

            minValue = good1 >= good2 ? good2 : good1;
            minQuanitity = _stepCache.good1currentState.getamount1fromamount0(
                minValue
            );

            if (_stepCache.remainQuanitity > minQuanitity) {
                _stepCache.remainQuanitity -= minQuanitity;

                minQuanitity -= good1;
                minValue = _stepCache.good1currentState.getamount0fromamount1(
                    minQuanitity
                );

                _stepCache.outputQuanitity += _stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);

                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(minValue, minQuanitity)
                );

                good2 = _stepCache.good2currentState.getamount1fromamount0(
                    minValue
                );

                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(minValue, good2)
                );
            } else {
                minValue = _stepCache.good1currentState.getamount0fromamount1(
                    _stepCache.remainQuanitity
                );

                _stepCache.outputQuanitity += _stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);

                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(minValue, _stepCache.remainQuanitity)
                );

                good2 = _stepCache.good2currentState.getamount1fromamount0(
                    minValue
                );

                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(minValue, good2)
                );

                _stepCache.remainQuanitity = 0;
            }
        }

        if (_stepCache.remainQuanitity > 0) {
            _stepCache.feeQuanitity -= _stepCache.good1config.getSellerFee(
                _stepCache.remainQuanitity
            );
        }

        return _stepCache;
    }

    function swapCompute2(
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
            minQuanitity = stepCache.good2currentState.getamount1fromamount0(
                minValue
            );

            if (stepCache.remainQuanitity > minQuanitity) {
                stepCache.remainQuanitity -= minQuanitity;
                minValue = stepCache.good1currentState.getamount0fromamount1(
                    minQuanitity
                );
                stepCache.outputQuanitity += stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);
                stepCache.good2currentState = addsub(
                    stepCache.good2currentState,
                    toBalanceUINT256(minValue, minQuanitity)
                );
                good1 = stepCache.good2currentState.getamount1fromamount0(
                    minValue
                );
                stepCache.good1currentState = subadd(
                    stepCache.good2currentState,
                    toBalanceUINT256(minValue, good2)
                );
            } else {
                minValue = stepCache.good2currentState.getamount0fromamount1(
                    stepCache.remainQuanitity
                );
                stepCache.outputQuanitity += stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);
                stepCache.good2currentState = addsub(
                    stepCache.good2currentState,
                    toBalanceUINT256(minValue, stepCache.remainQuanitity)
                );
                good1 = stepCache.good1currentState.getamount1fromamount0(
                    minValue
                );
                stepCache.good1currentState = subadd(
                    stepCache.good1currentState,
                    toBalanceUINT256(minValue, good2)
                );
                stepCache.remainQuanitity = 0;
            }
        }
        return stepCache;
    }

    function swapCommit(
        S_GoodState storage _self,
        T_BalanceUINT256 _swapstate,
        uint128 _fee,
        uint256 _marketconfig,
        S_Ralate memory _ralate
    ) internal {
        _self.currentState = _swapstate;
        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(_marketconfig.getLiquidFee(_fee), 0);
        allocateFee(_self, _fee, _marketconfig, _ralate);
    }

    function investGood(
        S_GoodState storage _self,
        uint128 _invest,
        uint256 _marketConfig,
        S_Ralate memory _ralate
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
        S_GoodState storage _self,
        S_ProofState storage _investProof,
        uint128 _goodQuantity,
        uint256 _marketconfig,
        S_Ralate memory _ralate
    ) internal returns (T_BalanceUINT256 disinvestResult_) {
        disinvestResult_ = toBalanceUINT256(
            toBalanceUINT256(
                _investProof.state.amount0(),
                _investProof.invest.amount1()
            ).getamount0fromamount1(_goodQuantity),
            _goodQuantity
        );
        require(
            disinvestResult_.amount0() <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount0()
                ),
            "value good value not enough"
        );
        require(
            _goodQuantity <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount1()
                ),
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
        S_GoodState storage _self,
        S_GoodState storage _valueGoodState,
        S_ProofState storage _investProof,
        uint128 _goodQuantity,
        uint256 _marketconfig,
        S_Ralate memory _ralate
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
                _valueGoodState.goodConfig.getDisinvestChips(
                    _valueGoodState.currentState.amount0()
                ),
            "normal good value not enough"
        );
        require(
            valequanity_ <
                _valueGoodState.goodConfig.getDisinvestChips(
                    _valueGoodState.currentState.amount1()
                ),
            "value good quantiy not enough"
        );
        require(
            NormalGoodResult1_.amount0() <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount0()
                ),
            "value good value not enough"
        );
        require(
            NormalGoodResult1_.amount1() <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount1()
                ),
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

        if (NormalGoodResult1_.amount1() > 0)
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
            _valueGoodState.feeQunitityState +
            toBalanceUINT256(
                _marketconfig.getLiquidFee(ValueGoodResult2_.amount1()),
                0
            );

        _investProof.burnNormalProofSome(_goodQuantity);
        if (ValueGoodResult2_.amount1() > 0)
            allocateFee(
                _valueGoodState,
                ValueGoodResult2_.amount1(),
                _marketconfig,
                _ralate
            );
    }
    function allocateFee(
        S_GoodState storage _self,
        uint128 _actualFeeQuantity,
        uint256 _marketconfig,
        S_Ralate memory _ralate
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

library L_GoodIdLibrary {
    function toId(S_GoodKey memory goodKey) internal pure returns (bytes32) {
        return keccak256(abi.encode(goodKey));
    }
}
