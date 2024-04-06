// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {FullMath} from "./FullMath.sol";
/// @notice Library for computing the ID of a pool

library L_MarketConfigLibrary {
    //商品出售费率 单位万分之一
    //起始位 1 长度
    function getLiquidFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, config)
        }
    }
    function getLiquidFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(250, config)
        }
        if (a == 0) {
            return 0;
        } else {
            return (amount / 100) * a;
        }
    }

    //投资者分佣占比 单位百分之一
    //起始位 7 长度 6
    function getSellerFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, shl(6, config))
        }
    }

    function getSellerFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(250, shl(6, config))
        }

        a = FullMath.mulDiv128(amount, a, 100);
    }

    //门户分佣占比 单位百分之一
    //起始位 53 长度 6
    function getGaterFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, shl(12, config))
        }
    }

    function getGaterFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(250, shl(12, config))
        }

        a = FullMath.mulDiv128(amount, a, 100);
    }

    //推荐人分佣占比 单位百分之一
    //起始位 59 长度 6
    function getReferFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, shl(18, config))
        }
    }

    function getReferFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(250, shl(18, config))
        }

        a = FullMath.mulDiv128(amount, a, 100);
    }

    //用户分佣占比 单位百分之一
    //起始位 65 长度 6
    function getCustomerFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(250, shl(24, config))
        }
    }

    function getCustomerFee(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(250, shl(24, config))
        }

        a = FullMath.mulDiv128(amount, a, 100);
    }

    //平台分佣占比 单位百分之一
    //起始位 47 长度 5
    function getPlatFee(uint256 config) internal pure returns (uint8 a) {
        assembly {
            a := shr(251, shl(30, config))
        }
    }

    function getPlatFee128(
        uint256 config,
        uint128 amount
    ) internal pure returns (uint128 a) {
        assembly {
            a := shr(251, shl(30, config))
        }

        a = FullMath.mulDiv128(amount, a, 100);
    }

    function getPlatFee256(
        uint256 config,
        uint256 amount
    ) internal pure returns (uint256 a) {
        assembly {
            a := shr(251, shl(30, config))
        }

        a = FullMath.mulDiv(amount, a, 100);
    }

    function checkAllocate(uint256 config) internal pure returns (bool) {
        uint8 a = getLiquidFee(config) +
            getSellerFee(config) +
            getGaterFee(config) +
            getReferFee(config) +
            getCustomerFee(config);
        return a == 100 ? true : false;
    }
}
