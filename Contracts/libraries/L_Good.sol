// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {L_Proof} from "./L_Proof.sol";
import {L_MarketConfigLibrary} from "./L_MarketConfig.sol";
import {L_GoodConfigLibrary} from "./L_GoodConfig.sol";
import {S_GoodKey} from "./L_Struct.sol";
import {L_CurrencyLibrary} from "./L_Currency.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd, lowerprice} from "./L_BalanceUINT256.sol";

library L_Good {
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_BalanceUINT256Library for uint256;
    using L_Proof for L_Proof.S_ProofState;
    using L_CurrencyLibrary for address;

    struct S_GoodState {
        uint256 goodConfig; //商品配置refer to goodConfig
        address owner; //商品创建者 good's creator
        address erc20address; //商品的erc20合约地址good's erc20address
        T_BalanceUINT256 currentState; //前128位表示商品的价值,后128位表示商品数量 amount0:the good's total value ,amount1:the good's quantity
        T_BalanceUINT256 investState; //前128位表示商品的投资总价值,后128位表示商品投资总数量 amount0:the good's total invest value,amount1:the good's total invest quantity
        T_BalanceUINT256 feeQunitityState; //前128位表示商品的手续费总额(包含构建手续费),后128位表示商品的构建手续费总额 amount0:the good's total fee quantity which contain contruct fee,amount1:the good's total contruct fee.
        mapping(address => uint128) fees;
    }

    struct S_GoodTmpState {
        uint256 goodConfig; //商品配置refer to goodConfig
        address owner; //商品创建者 good's creator
        address erc20address; //商品的erc20合约地址good's erc20address
        T_BalanceUINT256 currentState; //前128位表示商品的价值,后128位表示商品数量 amount0:the good's total value ,amount1:the good's quantity
        T_BalanceUINT256 investState; //前128位表示商品的投资总价值,后128位表示商品投资总数量 amount0:the good's total invest value,amount1:the good's total invest quantity
        T_BalanceUINT256 feeQunitityState; //前128位表示商品的手续费总额(包含构建手续费),后128位表示商品的构建手续费总额 amount0:the good's total fee quantity which contain contruct fee,amount1:the good's total contruct fee.
    }

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

    function updateGoodConfig(
        S_GoodState storage _self,
        uint256 _goodConfig
    ) internal {
        assembly {
            _goodConfig := shr(33, shl(33, _goodConfig))
        }
        _self.goodConfig = ((_self.goodConfig >> 223) << 223) + _goodConfig;
    }

    function init(
        S_GoodState storage self,
        T_BalanceUINT256 _init,
        address _erc20address,
        uint256 _goodConfig
    ) internal {
        self.currentState = _init;
        self.investState = _init;
        assembly {
            _goodConfig := shr(33, shl(33, _goodConfig))
        }
        self.goodConfig = _goodConfig;
        self.erc20address = _erc20address;
        self.owner = msg.sender;
    }

    struct swapCache {
        uint128 remainQuantity;
        uint128 outputQuantity;
        uint128 feeQuantity;
        uint128 swapvalue;
        T_BalanceUINT256 good1currentState;
        uint256 good1config;
        T_BalanceUINT256 good2currentState;
        uint256 good2config;
    }

    function swapCompute1(
        swapCache memory _stepCache,
        T_BalanceUINT256 _limitPrice
    ) internal pure returns (swapCache memory) {
        if (
            !lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) return _stepCache;

        uint128 minValue;
        uint128 minQuantity;
        _stepCache.feeQuantity = _stepCache.good1config.getSellFee(
            _stepCache.remainQuantity
        );
        _stepCache.remainQuantity -= _stepCache.feeQuantity;
        while (
            _stepCache.remainQuantity > 0 &&
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) {
            minValue = _stepCache.good1config.getSwapChips(
                _stepCache.good1currentState.amount0()
            ) >=
                _stepCache.good2config.getSwapChips(
                    _stepCache.good2currentState.amount0()
                )
                ? _stepCache.good2config.getSwapChips(
                    _stepCache.good2currentState.amount0()
                )
                : _stepCache.good1config.getSwapChips(
                    _stepCache.good1currentState.amount0()
                );
            minQuantity = _stepCache.good1currentState.getamount1fromamount0(
                minValue
            );
            if (_stepCache.remainQuantity > minQuantity) {
                _stepCache.remainQuantity -= minQuantity;

                _stepCache.outputQuantity += _stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);

                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(minValue, minQuantity)
                );
                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(
                        minValue,
                        _stepCache.good2currentState.getamount1fromamount0(
                            minValue
                        )
                    )
                );
            } else {
                minValue = _stepCache.good1currentState.getamount0fromamount1(
                    _stepCache.remainQuantity
                );
                _stepCache.outputQuantity += _stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);

                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(minValue, _stepCache.remainQuantity)
                );

                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(
                        minValue,
                        _stepCache.good2currentState.getamount1fromamount0(
                            minValue
                        )
                    )
                );
                _stepCache.remainQuantity = 0;
            }

            _stepCache.swapvalue += minValue;
        }

        if (_stepCache.remainQuantity > 0) {
            _stepCache.feeQuantity -= _stepCache.good1config.getSellFee(
                _stepCache.remainQuantity
            );

            _stepCache.remainQuantity += _stepCache.good1config.getSellFee(
                _stepCache.remainQuantity
            );
        }
        return _stepCache;
    }

    function swapCompute2(
        swapCache memory _stepCache,
        T_BalanceUINT256 _limitPrice
    ) internal pure returns (swapCache memory) {
        if (
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) return _stepCache;
        uint128 minValue;
        uint128 minQuantity;
        _stepCache.feeQuantity = _stepCache.good2config.getBuyFee(
            _stepCache.remainQuantity
        );
        while (
            _stepCache.remainQuantity > 0 &&
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) {
            minValue = _stepCache.good1config.getSwapChips(
                _stepCache.good1currentState.amount0()
            ) >=
                _stepCache.good2config.getSwapChips(
                    _stepCache.good2currentState.amount0()
                )
                ? _stepCache.good2config.getSwapChips(
                    _stepCache.good2currentState.amount0()
                )
                : _stepCache.good1config.getSwapChips(
                    _stepCache.good1currentState.amount0()
                );
            minQuantity = _stepCache.good2currentState.getamount1fromamount0(
                minValue
            );

            if (_stepCache.remainQuantity > minQuantity) {
                _stepCache.remainQuantity -= minQuantity;

                _stepCache.outputQuantity += _stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);
                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(minValue, minQuantity)
                );
                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(
                        minValue,
                        _stepCache.good1currentState.getamount1fromamount0(
                            minValue
                        )
                    )
                );
            } else {
                minValue = _stepCache.good2currentState.getamount0fromamount1(
                    _stepCache.remainQuantity
                );
                _stepCache.outputQuantity += _stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);
                _stepCache.good2currentState = addsub(
                    _stepCache.good2currentState,
                    toBalanceUINT256(minValue, _stepCache.remainQuantity)
                );

                _stepCache.good1currentState = subadd(
                    _stepCache.good1currentState,
                    toBalanceUINT256(
                        minValue,
                        _stepCache.good1currentState.getamount1fromamount0(
                            minValue
                        )
                    )
                );
                _stepCache.remainQuantity = 0;
            }
            _stepCache.swapvalue += minValue;
        }
        return _stepCache;
    }

    function swapCommit(
        S_GoodState storage _self,
        T_BalanceUINT256 _swapstate,
        uint128 _fee
    ) internal {
        _self.currentState = _swapstate;
        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(_fee, 0);
    }

    struct S_GoodInvestReturn {
        uint128 actualFeeQuantity; //实际手续费
        uint128 contructFeeQuantity; //构建手续费
        uint128 actualInvestValue; //实际投资价值
        uint128 actualInvestQuantity; //实际投资数量
    }
    function investGood(
        S_GoodState storage _self,
        uint128 _invest
    ) internal returns (S_GoodInvestReturn memory investResult_) {
        investResult_.actualFeeQuantity = _self.goodConfig.getInvestFee(
            _invest
        );
        investResult_.actualInvestQuantity =
            _invest -
            investResult_.actualFeeQuantity;

        investResult_.actualInvestValue = _self
            .currentState
            .getamount0fromamount1(investResult_.actualInvestQuantity);

        investResult_.contructFeeQuantity = toBalanceUINT256(
            _self.feeQunitityState.amount0(),
            _self.investState.amount1()
        ).getamount0fromamount1(investResult_.actualInvestQuantity);

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
    }

    struct S_GoodDisinvestReturn {
        uint128 profit; //实际手续费
        uint128 actual_fee; //构建手续费
        uint128 actualDisinvestQuantity; //实际撤资数量
    }

    struct S_GoodDisinvestParam {
        uint128 _goodQuantity;
        address _gater;
        address _referal;
        uint256 _marketconfig;
        address _marketcreator;
    }
    function disinvestGood(
        S_GoodState storage _self,
        S_GoodState storage _valueGoodState,
        L_Proof.S_ProofState storage _investProof,
        S_GoodDisinvestParam memory _params
    )
        internal
        returns (
            S_GoodDisinvestReturn memory normalGoodResult1_,
            S_GoodDisinvestReturn memory valueGoodResult2_,
            uint128 disinvestvalue
        )
    {
        disinvestvalue = toBalanceUINT256(
            _investProof.state.amount0(),
            _investProof.invest.amount1()
        ).getamount0fromamount1(_params._goodQuantity);

        normalGoodResult1_ = S_GoodDisinvestReturn(
            toBalanceUINT256(
                _self.feeQunitityState.amount0(),
                _self.investState.amount1()
            ).getamount0fromamount1(_params._goodQuantity),
            toBalanceUINT256(
                _investProof.invest.amount0(),
                _investProof.invest.amount1()
            ).getamount0fromamount1(_params._goodQuantity),
            _params._goodQuantity
        );

        require(
            (_self.goodConfig.isvaluegood() ||
                _valueGoodState.goodConfig.isvaluegood()) &&
                disinvestvalue <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount0()
                ) &&
                _params._goodQuantity <
                _self.goodConfig.getDisinvestChips(
                    _self.currentState.amount1()
                ),
            "G011"
        );

        _self.currentState =
            _self.currentState -
            toBalanceUINT256(
                disinvestvalue,
                normalGoodResult1_.actualDisinvestQuantity
            );

        _self.investState =
            _self.investState -
            toBalanceUINT256(
                disinvestvalue,
                normalGoodResult1_.actualDisinvestQuantity
            );

        _self.feeQunitityState =
            _self.feeQunitityState -
            toBalanceUINT256(
                normalGoodResult1_.profit,
                normalGoodResult1_.actual_fee
            );

        _investProof.burnProof(disinvestvalue);

        normalGoodResult1_.profit =
            normalGoodResult1_.profit -
            normalGoodResult1_.actual_fee;

        normalGoodResult1_.actual_fee = _self.goodConfig.getDisinvestFee(
            normalGoodResult1_.actualDisinvestQuantity
        );

        allocateFee(
            _self,
            normalGoodResult1_.profit,
            _params._marketconfig,
            _params._gater,
            _params._referal,
            _params._marketcreator,
            normalGoodResult1_.actualDisinvestQuantity -
                normalGoodResult1_.actual_fee
        );

        if (normalGoodResult1_.actual_fee > 0) {
            _self.feeQunitityState =
                _self.feeQunitityState +
                toBalanceUINT256(normalGoodResult1_.actual_fee, 0);
        }

        if (_investProof.valuegood != 0) {
            valueGoodResult2_ = S_GoodDisinvestReturn(
                toBalanceUINT256(
                    _valueGoodState.feeQunitityState.amount0(),
                    _valueGoodState.investState.amount1()
                ).getamount0fromamount1(disinvestvalue),
                toBalanceUINT256(
                    _investProof.valueinvest.amount0(),
                    _investProof.valueinvest.amount1()
                ).getamount0fromamount1(disinvestvalue),
                toBalanceUINT256(
                    _investProof.state.amount0(),
                    _investProof.valueinvest.amount1()
                ).getamount1fromamount0(disinvestvalue)
            );

            require(
                disinvestvalue <
                    _valueGoodState.goodConfig.getDisinvestChips(
                        _valueGoodState.currentState.amount0()
                    ) &&
                    valueGoodResult2_.actualDisinvestQuantity <
                    _valueGoodState.goodConfig.getDisinvestChips(
                        _valueGoodState.currentState.amount1()
                    ),
                "G012"
            );

            _valueGoodState.currentState =
                _valueGoodState.currentState -
                toBalanceUINT256(
                    disinvestvalue,
                    valueGoodResult2_.actualDisinvestQuantity
                );

            _valueGoodState.investState =
                _valueGoodState.investState -
                toBalanceUINT256(
                    disinvestvalue,
                    valueGoodResult2_.actualDisinvestQuantity
                );

            _valueGoodState.feeQunitityState =
                _valueGoodState.feeQunitityState -
                toBalanceUINT256(
                    valueGoodResult2_.profit,
                    valueGoodResult2_.actual_fee
                );

            valueGoodResult2_.profit =
                valueGoodResult2_.profit -
                valueGoodResult2_.actual_fee;

            valueGoodResult2_.actual_fee = _valueGoodState
                .goodConfig
                .getDisinvestFee(valueGoodResult2_.actualDisinvestQuantity);

            if (valueGoodResult2_.actual_fee > 0) {
                _valueGoodState.feeQunitityState =
                    _valueGoodState.feeQunitityState +
                    toBalanceUINT256(valueGoodResult2_.actual_fee, 0);
            }
            allocateFee(
                _valueGoodState,
                valueGoodResult2_.profit,
                _params._marketconfig,
                _params._gater,
                _params._referal,
                _params._marketcreator,
                valueGoodResult2_.actualDisinvestQuantity -
                    valueGoodResult2_.actual_fee
            );
        }
    }
    function collectGoodFee(
        S_GoodState storage _self,
        S_GoodState storage _valuegood,
        L_Proof.S_ProofState storage _investProof,
        address _gater,
        address _referal,
        uint256 _marketconfig,
        address _marketcreator
    ) internal returns (T_BalanceUINT256 profit) {
        uint128 profit1 = toBalanceUINT256(
            _self.feeQunitityState.amount0(),
            _self.investState.amount1()
        ).getamount0fromamount1(_investProof.invest.amount1()) -
            _investProof.invest.amount0();

        _self.feeQunitityState =
            _self.feeQunitityState +
            toBalanceUINT256(0, profit1);

        allocateFee(
            _self,
            profit1,
            _marketconfig,
            _gater,
            _referal,
            _marketcreator,
            0
        );
        uint128 profit2;
        if (_valuegood.goodConfig >= 0) {
            profit2 =
                toBalanceUINT256(
                    _valuegood.feeQunitityState.amount0(),
                    _valuegood.investState.amount1()
                ).getamount0fromamount1(_investProof.valueinvest.amount1()) -
                _investProof.valueinvest.amount0();
            _valuegood.feeQunitityState =
                _valuegood.feeQunitityState +
                toBalanceUINT256(0, profit2);
            allocateFee(
                _valuegood,
                profit2,
                _marketconfig,
                _gater,
                _referal,
                _marketcreator,
                0
            );
        }
        profit = toBalanceUINT256(profit1, profit2);
        _investProof.collectProofFee(profit);
    }

    function allocateFee(
        S_GoodState storage _self,
        uint128 _profit,
        uint256 _marketconfig,
        address _gater,
        address _referal,
        address _marketcreator,
        uint128 _divestquantity
    ) private {
        uint128 marketfee = _marketconfig.getPlatFee128(_profit);
        _profit -= marketfee;
        uint128 temfee1;
        uint128 temfee2;
        if (_referal == address(0)) {
            temfee1 = _marketconfig.getLiquidFee(_profit);
            _self.erc20address.safeTransfer(
                msg.sender,
                temfee1 + _divestquantity
            );
            temfee2 =
                _marketconfig.getSellerFee(_profit) +
                _marketconfig.getCustomerFee(_profit);
            _self.fees[_gater] += temfee2;
            _self.fees[_marketcreator] += (_profit -
                temfee1 -
                temfee2 +
                marketfee);
        } else {
            if (_self.owner == _marketcreator) {
                marketfee += _marketconfig.getSellerFee(_profit);
            } else {
                _self.fees[_self.owner] += _marketconfig.getSellerFee(_profit);
            }
            if (_gater == _marketcreator) {
                marketfee += _marketconfig.getGaterFee(_profit);
            } else {
                _self.fees[_gater] += _marketconfig.getGaterFee(_profit);
            }
            if (_referal == _marketcreator) {
                marketfee += _marketconfig.getReferFee(_profit);
            } else {
                _self.fees[_referal] += _marketconfig.getReferFee(_profit);
            }
            _self.fees[_marketcreator] += marketfee;
            _self.erc20address.safeTransfer(
                msg.sender,
                _marketconfig.getLiquidFee(_profit) +
                    _marketconfig.getCustomerFee(_profit) +
                    _divestquantity
            );
        }
    }
    function modifyGoodConfig(
        S_GoodState storage _self,
        uint256 _goodconfig
    ) internal {
        _self.goodConfig =
            (_self.goodConfig % (2 ** 223)) +
            (_goodconfig << 223);
    }
}

library L_GoodIdLibrary {
    function toId(S_GoodKey memory goodKey) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(goodKey)));
    }
}
