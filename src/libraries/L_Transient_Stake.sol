// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.29;

import {TTSwapError} from "./L_Error.sol";
/// @notice This is a temporary library that allows us to use transient storage (tstore/tload)
/// TODO: This library can be deleted when we have the transient keyword support in solidity.

library L_Transient {
    // The slot holding the Value state, transiently. bytes32(uint256(keccak256("STAKE_VALUE_SLOT")) - 1)
    bytes32 constant VALUE_SLOT = 0xbc0bea6b0debcaf41836b6168bd1bce6a6cfb17d221105a2e34f5c1e5634e2a1;
    // The slot holding the Value state, transiently. bytes32(uint256(keccak256("STAKE_DEPTH_SLOT")) - 1)
    bytes32 constant DEPTH_SLOT = 0x968200d04761c0c59f9a621549e0c376bd2c036f6fd5b0d8ff844478c3216f8e;
    // The slot holding the Value state, transiently. bytes32(uint256(keccak256("STAKE_LOCK_SLOT")) - 1)
    bytes32 constant LOCK_SLOT = 0xe8b57f2a24cc49561abc37cc14eb27f7e291d1ac82b5f173f246cc4b4de01451;

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

    function setValue(uint256 locker) internal {
        assembly {
            tstore(VALUE_SLOT, locker)
        }
    }

    function getValue() internal view returns (uint256 value) {
        assembly {
            value := tload(VALUE_SLOT)
        }
    }

    function increaseValue(uint256 amount) internal {
        assembly {
            tstore(VALUE_SLOT, add(tload(VALUE_SLOT), amount))
        }
    }

    function decreaseValue(uint256 amount) internal {
        if (amount > getValue()) revert TTSwapError(28);
        assembly {
            tstore(VALUE_SLOT, sub(tload(VALUE_SLOT), amount))
        }
    }

    function getDepth() internal view returns (uint256 step) {
        assembly {
            step := tload(DEPTH_SLOT)
        }
    }

    function clearDepth() internal {
        assembly {
            tstore(DEPTH_SLOT, 0)
        }
    }

    function addDepth() internal {
        assembly {
            tstore(DEPTH_SLOT, add(tload(DEPTH_SLOT), 1))
        }
    }

    function subDepth() internal {
        assembly {
            tstore(DEPTH_SLOT, sub(tload(DEPTH_SLOT), 1))
        }
    }

    function checkbefore() internal {
        if (getDepth() == 0) {
            setValue(msg.value);
            clearDepth();
        }
        addDepth();
    }

    function checkafter() internal {
        subDepth();
        if (getDepth() == 0 && getValue() > 0) {
            uint256 amount = getValue();
            setValue(0);
            bool success;
            address to = msg.sender;
            assembly {
                // Transfer the ETH and store if it succeeded or not.
                success := call(gas(), to, amount, 0, 0, 0, 0)
            }
            if (!success) revert TTSwapError(30);
        }
    }
}
