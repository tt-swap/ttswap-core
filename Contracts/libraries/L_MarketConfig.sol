// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title Market Configuration Library
/// @notice Library for managing and calculating various fee configurations for a market
library L_MarketConfigLibrary {
    /// @notice Get the liquidity provider fee percentage
    /// @dev Extracts the fee from the first 6 bits of the config
    /// @param config The market configuration
    /// @return a The liquidity provider fee percentage (in hundredths)
    function getLiquidFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, config)
        }
    }

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

    /// @notice Get the seller fee percentage
    /// @dev Extracts the fee from bits 7-12 of the config
    /// @param config The market configuration
    /// @return a The seller fee percentage (in hundredths)
    function getSellerFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, shl(6, config))
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

    /// @notice Get the gater fee percentage
    /// @dev Extracts the fee from bits 53-58 of the config
    /// @param config The market configuration
    /// @return a The gater fee percentage (in hundredths)
    function getGaterFee(uint256 config) internal pure returns (uint8 a) {
        unchecked {
            assembly {
                a := shr(250, shl(12, config))
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

    /// @notice Get the referrer fee percentage
    /// @dev Extracts the fee from bits 59-64 of the config
    /// @param config The market configuration
    /// @return a The referrer fee percentage (in hundredths)
    function getReferFee(uint256 config) internal pure returns (uint8 a) {
        unchecked {
            assembly {
                a := shr(250, shl(18, config))
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

    /// @notice Get the customer fee percentage
    /// @dev Extracts the fee from bits 65-70 of the config
    /// @param config The market configuration
    /// @return a The customer fee percentage (in hundredths)
    function getCustomerFee(uint256 config) internal pure returns (uint8 a) {
        unchecked {
            assembly {
                a := shr(250, shl(24, config))
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

    /// @notice Get the platform fee percentage
    /// @dev Extracts the fee from bits 47-51 of the config
    /// @param config The market configuration
    /// @return a The platform fee percentage (in hundredths)
    function getPlatFee(uint256 config) internal pure returns (uint8 a) {
        unchecked {
            assembly {
                a := shr(251, shl(30, config))
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

    /// @notice Check if the sum of all fee percentages equals 100%
    /// @param config The market configuration
    /// @return A boolean indicating whether the fee allocation is valid (sums to 100%)
    function checkAllocate(uint256 config) internal pure returns (bool) {
        uint8 a = getLiquidFee(config) +
            getSellerFee(config) +
            getGaterFee(config) +
            getReferFee(config) +
            getCustomerFee(config);
        return a == 100 ? true : false;
    }
}
