// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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

    /// @notice Get the investment fee rate (in basis points)
    /// @param config The configuration value
    /// @return a The investment fee rate
    function getInvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(250, shl(33, config))
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

    function getInvestFulFee(
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

    /// @notice Get the disinvestment fee rate (in basis points)
    /// @param config The configuration value
    /// @return a The disinvestment fee rate
    function getDisinvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(250, shl(39, config))
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

    /// @notice Get the buying fee rate (in basis points)
    /// @param config The configuration value
    /// @return a The buying fee rate
    function getBuyFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(249, shl(45, config))
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

    /// @notice Get the selling fee rate (in basis points)
    /// @param config The configuration value
    /// @return a The selling fee rate
    function getSellFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(249, shl(52, config))
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

    /// @notice Get the swap chips
    /// @param config The configuration value
    /// @return a The swap chips
    function getSwapChips(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(59, config))
        }
        return a * 64;
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
        return (amount / (a * 64));
    }

    /// @notice Get the disinvestment chips
    /// @param config The configuration value
    /// @return a The disinvestment chips
    function getDisinvestChips(
        uint256 config
    ) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(69, config))
        }
        return a;
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

    /// @notice Get the good type
    /// @param config The configuration value
    /// @return a The good type
    function getGoodType(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(223, shl(79, config))
        }

        return a;
    }

    /// @notice Get the phone number
    /// @param config The configuration value
    /// @return a The phone number
    function getTell(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(112, config))
        }

        return a;
    }

    /// @notice Get the longitude
    /// @param config The configuration value
    /// @return a The longitude
    function getLongitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(160, config))
        }

        return a;
    }

    /// @notice Get the latitude
    /// @param config The configuration value
    /// @return a The latitude
    function getLatitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(208, config))
        }
        return a;
    }

    /// @notice Get a specific range of bits from the configuration
    /// @param config The configuration value
    /// @param left The left shift amount
    /// @param right The right shift amount
    /// @return b The extracted value
    function getxy(
        uint256 config,
        uint256 left,
        uint256 right
    ) internal pure returns (uint256 b) {
        assembly {
            b := shr(right, shl(left, config))
        }
    }

    /// @notice Get a specific range of bits from the configuration and multiply by an amount
    /// @param config The configuration value
    /// @param left The left shift amount
    /// @param right The right shift amount
    /// @param amount The amount to multiply by
    /// @return b The calculated result
    function getxyamount(
        uint256 config,
        uint256 left,
        uint256 right,
        uint256 amount
    ) internal pure returns (uint256 b) {
        assembly {
            b := shr(right, shl(left, config))
        }
        b = amount * b;
    }
}
