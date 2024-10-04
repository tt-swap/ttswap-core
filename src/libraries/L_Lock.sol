// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.1;

/// @notice This is a temporary library that allows us to use transient storage (tstore/tload)
/// TODO: This library can be deleted when we have the transient keyword support in solidity.
library L_Lock {
    // The slot holding the locker state, transiently. keccak256("L_Lock") - 1)
    bytes32 constant LOCK_SLOT =
        0xcfdbe78f31bc5efa50605e8b11a7b6843971370ea97eb24de6e1a1eb9d235645;

    function set(address locker) internal {
        assembly {
            tstore(LOCK_SLOT, locker)
        }
    }

    function get() internal view returns (address locker) {
        assembly {
            locker := tload(LOCK_SLOT)
        }
    }
}
