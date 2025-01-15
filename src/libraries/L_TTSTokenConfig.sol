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

    function getratio(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint256 b) {
        unchecked {
            assembly {
                config := and(config, 0xffff)
                config := mul(config, amount)
                config := div(config, 10000)
                b := shl(128, config)
            }
        }
    }

    function setratio(
        uint256 config,
        uint256 ttsconfig
    ) internal pure returns (uint256 b) {
        unchecked {
            assembly {
                ttsconfig := shl(16, shr(16, ttsconfig))
                config := and(config, 0xffff)
                b := add(ttsconfig, config)
            }
        }
    }
}
