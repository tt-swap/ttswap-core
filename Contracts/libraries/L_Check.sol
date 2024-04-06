// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {L_CurrencyLibrary} from "../libraries/L_Currency.sol";
import {L_GoodConfigLibrary} from "../libraries/L_GoodConfig.sol";
library L_CHECK {
    using L_CurrencyLibrary for address;
    using L_GoodConfigLibrary for uint256;
    function checkinitNormalGoodParas(
        uint256 goodConfig,
        address para_erc20address,
        uint256 para_goodConfig
    ) internal view {
        require(goodConfig.isvaluegood(), "M002");
        require(!para_goodConfig.isvaluegood(), "M003");
        require(para_erc20address.decimals() <= 18, "M004");
        require(para_erc20address.totalSupply() <= 2 ** 96, "M005");
    }
}
