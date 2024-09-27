// SPDX-License-Identifier: MIT
<<<<<<< HEAD
pragma solidity ^0.8.1;
=======
pragma solidity 0.8.26;
>>>>>>> 7ff40e0 (remove balance type 20240922)

using L_TTSwapUINT256Library for uint256;
/// @notice Converts two uint128 values into a T_BalanceUINT256
/// @param _amount0 The first 128-bit amount
/// @param _amount1 The second 128-bit amount
/// @return balanceDelta The resulting T_BalanceUINT256
function toTTSwapUINT256(
    uint128 _amount0,
    uint128 _amount1
) pure returns (uint256 balanceDelta) {
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

/// @notice Adds two T_BalanceUINT256 values
/// @param a The first T_BalanceUINT256
/// @param b The second T_BalanceUINT256
/// @return The sum of a and b as a T_BalanceUINT256
function add(uint256 a, uint256 b) pure returns (uint256) {
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
    return toTTSwapUINT256(toInt128(res0), toInt128(res1));
}

/// @notice Subtracts two T_BalanceUINT256 values
/// @param a The first T_BalanceUINT256
/// @param b The second T_BalanceUINT256
/// @return The difference of a and b as a T_BalanceUINT256
function sub(uint256 a, uint256 b) pure returns (uint256) {
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
        res0 := sub(a0, b0)
        res1 := sub(a1, b1)
    }
    return toTTSwapUINT256(toInt128(res0), toInt128(res1));
}

/// @notice Adds the first components and subtracts the second components of two T_BalanceUINT256 values
/// @param a The first T_BalanceUINT256
/// @param b The second T_BalanceUINT256
/// @return The result of (a0 + b0, a1 - b1) as a T_BalanceUINT256
function addsub(uint256 a, uint256 b) pure returns (uint256) {
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
        res1 := sub(a1, b1)
    }
    return toTTSwapUINT256(toInt128(res0), toInt128(res1));
}

/// @notice Subtracts the first components and adds the second components of two T_BalanceUINT256 values
/// @param a The first T_BalanceUINT256
/// @param b The second T_BalanceUINT256
/// @return The result of (a0 - b0, a1 + b1) as a T_BalanceUINT256
function subadd(uint256 a, uint256 b) pure returns (uint256) {
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
        res0 := sub(a0, b0)
        res1 := add(a1, b1)
    }
    return toTTSwapUINT256(toInt128(res0), toInt128(res1));
}

/// @notice Safely converts a uint256 to a uint128
/// @param a The uint256 value to convert
/// @return The converted uint128 value, or 0 if overflow
function toInt128(uint256 a) pure returns (uint128) {
    return a <= type(uint128).max ? uint128(a) : 0;
}

/// @notice Compares the prices of three T_BalanceUINT256 values
/// @param a The first T_BalanceUINT256
/// @param b The second T_BalanceUINT256
/// @param c The third T_BalanceUINT256
/// @return True if the price of a is lower than the prices of b and c, false otherwise
function lowerprice(uint256 a, uint256 b, uint256 c) pure returns (bool) {
    return
        uint256(a.amount0()) * uint256(b.amount1()) * uint256(c.amount1()) >
            uint256(a.amount1()) * uint256(b.amount0()) * uint256(c.amount0())
            ? true
            : false;
}

/// @notice Performs a multiplication followed by a division
/// @param config The multiplicand
/// @param amount The multiplier
/// @param domitor The divisor
/// @return a The result as a uint128
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

/// @title L_TTSwapUINT256Library
/// @notice A library for operations on T_BalanceUINT256
library L_TTSwapUINT256Library {
    /// @notice Extracts the first 128-bit amount from a T_BalanceUINT256
    /// @param balanceDelta The T_BalanceUINT256 to extract from
    /// @return _amount0 The extracted first 128-bit amount
    function amount0(
        uint256 balanceDelta
    ) internal pure returns (uint128 _amount0) {
        /// @solidity memory-safe-assembly
        assembly {
            _amount0 := shr(128, balanceDelta)
        }
    }

    /// @notice Extracts the second 128-bit amount from a T_BalanceUINT256
    /// @param balanceDelta The T_BalanceUINT256 to extract from
    /// @return _amount1 The extracted second 128-bit amount
    function amount1(
        uint256 balanceDelta
    ) internal pure returns (uint128 _amount1) {
        /// @solidity memory-safe-assembly
        assembly {
            _amount1 := balanceDelta
        }
    }

    /// @notice Calculates amount0 based on a given amount1 and the ratio in balanceDelta
    /// @param balanceDelta The T_BalanceUINT256 containing the ratio
    /// @param amount1delta The amount1 to base the calculation on
    /// @return _amount0 The calculated amount0
    function getamount0fromamount1(
        uint256 balanceDelta,
        uint128 amount1delta
    ) internal pure returns (uint128 _amount0) {
        return
            mulDiv(
                balanceDelta.amount0(),
                amount1delta,
                balanceDelta.amount1()
            );
    }

    /// @notice Calculates amount1 based on a given amount0 and the ratio in balanceDelta
    /// @param balanceDelta The T_BalanceUINT256 containing the ratio
    /// @param amount0delta The amount0 to base the calculation on
    /// @return _amount1 The calculated amount1
    function getamount1fromamount0(
        uint256 balanceDelta,
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
