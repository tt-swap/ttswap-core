// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {S_ProofKey} from "./L_Struct.sol";
import {toTTSwapUINT256, mulDiv, sub, add, L_TTSwapUINT256Library} from "./L_TTSwapUINT256.sol";
import {I_TTSwap_Token} from "../interfaces/I_TTSwap_Token.sol";

library L_Proof {
    using L_TTSwapUINT256Library for uint256;
    /**
     * @dev Represents the state of a proof
     * @member currentgood The current good  associated with the proof
     * @member valuegood The value good associated with the proof
     * @member state amount0 (first 128 bits) represents total value
     * @member invest amount0 (first 128 bits) represents invest normal good quantity, amount1 (last 128 bits) represents normal good constuct fee when investing
     * @member valueinvest amount0 (first 128 bits) represents invest value good quantity, amount1 (last 128 bits) represents value good constuct fee when investing
     */
    struct S_ProofState {
        uint256 currentgood;
        uint256 valuegood;
        uint256 state;
        uint256 invest;
        uint256 valueinvest;
    }

    /**
     * @dev Updates the investment state of a proof
     * @param _self The proof state to update
     * @param _currenctgood The current good value
     * @param _valuegood The value good
     * @param _state amount0 (first 128 bits) represents total value
     * @param _invest amount0 (first 128 bits) represents invest normal good quantity, amount1 (last 128 bits) represents normal good constuct fee when investing
     * @param _valueinvest amount0 (first 128 bits) represents invest value good quantity, amount1 (last 128 bits) represents value good constuct fee when investing
     */
    function updateInvest(
        S_ProofState storage _self,
        uint256 _currenctgood,
        uint256 _valuegood,
        uint256 _state,
        uint256 _invest,
        uint256 _valueinvest
    ) internal {
        if (_self.invest.amount1() == 0) _self.currentgood = _currenctgood;
        if (_valuegood != 0) _self.valuegood = _valuegood;
        _self.state = add(_self.state, _state);
        _self.invest = add(_self.invest, _invest);
        if (_valuegood != 0)
            _self.valueinvest = add(_self.valueinvest, _valueinvest);
    }

    /**
     * @dev Burns a portion of the proof
     * @param _self The proof state to update
     * @param _value The amount to burn
     */
    function burnProof(S_ProofState storage _self, uint128 _value) internal {
        // Calculate the amount of investment to burn based on the proportion of _value to total state
        uint256 burnResult1_ = toTTSwapUINT256(
            mulDiv(_self.invest.amount0(), _value, _self.state.amount0()),
            mulDiv(_self.invest.amount1(), _value, _self.state.amount0())
        );

        // If there's a value good, calculate and burn the corresponding amount of value investment
        if (_self.valuegood != 0) {
            uint256 burnResult2_ = toTTSwapUINT256(
                mulDiv(
                    _self.valueinvest.amount0(),
                    _value,
                    _self.state.amount0()
                ),
                mulDiv(
                    _self.valueinvest.amount1(),
                    _value,
                    _self.state.amount0()
                )
            );
            // Subtract the calculated value investment from the total value investment
            _self.valueinvest = sub(_self.valueinvest, burnResult2_);
        }

        // Subtract the calculated investment from the total investment
        _self.invest = sub(_self.invest, burnResult1_);

        // Reduce the total state by the burned value
        _self.state = sub(_self.state, toTTSwapUINT256(_value, 0));
    }

    /**
     * @dev Collects fees for the proof
     * @param _self The proof state to update
     * @param profit The profit to add
     */
    function collectProofFee(
        S_ProofState storage _self,
        uint256 profit
    ) internal {
        _self.invest = add(_self.invest, toTTSwapUINT256(profit.amount0(), 0));
        if (_self.valuegood != 0) {
            _self.valueinvest = add(
                _self.valueinvest,
                toTTSwapUINT256(profit.amount1(), 0)
            );
        }
    }

    /**
     * @dev Combines two proof states
     * @param _self The proof state to update
     * @param _get The proof state to combine with
     */
    function conbine(
        S_ProofState storage _self,
        S_ProofState storage _get
    ) internal {
        _self.state = add(_self.state, _get.state);
        _self.invest = add(_self.invest, _get.invest);
        _self.valueinvest = add(_self.valueinvest, _get.valueinvest);
    }

    /**
     * @dev Stakes a certain amount of proof value
     * @param contractaddress The address of the staking contract
     * @param to The address to stake for
     * @param proofvalue The amount of proof value to stake
     * @return The staked amount
     */
    function stake(
        address contractaddress,
        address to,
        uint128 proofvalue
    ) internal returns (uint128) {
        return I_TTSwap_Token(contractaddress).stake(to, proofvalue);
    }

    /**
     * @dev Unstakes a certain amount of proof value
     * @param contractaddress The address of the staking contract
     * @param from The address to unstake from
     * @param divestvalue The amount of proof value to unstake
     */
    function unstake(
        address contractaddress,
        address from,
        uint128 divestvalue
    ) internal {
        I_TTSwap_Token(contractaddress).unstake(from, divestvalue);
    }
}

library L_ProofKeyLibrary {
    function toKey(S_ProofKey memory proofKey) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(proofKey)));
    }
}
library L_ProofIdLibrary {
    function toId(uint256 proofkey) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encode(proofkey, address(this), block.timestamp))
            );
    }
}
