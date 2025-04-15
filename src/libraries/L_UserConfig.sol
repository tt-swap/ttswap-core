// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/// @title Market Configuration Library
/// @notice Library for managing and calculating various fee configurations for a market
library L_UserConfigLibrary {
    /// @notice Check if the good is a value good
    /// @param config The configuration value
    /// @return a True if it's a value good, false otherwise
    function isBan(uint256 config) internal pure returns (bool a) {
        return (config & 1) != 0;
    }

    /// @notice Check if the good is a value good
    /// @param config The configuration value
    /// @return a True if it's a value good, false otherwise
    function isMarketor(uint256 config) internal pure returns (bool a) {
        return (config & 2) != 0;
    }
}
