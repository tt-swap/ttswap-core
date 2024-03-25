// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IERC20Minimal} from "../interfaces/IERC20Minimal.sol";

type T_Currency is address;

/// @title L_CurrencyLibrary
/// @dev This library allows for transferring and holding native tokens and ERC20 tokens
library L_CurrencyLibrary {
    using L_CurrencyLibrary for T_Currency;

    /// @notice Thrown when a native transfer fails
    error NativeTransferFailed();

    /// @notice Thrown when an ERC20 transfer fails
    error ERC20TransferFailed();

    T_Currency public constant NATIVE = T_Currency.wrap(address(0));

    function approve(T_Currency currency, uint256 amount) internal {
        IERC20Minimal(T_Currency.unwrap(currency)).approve(
            address(this),
            amount
        );
    }

    function decimals(T_Currency currency) internal view returns (uint8) {
        return IERC20Minimal(T_Currency.unwrap(currency)).decimals();
    }

    function totalSupply(T_Currency currency) internal view returns (uint256) {
        return IERC20Minimal(T_Currency.unwrap(currency)).totalSupply();
    }

    function transferFrom(
        T_Currency currency,
        address from,
        uint256 amount
    ) internal {
        IERC20Minimal(T_Currency.unwrap(currency)).transferFrom(
            from,
            address(this),
            amount
        );
    }

    function transfer(
        T_Currency currency,
        address to,
        uint256 amount
    ) internal {
        // implementation from
        // https://github.com/transmissions11/solmate/blob/e8f96f25d48fe702117ce76c79228ca4f20206cb/src/utils/SafeTransferLib.sol

        bool success;
        if (currency.isNative()) {
            assembly {
                // Transfer the ETH and store if it succeeded or not.
                success := call(gas(), to, amount, 0, 0, 0, 0)
            }

            if (!success) revert NativeTransferFailed();
        } else {
            assembly {
                // We'll write our calldata to this slot below, but restore it later.
                let memPointer := mload(0x40)

                // Write the abi-encoded calldata into memory, beginning with the function selector.
                mstore(
                    0,
                    0xa9059cbb00000000000000000000000000000000000000000000000000000000
                )
                mstore(4, to) // Append the "to" argument.
                mstore(36, amount) // Append the "amount" argument.

                success := and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(
                        and(eq(mload(0), 1), gt(returndatasize(), 31)),
                        iszero(returndatasize())
                    ),
                    // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    call(gas(), currency, 0, 0, 68, 0, 32)
                )

                mstore(0x60, 0) // Restore the zero slot to zero.
                mstore(0x40, memPointer) // Restore the memPointer.
            }

            if (!success) revert ERC20TransferFailed();
        }
    }

    function balanceOfSelf(
        T_Currency currency
    ) internal view returns (uint256) {
        if (currency.isNative()) {
            return address(this).balance;
        } else {
            return
                IERC20Minimal(T_Currency.unwrap(currency)).balanceOf(
                    address(this)
                );
        }
    }

    function balanceOf(
        T_Currency currency,
        address owner
    ) internal view returns (uint256) {
        if (currency.isNative()) {
            return owner.balance;
        } else {
            return IERC20Minimal(T_Currency.unwrap(currency)).balanceOf(owner);
        }
    }

    function isNative(T_Currency currency) internal pure returns (bool) {
        return T_Currency.unwrap(currency) == T_Currency.unwrap(NATIVE);
    }

    function toId(T_Currency currency) internal pure returns (uint256) {
        return uint160(T_Currency.unwrap(currency));
    }

    function fromId(uint256 id) internal pure returns (T_Currency) {
        return T_Currency.wrap(address(uint160(id)));
    }

    function unwrap(T_Currency currency) internal pure returns (address) {
        return T_Currency.unwrap(currency);
    }
}
