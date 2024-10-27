// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {L_Proof} from "./L_Proof.sol";
import {L_MarketConfigLibrary} from "./L_MarketConfig.sol";
import {L_GoodConfigLibrary} from "./L_GoodConfig.sol";
import {L_CurrencyLibrary} from "./L_Currency.sol";

import {S_GoodState, S_GoodKey, S_ProofState, S_takeGoodInputPrams} from "../interfaces/I_TTSwap_Market.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, add, sub, addsub, subadd, lowerprice} from "./L_TTSwapUINT256.sol";

/**
 * @title L_Good Library
 * @dev A library for managing goods in a decentralized marketplace
 * @notice This library provides functions for investing, disinvesting, swapping, and fee management for goods
 */
library L_TakeLimitPriceOrder {
    using L_GoodConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_TakeLimitPriceOrder for S_takeGoodCache;
    struct S_takeGoodCache {
        uint128 remainQuantity; // Remaining quantity to be swapped
        uint128 outputQuantity; // Quantity received from the swap
        uint128 feeQuantity; // Fee amount for the swap
        uint128 swapvalue; // Total value of the swap
        uint128 goodid2FeeQuantity_;
        uint128 goodid2Quantity_;
        uint256 good1currentState; // Current state of the first good
        uint256 good1config; // Configuration of the first good
        uint256 good2currentState; // Current state of the second good
        uint256 good2config; // Configuration of the second good
        uint256 limitPrice;
    }
    function init_takeGoodCache(
        S_takeGoodCache memory _stepCache,
        S_takeGoodInputPrams memory inputdata,
        uint256 _good1curstate,
        uint256 _good1config,
        uint256 _good2curstate,
        uint256 _good2config,
        uint96 _tolerance
    ) internal pure {
        _stepCache.remainQuantity = inputdata._swapQuantity.amount0();
        _stepCache.good1currentState = _good1curstate;
        _stepCache.good1config = _good1config;
        _stepCache.good2currentState = _good2curstate;
        _stepCache.good2config = _good2config;
        uint256 a = _stepCache.good1currentState.amount1() *
            _stepCache.good2currentState.amount0();
        uint256 b = _stepCache.good1currentState.amount1() *
            _stepCache.good2currentState.amount0();
        a = a + a * _tolerance;
        if (a >= b) {
            _stepCache.limitPrice = ((a * 10000) / b) << (128 + 10000);
        } else {
            _stepCache.limitPrice = (10000 << (128 + b / a));
        }
    }

    /**
     * @notice Compute the swap result from good1 to good2
     * @dev Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts
     * @param _stepCache A cache structure containing swap state and configurations
     */
    function takeGoodCompute(S_takeGoodCache memory _stepCache) internal pure {
        // Check if the current price is lower than the limit price, if not, return immediately
        if (_stepCache.isOverPrice()) {
            uint128 minValue;
            uint128 minQuantity;
            // Calculate and deduct the sell fee
            _stepCache.feeQuantity = _stepCache.good1config.getSellFee(
                _stepCache.remainQuantity
            );
            _stepCache.remainQuantity -= _stepCache.feeQuantity;

            // Continue swapping while there's remaining quantity and price is favorable
            while (_stepCache.isOverPrice()) {
                // Determine the minimum swap value (take the smaller of the two goods)
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

                // Calculate the corresponding quantity for the minimum value
                minQuantity = _stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);

                if (_stepCache.remainQuantity > minQuantity) {
                    // Swap the entire minQuantity
                    _stepCache.remainQuantity -= minQuantity;

                    // Calculate and add the output quantity
                    _stepCache.outputQuantity += _stepCache
                        .good2currentState
                        .getamount1fromamount0(minValue);

                    // Update the states of both goods
                    _stepCache.good1currentState = subadd(
                        _stepCache.good1currentState,
                        toTTSwapUINT256(minValue, minQuantity)
                    );
                    _stepCache.good2currentState = addsub(
                        _stepCache.good2currentState,
                        toTTSwapUINT256(
                            minValue,
                            _stepCache.good2currentState.getamount1fromamount0(
                                minValue
                            )
                        )
                    );
                } else {
                    // Swap the remaining quantity
                    minValue = _stepCache
                        .good1currentState
                        .getamount0fromamount1(_stepCache.remainQuantity);
                    _stepCache.outputQuantity += _stepCache
                        .good2currentState
                        .getamount1fromamount0(minValue);

                    // Update the states of both goods
                    _stepCache.good1currentState = subadd(
                        _stepCache.good1currentState,
                        toTTSwapUINT256(minValue, _stepCache.remainQuantity)
                    );

                    _stepCache.good2currentState = addsub(
                        _stepCache.good2currentState,
                        toTTSwapUINT256(
                            minValue,
                            _stepCache.good2currentState.getamount1fromamount0(
                                minValue
                            )
                        )
                    );
                    _stepCache.remainQuantity = 0;
                }

                // Update the total swap value
                _stepCache.swapvalue += minValue;
            }

            // Adjust fees if there's remaining quantity
            if (_stepCache.remainQuantity > 0) {
                _stepCache.feeQuantity -= _stepCache.good1config.getSellFee(
                    _stepCache.remainQuantity
                );

                _stepCache.remainQuantity += _stepCache.good1config.getSellFee(
                    _stepCache.remainQuantity
                );
            }
        }
        _stepCache.goodid2FeeQuantity_ = _stepCache.good2config.getBuyFee(
            _stepCache.outputQuantity
        );
        _stepCache.goodid2Quantity_ =
            _stepCache.outputQuantity -
            _stepCache.goodid2FeeQuantity_;
    }

    function isOverPrice(
        S_takeGoodCache memory _stepCache
    ) internal pure returns (bool) {
        return
            (
                uint256(_stepCache.good1currentState.amount0()) *
                    uint256(_stepCache.good2currentState.amount1()) *
                    uint256(_stepCache.limitPrice.amount1()) >
                    uint256(_stepCache.good1currentState.amount1()) *
                        uint256(_stepCache.good2currentState.amount0()) *
                        uint256(_stepCache.limitPrice.amount0())
                    ? true
                    : false
            ) && _stepCache.remainQuantity > 0;
    }
}
