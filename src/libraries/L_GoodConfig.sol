// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/// @title L_GoodConfigLibrary
/// @notice A library for managing and retrieving configuration data for goods
/// @dev This library uses bitwise operations and assembly for efficient storage and retrieval of configuration data
library L_GoodConfigLibrary {
    /// @notice Check if the good is a value good
    /// @param config The configuration value
    /// @return a True if it's a value good, false otherwise
    function isvaluegood(uint256 config) internal pure returns (bool a) {
        return (config & (1 << 255)) != 0;
    }

    /// @notice Check if the good is a normal good
    /// @param config The configuration value
    /// @return a True if it's a normal good, false otherwise
    function isnormalgood(uint256 config) internal pure returns (bool a) {
        return (config & (1 << 255)) == 0;
    }

    /// @notice Calculate the investment fee for a given amount
    /// @param config The configuration value
    /// @param amount The investment amount
    /// @return a The calculated investment fee
    function getFlashFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint256 a) {
        unchecked {
            assembly {
                config := shr(250, shl(27, config))
                config := mul(config, amount)
                a := div(config, 10000)
            }
        }
    }

    /// @notice Calculate the investment fee for a given amount
    /// @param config The configuration value
    /// @param amount The investment amount
    /// @return a The calculated investment fee
    function getInvestFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(33, config))
                config := mul(config, amount)
                a := div(config, 10000)
            }
        }
    }

    function getInvestFullFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(33, config))
                amount := div(amount, sub(10000, config))
                a := mul(amount, 10000)
            }
        }
    }

    /// @notice Calculate the disinvestment fee for a given amount
    /// @param config The configuration value
    /// @param amount The disinvestment amount
    /// @return a The calculated disinvestment fee
    function getDisinvestFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(39, config))
                config := mul(config, amount)
                a := div(config, 10000)
            }
        }
    }

    /// @notice Calculate the buying fee for a given amount
    /// @param config The configuration value
    /// @param amount The buying amount
    /// @return a The calculated buying fee
    function getBuyFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(249, shl(45, config))
                config := mul(config, amount)
                a := div(config, 10000)
            }
        }
    }

    /// @notice Calculate the selling fee for a given amount
    /// @param config The configuration value
    /// @param amount The selling amount
    /// @return a The calculated selling fee
    function getSellFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(249, shl(52, config))
                config := mul(config, amount)
                a := div(config, 10000)
            }
        }
    }

    /// @notice Get the swap chips for a given amount
    /// @param config The configuration value
    /// @param amount The amount
    /// @return The swap chips for the given amount
    function getSwapChips(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128) {
        uint128 a;
        assembly {
            a := shr(246, shl(59, config))
        }
        if (a == 0) return amount;
        return (amount / (a * 10));
    }

    /// @notice Get the disinvestment chips for a given amount
    /// @param config The configuration value
    /// @param amount The amount
    /// @return The disinvestment chips for the given amount
    function getDisinvestChips(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128) {
        uint128 a;
        assembly {
            a := shr(246, shl(69, config))
        }
        if (a == 0) return amount;
        return (amount / a);
    }
}
