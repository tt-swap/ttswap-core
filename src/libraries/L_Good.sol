// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {L_Proof} from "./L_Proof.sol";
import {L_MarketConfigLibrary} from "./L_MarketConfig.sol";
import {L_GoodConfigLibrary} from "./L_GoodConfig.sol";
import {S_GoodKey} from "./L_Struct.sol";
import {L_CurrencyLibrary} from "./L_Currency.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd, lowerprice} from "./L_BalanceUINT256.sol";

/**
 * @title L_Good Library
 * @dev A library for managing goods in a decentralized marketplace
 * @notice This library provides functions for investing, disinvesting, swapping, and fee management for goods
 */
library L_Good {
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_BalanceUINT256Library for uint256;
    using L_Proof for L_Proof.S_ProofState;
    using L_CurrencyLibrary for address;

    /**
     * @dev Struct representing the state of a good
     */
    struct S_GoodState {
        uint256 goodConfig; // Configuration of the good
        address owner; // Creator of the good
        address erc20address; // ERC20 token address associated with the good
        T_BalanceUINT256 currentState; // Current state: amount0 (first 128 bits) represents total value, amount1 (last 128 bits) represents quantity
        T_BalanceUINT256 investState; // Investment state: amount0 represents total invested value, amount1 represents total invested quantity
        T_BalanceUINT256 feeQuantityState; // Fee state: amount0 represents total fees (including construction fees), amount1 represents total construction fees
        mapping(address => uint128) commission; // Mapping to store commission amounts for each address
        address trigge;
    }

    /**
     * @dev Struct representing a temporary state of a good
     */
    struct S_GoodTmpState {
        uint256 goodConfig; // Configuration of the good
        address owner; // Creator of the good
        address erc20address; // ERC20 token address associated with the good
        T_BalanceUINT256 currentState; // Current state: amount0 (first 128 bits) represents total value, amount1 (last 128 bits) represents quantity
        T_BalanceUINT256 investState; // Investment state: amount0 represents total invested value, amount1 represents total invested quantity
        T_BalanceUINT256 feeQuantityState; // Fee state: amount0 represents total fees (including construction fees), amount1 represents total construction fees
    }

    /**
     * @notice Update the good configuration
     * @dev Preserves the top 33 bits of the existing config and updates the rest
     * @param _self Storage pointer to the good state
     * @param _goodConfig New configuration value to be applied
     */
    function updateGoodConfig(
        S_GoodState storage _self,
        uint256 _goodConfig
    ) internal {
        // Clear the top 33 bits of the new config
        assembly {
            _goodConfig := shr(33, shl(33, _goodConfig))
        }
        // Preserve the top 33 bits of the existing config and add the new config
        _self.goodConfig = ((_self.goodConfig >> 223) << 223) + _goodConfig;
    }

    /**
     * @notice Initialize the good state
     * @dev Sets up the initial state, configuration, and owner of the good
     * @param self Storage pointer to the good state
     * @param _init Initial balance state
     * @param _erc20address Address of the ERC20 token associated with the good
     * @param _goodConfig Configuration of the good
     */
    function init(
        S_GoodState storage self,
        T_BalanceUINT256 _init,
        address _erc20address,
        uint256 _goodConfig
    ) internal {
        self.currentState = _init;
        self.investState = _init;
        self.goodConfig = (_goodConfig << 33) >> 33;
        self.erc20address = _erc20address;
        self.owner = msg.sender;
    }

    /**
     * @dev Struct to cache swap-related data
     */
    struct swapCache {
        uint128 remainQuantity; // Remaining quantity to be swapped
        uint128 outputQuantity; // Quantity received from the swap
        uint128 feeQuantity; // Fee amount for the swap
        uint128 swapvalue; // Total value of the swap
        T_BalanceUINT256 good1currentState; // Current state of the first good
        uint256 good1config; // Configuration of the first good
        T_BalanceUINT256 good2currentState; // Current state of the second good
        uint256 good2config; // Configuration of the second good
    }

    /**
     * @notice Compute the swap result from good1 to good2
     * @dev Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts
     * @param _stepCache A cache structure containing swap state and configurations
     * @param _limitPrice The price limit for the swap
     * @return Updated swapCache structure containing the swap results
     */
    function swapCompute1(
        swapCache memory _stepCache,
        T_BalanceUINT256 _limitPrice
    ) internal pure returns (swapCache memory) {
        // Check if the current price is lower than the limit price, if not, return immediately
        if (
            !lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) return _stepCache;

        uint128 minValue;
        uint128 minQuantity;

        // Calculate and deduct the sell fee
        _stepCache.feeQuantity = _stepCache.good1config.getSellFee(
            _stepCache.remainQuantity
        );
        _stepCache.remainQuantity -= _stepCache.feeQuantity;

        // Continue swapping while there's remaining quantity and price is favorable
        while (
            _stepCache.remainQuantity > 0 &&
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) {
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
            minQuantity = _stepCache.good1currentState.getamount1fromamount0(
                minValue
            );

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
                // Swap the remaining quantity
                minValue = _stepCache.good1currentState.getamount0fromamount1(
                    _stepCache.remainQuantity
                );
                _stepCache.outputQuantity += _stepCache
                    .good2currentState
                    .getamount1fromamount0(minValue);

                // Update the states of both goods
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
        return _stepCache;
    }

    /**
     * @notice Compute the swap result from good2 to good1
     * @dev Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts
     * @param _stepCache A cache structure containing swap state and configurations
     * @param _limitPrice The price limit for the swap
     * @return Updated swapCache structure containing the swap results
     */
    function swapCompute2(
        swapCache memory _stepCache,
        T_BalanceUINT256 _limitPrice
    ) internal pure returns (swapCache memory) {
        // Check if the current price is higher than the limit price, if so, return immediately
        if (
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) return _stepCache;

        uint128 minValue;
        uint128 minQuantity;

        // Calculate and deduct the buy fee
        _stepCache.feeQuantity = _stepCache.good2config.getBuyFee(
            _stepCache.remainQuantity
        );

        // Continue swapping while there's remaining quantity and price is favorable
        while (
            _stepCache.remainQuantity > 0 &&
            lowerprice(
                _stepCache.good1currentState,
                _stepCache.good2currentState,
                _limitPrice
            )
        ) {
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
            minQuantity = _stepCache.good2currentState.getamount1fromamount0(
                minValue
            );

            if (_stepCache.remainQuantity > minQuantity) {
                // Swap the entire minQuantity
                _stepCache.remainQuantity -= minQuantity;

                // Calculate and add the output quantity
                _stepCache.outputQuantity += _stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);

                // Update the states of both goods
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
                // Swap the remaining quantity
                minValue = _stepCache.good2currentState.getamount0fromamount1(
                    _stepCache.remainQuantity
                );
                _stepCache.outputQuantity += _stepCache
                    .good1currentState
                    .getamount1fromamount0(minValue);

                // Update the states of both goods
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

            // Update the total swap value
            _stepCache.swapvalue += minValue;
        }
        return _stepCache;
    }

    /**
     * @notice Commit the result of a swap operation to the good's state
     * @dev Updates the current state and fee state of the good after a swap
     * @param _self Storage pointer to the good state
     * @param _swapstate The new state of the good after the swap
     * @param _fee The fee amount collected from the swap
     */
    function swapCommit(
        S_GoodState storage _self,
        T_BalanceUINT256 _swapstate,
        uint128 _fee
    ) internal {
        _self.currentState = _swapstate;
        _self.feeQuantityState =
            _self.feeQuantityState +
            toBalanceUINT256(_fee, 0);
    }

    /**
     * @notice Struct to hold the return values of an investment operation
     * @dev Used to store and return the results of investing in a good
     */
    struct S_GoodInvestReturn {
        uint128 actualFeeQuantity; // The actual fee amount charged for the investment
        uint128 constructFeeQuantity; // The construction fee amount (if applicable)
        uint128 actualInvestValue; // The actual value invested after fees
        uint128 actualInvestQuantity; // The actual quantity of goods received for the investment
    }

    /**
     * @notice Invest in a good
     * @dev Calculates fees, updates states, and returns investment results
     * @param _self Storage pointer to the good state
     * @param _invest Amount to invest
     * @return investResult_ Struct containing investment results
     */
    function investGood(
        S_GoodState storage _self,
        uint128 _invest
    ) internal returns (S_GoodInvestReturn memory investResult_) {
        // Calculate the investment fee
        investResult_.actualFeeQuantity = _self.goodConfig.getInvestFee(
            _invest
        );
        // Calculate the actual investment quantity after deducting the fee
        investResult_.actualInvestQuantity =
            _invest -
            investResult_.actualFeeQuantity;

        // Calculate the actual investment value based on the current state
        investResult_.actualInvestValue = _self
            .currentState
            .getamount0fromamount1(investResult_.actualInvestQuantity);

        // Calculate the construction fee
        investResult_.constructFeeQuantity = toBalanceUINT256(
            _self.feeQuantityState.amount0(),
            _self.investState.amount1()
        ).getamount0fromamount1(investResult_.actualInvestQuantity);

        // Update the fee quantity state
        _self.feeQuantityState =
            _self.feeQuantityState +
            toBalanceUINT256(
                investResult_.actualFeeQuantity +
                    investResult_.constructFeeQuantity,
                investResult_.constructFeeQuantity
            );
        // Update the current state with the new investment
        _self.currentState =
            _self.currentState +
            toBalanceUINT256(
                investResult_.actualInvestValue,
                investResult_.actualInvestQuantity
            );
        // Update the invest state with the new investment
        _self.investState =
            _self.investState +
            toBalanceUINT256(
                investResult_.actualInvestValue,
                investResult_.actualInvestQuantity
            );
    }

    /**
     * @notice Struct to hold the return values of a disinvestment operation
     * @dev Used to store and return the results of disinvesting from a good
     */
    struct S_GoodDisinvestReturn {
        uint128 profit; // The profit earned from disinvestment
        uint128 actual_fee; // The actual fee charged for disinvestment
        uint128 actualDisinvestQuantity; // The actual quantity of goods disinvested
    }

    /**
     * @notice Struct to hold the parameters for a disinvestment operation
     * @dev Used to pass multiple parameters to the disinvestGood function
     */
    struct S_GoodDisinvestParam {
        uint128 _goodQuantity; // The quantity of goods to disinvest
        address _gater; // The address of the gater (if applicable)
        address _referral; // The address of the referrer (if applicable)
        uint256 _marketconfig; // The market configuration
        address _marketcreator; // The address of the market creator
    }

    /**
     * @notice Disinvest from a good and potentially its associated value good
     * @dev This function handles the complex process of disinvesting from a good, including fee calculations and state updates
     * @param _self Storage pointer to the main good state
     * @param _valueGoodState Storage pointer to the value good state (if applicable)
     * @param _investProof Storage pointer to the investment proof state
     * @param _params Struct containing disinvestment parameters
     * @return normalGoodResult1_ Struct containing disinvestment results for the main good
     * @return valueGoodResult2_ Struct containing disinvestment results for the value good (if applicable)
     * @return disinvestvalue The total value being disinvested
     */
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
        // Calculate the disinvestment value based on the investment proof and requested quantity
        disinvestvalue = toBalanceUINT256(
            _investProof.state.amount0(),
            _investProof.invest.amount1()
        ).getamount0fromamount1(_params._goodQuantity);

        // Calculate initial disinvestment results for the main good
        normalGoodResult1_ = S_GoodDisinvestReturn(
            toBalanceUINT256(
                _self.feeQuantityState.amount0(),
                _self.investState.amount1()
            ).getamount0fromamount1(_params._goodQuantity),
            toBalanceUINT256(
                _investProof.invest.amount0(),
                _investProof.invest.amount1()
            ).getamount0fromamount1(_params._goodQuantity),
            _params._goodQuantity
        );

        // Ensure disinvestment conditions are met
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

        // Update main good states
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

        _self.feeQuantityState =
            _self.feeQuantityState -
            toBalanceUINT256(
                normalGoodResult1_.profit,
                normalGoodResult1_.actual_fee
            );

        // Burn the investment proof
        _investProof.burnProof(disinvestvalue);

        // Calculate final profit and fee for main good
        normalGoodResult1_.profit =
            normalGoodResult1_.profit -
            normalGoodResult1_.actual_fee;

        normalGoodResult1_.actual_fee = _self.goodConfig.getDisinvestFee(
            normalGoodResult1_.actualDisinvestQuantity
        );

        // Allocate fees for main good
        allocateFee(
            _self,
            normalGoodResult1_.profit,
            _params._marketconfig,
            _params._gater,
            _params._referral,
            _params._marketcreator,
            normalGoodResult1_.actualDisinvestQuantity -
                normalGoodResult1_.actual_fee
        );

        // Update fee state for main good if necessary
        if (normalGoodResult1_.actual_fee > 0) {
            _self.feeQuantityState =
                _self.feeQuantityState +
                toBalanceUINT256(normalGoodResult1_.actual_fee, 0);
        }

        // Handle value good disinvestment if applicable
        if (_investProof.valuegood != 0) {
            // Calculate disinvestment results for value good
            valueGoodResult2_ = S_GoodDisinvestReturn(
                toBalanceUINT256(
                    _valueGoodState.feeQuantityState.amount0(),
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

            // Ensure value good disinvestment conditions are met
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

            // Update value good states
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

            _valueGoodState.feeQuantityState =
                _valueGoodState.feeQuantityState -
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
                _valueGoodState.feeQuantityState =
                    _valueGoodState.feeQuantityState +
                    toBalanceUINT256(valueGoodResult2_.actual_fee, 0);
            }
            allocateFee(
                _valueGoodState,
                valueGoodResult2_.profit,
                _params._marketconfig,
                _params._gater,
                _params._referral,
                _params._marketcreator,
                valueGoodResult2_.actualDisinvestQuantity -
                    valueGoodResult2_.actual_fee
            );
        }
    }

    /**
     * @notice Collect fees for a good and its associated value good
     * @dev This function handles the process of collecting fees for a good and its associated value good, if applicable
     * @param _self Storage pointer to the main good state
     * @param _valuegood Storage pointer to the value good state (if applicable)
     * @param _investProof Storage pointer to the investment proof state
     * @param _gater The address of the gater (if applicable)
     * @param _referral The address of the referrer (if applicable)
     * @param _marketconfig The market configuration
     * @param _marketcreator The address of the market creator
     * @return profit The total profit collected
     */
    function collectGoodFee(
        S_GoodState storage _self,
        S_GoodState storage _valuegood,
        L_Proof.S_ProofState storage _investProof,
        address _gater,
        address _referral,
        uint256 _marketconfig,
        address _marketcreator
    ) internal returns (T_BalanceUINT256 profit) {
        // Calculate profit for the main good
        uint128 profit1 = toBalanceUINT256(
            _self.feeQuantityState.amount0(),
            _self.investState.amount1()
        ).getamount0fromamount1(_investProof.invest.amount1()) -
            _investProof.invest.amount0();

        // Update fee quantity state for the main good
        _self.feeQuantityState =
            _self.feeQuantityState +
            toBalanceUINT256(0, profit1);

        // Allocate fees for the main good
        allocateFee(
            _self,
            profit1,
            _marketconfig,
            _gater,
            _referral,
            _marketcreator,
            0
        );

        uint128 profit2;
        // If value good exists, calculate and allocate its fees
        if (_valuegood.goodConfig >= 0) {
            // Calculate profit for the value good
            profit2 =
                toBalanceUINT256(
                    _valuegood.feeQuantityState.amount0(),
                    _valuegood.investState.amount1()
                ).getamount0fromamount1(_investProof.valueinvest.amount1()) -
                _investProof.valueinvest.amount0();

            // Update fee quantity state for the value good
            _valuegood.feeQuantityState =
                _valuegood.feeQuantityState +
                toBalanceUINT256(0, profit2);

            // Allocate fees for the value good
            allocateFee(
                _valuegood,
                profit2,
                _marketconfig,
                _gater,
                _referral,
                _marketcreator,
                0
            );
        }

        // Combine profits from main good and value good
        profit = toBalanceUINT256(profit1, profit2);

        // Update the investment proof with collected fees
        _investProof.collectProofFee(profit);
    }

    /**
     * @notice Allocate fees to various parties
     * @dev This function handles the allocation of fees to the market creator, gater, referrer, and liquidity providers
     * @param _self Storage pointer to the good state
     * @param _profit The total profit to be allocated
     * @param _marketconfig The market configuration
     * @param _gater The address of the gater (if applicable)
     * @param _referral The address of the referrer (if applicable)
     * @param _marketcreator The address of the market creator
     * @param _divestQuantity The quantity of goods being divested (if applicable)
     */
    function allocateFee(
        S_GoodState storage _self,
        uint128 _profit,
        uint256 _marketconfig,
        address _gater,
        address _referral,
        address _marketcreator,
        uint128 _divestQuantity
    ) private {
        // Calculate platform fee and deduct it from the profit
        uint128 marketfee = _marketconfig.getPlatFee128(_profit);
        _profit -= marketfee;

        // Calculate individual fees based on market configuration
        uint128 liquidFee = _marketconfig.getLiquidFee(_profit);
        uint128 sellerFee = _marketconfig.getSellerFee(_profit);
        uint128 gaterFee = _marketconfig.getGaterFee(_profit);
        uint128 referFee = _marketconfig.getReferFee(_profit);
        uint128 customerFee = _marketconfig.getCustomerFee(_profit);

        if (_referral == address(0)) {
            // If no referrer, distribute fees differently
            _self.erc20address.safeTransfer(
                msg.sender,
                liquidFee + _divestQuantity
            );
            _self.commission[_gater] += sellerFee + customerFee;
            _self.commission[_marketcreator] += (_profit -
                liquidFee -
                sellerFee -
                customerFee +
                marketfee);
        } else {
            // If referrer exists, distribute fees according to roles
            if (_self.owner != _marketcreator) {
                _self.commission[_self.owner] += sellerFee;
            } else {
                marketfee += sellerFee;
            }

            if (_gater != _marketcreator) {
                _self.commission[_gater] += gaterFee;
            } else {
                marketfee += gaterFee;
            }

            if (_referral != _marketcreator) {
                _self.commission[_referral] += referFee;
            } else {
                marketfee += referFee;
            }

            _self.commission[_marketcreator] += marketfee;
            _self.erc20address.safeTransfer(
                msg.sender,
                liquidFee + customerFee + _divestQuantity
            );
        }
    }

    /**
     * @notice Modify the good configuration
     * @dev This function modifies the good configuration by preserving the top 33 bits and updating the rest
     * @param _self Storage pointer to the good state
     * @param _goodconfig The new configuration value to be applied
     */
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
    /**
     * @notice Convert a good key to an ID
     * @dev This function converts a good key to a unique ID using keccak256 hashing
     * @param goodKey The good key to be converted
     * @return The unique ID of the good
     */
    function toId(S_GoodKey memory goodKey) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(goodKey)));
    }
}
