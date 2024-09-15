// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title TTS Token Configuration Library
/// @notice A library for handling TTS token configurations
library L_TTSTokenConfigLibrary {
    /// @notice Checks if the given configuration represents a main item
    /// @dev Uses assembly to perform a bitwise right shift operation
    /// @param config The configuration value to check
    /// @return a True if the configuration represents a main item, false otherwise
    function ismain(uint256 config) internal pure returns (bool a) {
        uint256 b;
        assembly {
            b := shr(255, config)
        }
        return b == 1 ? true : false;
    }
}
