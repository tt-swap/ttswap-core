// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.23;

import {FullMath} from "./FullMath.sol";

/// @notice Library for computing the ID of a pool
library L_GoodConfigLibrary {
    //商品配置
    function isvaluegood(uint256 config) internal pure returns (bool a) {
        uint256 b;
        assembly {
            b := shr(255, config)
        }
        return b == 1 ? true : false;
    }

    //商品投资费率 单位万分之一
    //起始位 1 长度 10
    function getInvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(1, config))
        }
    }

    function getInvestFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(246, shl(1, config))
        }
        a = FullMath.mulDiv128(amount, a, 10000);
    }

    //商品撤资费率 单位万分之一
    //起始位 11 长度 10
    function getDisinvestFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(11, config))
        }
    }

    function getDisinvestFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(246, shl(11, config))
        }

        a = FullMath.mulDiv128(amount, a, 10000);
    }

    //商品购买费率 单位万分之一
    //起始位 21 长度 10
    function getBuyFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(21, config))
        }
    }

    function getBuyFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(246, shl(21, config))
        }

        a = FullMath.mulDiv128(amount, a, 10000);
    }

    //商品出售费率 单位万分之一
    //起始位 31 长度 10
    function getSellFee(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(31, config))
        }
    }

    function getSellFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(246, shl(31, config))
        }
        a = FullMath.mulDiv128(amount, a, 10000);
    }

    //
    function getSwapChips(uint256 config) internal pure returns (uint16 a) {
        assembly {
            a := shr(246, shl(41, config))
        }
        return a * 2 ** 6;
    }

    function getSwapChips(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128) {
        uint128 a;
        assembly {
            a := shr(246, shl(41, config))
        }
        if (a == 0) return amount;
        return (amount / (a * 2 ** 6));
    }

    //物品类型
    function getGoodType(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(223, shl(51, config))
        }

        return a;
    }

    //电话号码
    function getTell(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(84, config))
        }

        return a;
    }

    //经度
    function getLongitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(132, config))
        }

        return a;
    }

    //纬度
    function getLatitude(uint256 config) internal pure returns (uint128 a) {
        assembly {
            a := shr(208, shl(180, config))
        }
        return a;
    }
}
