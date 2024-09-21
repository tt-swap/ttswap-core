// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

/// @notice This is a temporary library that allows us to use transient storage (tstore/tload)
/// TODO: This library can be deleted when we have the transient keyword support in solidity.
library L_Triger {
    function isOk(bool _isok) internal pure {
        if (!_isok) revert();
    }
}
