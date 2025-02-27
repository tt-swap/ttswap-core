// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.1;

import {TTSwapError} from "./L_Error.sol";
/// @notice This is a temporary library that allows us to use transient storage (tstore/tload)
/// TODO: This library can be deleted when we have the transient keyword support in solidity.
library L_Transient {
    // The slot holding the locker state, transiently. keccak256("L_Lock") - 1)

    bytes32 constant VALUE_SLOT =
        0xcfdbe78f31bc5efa50605e8b11a7b6843971370ea97eb24de6e1a1eb1d235643;
    bytes32 constant DEPTH_SLOT =
        0xcfdbe78f31bc5efa50605e8b11a7b6843971370ea97eb24de6e1a1eb7d235644;

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
    function setValue(uint256 locker) internal {
        assembly {
            tstore(VALUE_SLOT, locker)
        }
    }

    function getValue() internal view returns (uint256 step) {
        assembly {
            step := tload(VALUE_SLOT)
        }
    }

    function increaseValue(uint256 amount) internal {
        assembly {
            tstore(VALUE_SLOT, add(tload(VALUE_SLOT), amount))
        }
    }

    function decreaseValue(uint256 amount) internal {
        if (amount > getValue()) revert TTSwapError(25);
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
        if (getDepth() == 0) {
            uint256 amount = getValue();
            setValue(0);
            bool success;
            address to = msg.sender;
            assembly {
                // Transfer the ETH and store if it succeeded or not.
                success := call(gas(), to, amount, 0, 0, 0, 0)
            }
            if (!success) revert TTSwapError(25);
        }
    }
}
