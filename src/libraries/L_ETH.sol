// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title L_CurrencyLibrary
/// @dev This library allows for transferring and holding native tokens and ERC20 tokens
library L_ETHLibrary {
    error ETHTransferError();

    function transfer(address to, uint256 amount) internal {
        // altered from https://github.com/transmissions11/solmate/blob/44a9963d4c78111f77caa0e65d677b8b46d6f2e6/src/utils/SafeTransferLib.sol
        // modified custom error selectors

        bool success;
        assembly ("memory-safe") {
            // Transfer the ETH and revert if it fails.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }
        // revert with NativeTransferFailed, containing the bubbled up error as an argument
        if (!success) {
            revert ETHTransferError();
        }
    }

    function transferFrom(uint256 amount) internal {
        // altered from https://github.com/transmissions11/solmate/blob/44a9963d4c78111f77caa0e65d677b8b46d6f2e6/src/utils/SafeTransferLib.sol
        // modified custom error selectors

        if (msg.value != amount) {
            revert ETHTransferError();
        }
    }
}
