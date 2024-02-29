// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {L_GoodConfigLibrary} from "../../Contracts/libraries/L_GoodConfig.sol";
import "../../src/ERC20.sol";
import "../../Contracts/MarketManager.sol";
import "../../Contracts/interfaces/I_Good.sol";
import {S_GoodKey} from "../../Contracts/types/S_GoodKey.sol";
import {T_GoodId, L_GoodIdLibrary} from "../../Contracts/types/T_GoodId.sol";
import {T_Currency} from "../../Contracts/types/T_Currency.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../../Contracts/types/T_BalanceUINT256.sol";
import "../util/initMetaGoodtest.sol";

contract initNormalGoodtest is initMetaGoodtest, Test {
    using L_GoodIdLibrary for S_GoodKey;

    function InitMetaGood1(string memory name) public {
        initMetaGoodtest1(name);
    }

    function InitNormalGood1(string memory name) public {
        USDT = new MyToken(name, name);
        address alice = address(this);
        USDT.mint(alice, 100000);
        btc.mint(alice, 100000);
        USDT.approve(address(market), 100000);
        btc.approve(address(market), 100000);
        market.updatetoValueGood(metagood);
        market.initNormalGood(metagood, toBalanceUINT256(2000, 2000), T_Currency.wrap(address(USDT)), 0);
    }
}
