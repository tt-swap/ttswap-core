// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

type T_BalanceUINT256 is uint256;

using {add as +, sub as -} for T_BalanceUINT256 global;
using L_BalanceUINT256Library for T_BalanceUINT256 global;

function toBalanceUINT256(
    uint128 _amount0,
    uint128 _amount1
) pure returns (T_BalanceUINT256 balanceDelta) {
    /// @solidity memory-safe-assembly
    assembly {
        balanceDelta := or(
            shl(128, _amount0),
            and(
                0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
                _amount1
            )
        )
    }
}

function add(
    T_BalanceUINT256 a,
    T_BalanceUINT256 b
) pure returns (T_BalanceUINT256) {
    uint256 res0;
    uint256 res1;
    assembly ("memory-safe") {
        let a0 := sar(128, a)
        let a1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            a
        )
        let b0 := sar(128, b)
        let b1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            b
        )
        res0 := add(a0, b0)
        res1 := add(a1, b1)
    }
    return toBalanceUINT256(toInt128(res0), toInt128(res1));
}

function sub(
    T_BalanceUINT256 a,
    T_BalanceUINT256 b
) pure returns (T_BalanceUINT256) {
    uint256 res0;
    uint256 res1;
    assembly {
        let a0 := sar(128, a)
        let a1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            a
        )
        let b0 := sar(128, b)
        let b1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            b
        )
        res0 := sub(a0, b0)
        res1 := sub(a1, b1)
    }
    return toBalanceUINT256(toInt128(res0), toInt128(res1));
}

function addsub(
    T_BalanceUINT256 a,
    T_BalanceUINT256 b
) pure returns (T_BalanceUINT256) {
    uint256 res0;
    uint256 res1;
    assembly {
        let a0 := sar(128, a)
        let a1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            a
        )
        let b0 := sar(128, b)
        let b1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            b
        )
        res0 := add(a0, b0)
        res1 := sub(a1, b1)
    }
    return toBalanceUINT256(toInt128(res0), toInt128(res1));
}

function subadd(
    T_BalanceUINT256 a,
    T_BalanceUINT256 b
) pure returns (T_BalanceUINT256) {
    uint256 res0;
    uint256 res1;
    assembly {
        let a0 := sar(128, a)
        let a1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            a
        )
        let b0 := sar(128, b)
        let b1 := and(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,
            b
        )
        res0 := sub(a0, b0)
        res1 := add(a1, b1)
    }
    return toBalanceUINT256(toInt128(res0), toInt128(res1));
}

function toInt128(uint256 a) pure returns (uint128) {
    return a <= type(uint128).max ? uint128(a) : 0;
}

function lowerprice(
    T_BalanceUINT256 a,
    T_BalanceUINT256 b,
    T_BalanceUINT256 c
) pure returns (bool) {
    return
        uint256(a.amount0()) * uint256(b.amount1()) * uint256(c.amount1()) >
            uint256(a.amount1()) * uint256(b.amount0()) * uint256(c.amount0())
            ? true
            : false;
}

function mulDiv(
    uint256 config,
    uint256 amount,
    uint256 domitor
) pure returns (uint128 a) {
    uint256 result;
    unchecked {
        assembly {
            config := mul(config, amount)
            result := div(config, domitor)
        }
    }
    return toInt128(result);
}

library L_BalanceUINT256Library {
    function amount0(
        T_BalanceUINT256 balanceDelta
    ) internal pure returns (uint128 _amount0) {
        /// @solidity memory-safe-assembly
        assembly {
            _amount0 := shr(128, balanceDelta)
        }
    }

    function amount1(
        T_BalanceUINT256 balanceDelta
    ) internal pure returns (uint128 _amount1) {
        /// @solidity memory-safe-assembly
        assembly {
            _amount1 := balanceDelta
        }
    }

    function getamount0fromamount1(
        T_BalanceUINT256 balanceDelta,
        uint128 amount1delta
    ) internal pure returns (uint128 _amount0) {
        return
            mulDiv(
                balanceDelta.amount0(),
                amount1delta,
                balanceDelta.amount1()
            );
    }

    function getamount1fromamount0(
        T_BalanceUINT256 balanceDelta,
        uint128 amount0delta
    ) internal pure returns (uint128 _amount1) {
        return
            mulDiv(
                balanceDelta.amount1(),
                amount0delta,
                balanceDelta.amount0()
            );
    }
}
