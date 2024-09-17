// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title Market Configuration Library
/// @notice Library for managing and calculating various fee configurations for a market
library L_MarketConfigLibrary {
    /// @notice Calculate the liquidity provider fee amount
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated liquidity provider fee amount
    function getLiquidFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, config)
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the seller fee amount
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated seller fee amount
    function getSellerFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(6, config))
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the gater fee amount
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated gater fee amount
    function getGaterFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(12, config))
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the referrer fee amount
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated referrer fee amount
    function getReferFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(18, config))
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the customer fee amount
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated customer fee amount
    function getCustomerFee(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(250, shl(24, config))
                config := mul(amount, config)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the platform fee amount and return it as a uint128
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated platform fee amount as a uint128
    function getPlatFee128(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint128 a) {
        unchecked {
            assembly {
                config := shr(251, shl(30, config))
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }

    /// @notice Calculate the platform fee amount and return it as a uint256
    /// @param config The market configuration
    /// @param amount The total amount to calculate the fee from
    /// @return a The calculated platform fee amount as a uint256
    function getPlatFee256(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint256 a) {
        unchecked {
            assembly {
                config := shr(251, shl(30, config))
                config := mul(config, amount)
                a := div(config, 100)
            }
        }
    }
}
