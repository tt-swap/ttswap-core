// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {S_ProofKey} from "./L_Struct.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "./L_BalanceUINT256.sol";

library L_Proof {
    struct S_ProofState {
        address owner;
        uint256 currentgood;
        uint256 valuegood;
        T_BalanceUINT256 state; //前128位表示投资的价值, amount0:invest value
        T_BalanceUINT256 invest; //前128位表示投资的构建手续费,后128位表示投资数量 amount0:contrunct fee ,amount1:invest quantity
        T_BalanceUINT256 valueinvest; //前128位表示投资的构建手续费,后128位表示投资数量 amount0:contrunct fee ,amount1:invest quantity
        address approval;
        address beneficiary;
    }
    function updateValueInvest(
        S_ProofState storage _self,
        uint256 _currenctgood,
        T_BalanceUINT256 _state,
        T_BalanceUINT256 _invest
    ) internal {
        if (_self.invest.amount1() == 0) {
            _self.owner = msg.sender;
            _self.currentgood = _currenctgood;
            _self.valuegood = 0;
        }
        _self.invest = _self.invest + _invest;
        _self.state = _self.state + _state;
    }

    function updateNormalInvest(
        S_ProofState storage _self,
        uint256 _currenctgood,
        uint256 _valuegood,
        T_BalanceUINT256 _state,
        T_BalanceUINT256 _invest,
        T_BalanceUINT256 _valueinvest
    ) internal {
        if (_self.invest.amount1() == 0) {
            _self.owner = msg.sender;
            _self.currentgood = _currenctgood;
            _self.valuegood = _valuegood;
        }
        _self.state = _self.state + _state;
        _self.invest = _self.invest + _invest;
        _self.valueinvest = _self.valueinvest + _valueinvest;
    }

    function burnValueProofSome(
        S_ProofState storage _self,
        uint128 _quantity
    ) internal {
        T_BalanceUINT256 burnResult_ = toBalanceUINT256(
            mulDiv(_self.state.amount0(), _quantity, _self.invest.amount1()),
            _self.invest.getamount0fromamount1(_quantity)
        );
        _self.invest =
            _self.invest -
            toBalanceUINT256(burnResult_.amount1(), _quantity);

        _self.state = _self.state - toBalanceUINT256(burnResult_.amount0(), 0);
    }

    function burnNormalProofSome(
        S_ProofState storage _self,
        uint128 _quantity
    ) internal {
        T_BalanceUINT256 burnResult1_ = toBalanceUINT256(
            mulDiv(_self.state.amount0(), _quantity, _self.invest.amount1()),
            _self.invest.getamount0fromamount1(_quantity)
        );

        T_BalanceUINT256 burnResult2_ = toBalanceUINT256(
            mulDiv(
                _self.valueinvest.amount0(),
                _quantity,
                _self.invest.amount1()
            ),
            mulDiv(
                _self.valueinvest.amount1(),
                _quantity,
                _self.invest.amount1()
            )
        );
        _self.invest =
            _self.invest -
            toBalanceUINT256(burnResult1_.amount1(), _quantity);
        _self.valueinvest = _self.valueinvest - burnResult2_;
        _self.state = _self.state - toBalanceUINT256(burnResult1_.amount0(), 0);
    }

    function mulDiv(
        uint256 config,
        uint256 amount,
        uint256 domitor
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := mul(config, amount)
                a := div(config, domitor)
            }
        }
    }

    function _approve(S_ProofState storage _self, address to) internal {
        _self.approval = to;
    }

    function collectValueProofFee(
        S_ProofState storage _self,
        uint128 profit
    ) internal {
        _self.invest = _self.invest + toBalanceUINT256(profit, 0);
    }

    function collectNormalProofFee(
        S_ProofState storage _self,
        T_BalanceUINT256 profit
    ) internal {
        _self.invest = _self.invest + toBalanceUINT256(profit.amount0(), 0);
        _self.valueinvest =
            _self.valueinvest +
            toBalanceUINT256(profit.amount1(), 0);
    }
}

library L_ProofKeyLibrary {
    function toId(S_ProofKey memory proofKey) internal pure returns (bytes32) {
        return keccak256(abi.encode(proofKey));
    }
}

library L_ProofIdLibrary {
    function toId(S_ProofKey memory proofKey) internal pure returns (bytes32) {
        return keccak256(abi.encode(proofKey));
    }
}
