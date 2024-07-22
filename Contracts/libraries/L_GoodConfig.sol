// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @notice
library L_GoodConfigLibrary {
    //商品配置
    function isvaluegood(uint256 config) internal pure returns (bool a) {
        uint256 b;
        assembly {
            b := shr(255, config)
        }
        return b == 1 ? true : false;
    }
    function isnormalgood(uint256 config) internal pure returns (bool a) {
        uint256 b;
        assembly {
            b := shr(255, config)
        }
        return b == 1 ? false : true;
    }

    //商品投资费率 单位万分之一
    //起始位 5 长度 7
    function getInvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(250, shl(33, config))
        }
    }

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

    //商品撤资费率 单位万分之一
    //起始位 13 长度 7
    function getDisinvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(250, shl(39, config))
        }
    }

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

    //商品购买费率 单位万分之一
    //起始位 20 长度 7
    function getBuyFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(249, shl(45, config))
        }
    }

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

    //商品出售费率 单位万分之一
    //起始位 27 长度 7
    function getSellFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(249, shl(52, config))
        }
    }

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

    // get swap chips
    function getSwapChips(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(59, config))
        }
        return a * 64;
    }

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

    // get disinvest Chips
    function getDisinvestChips(
        uint256 config
    ) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(69, config))
        }
        return a;
    }

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

    //物品类型
    function getGoodType(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(223, shl(79, config))
        }

        return a;
    }

    //电话号码
    function getTell(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(112, config))
        }

        return a;
    }

    //经度
    function getLongitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(160, config))
        }

        return a;
    }

    //纬度
    function getLatitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(208, config))
        }
        return a;
    }

    function getxy(
        uint256 config,
        uint256 left,
        uint256 right
    ) internal pure returns (uint256 b) {
        assembly {
            b := shr(right, shl(left, config))
        }
    }

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
