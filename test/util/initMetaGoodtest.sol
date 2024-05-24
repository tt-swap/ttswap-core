// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {L_GoodConfigLibrary} from "../../Contracts/libraries/L_GoodConfig.sol";
import "../../src/ERC20.sol";
import "../../Contracts/MarketManager.sol";
import "../../Contracts/interfaces/I_Good.sol";
import {S_GoodKey} from "../../Contracts/libraries/L_Struct.sol";
import {L_GoodIdLibrary} from "../../Contracts/libraries/L_Good.sol";
import {L_CurrencyLibrary} from "../../Contracts/libraries/L_Currency.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../../Contracts/libraries/L_BalanceUINT256.sol";

contract initMetaGoodtest {
    using L_GoodIdLibrary for S_GoodKey;

    address public marketcreator;
    MyToken public btc;
    MyToken public USDT;
    MyToken public WETH;
    uint256 public metagood;
    uint256 public normalGood1;
    uint256 public normalGood2;

    MarketManager market;

    function initMetaGoodtest1(string memory aa) public {
        marketcreator = address(this);
        market = new MarketManager(marketcreator, 1);
        btc = new MyToken(aa, aa, 8);
        btc.mint(marketcreator, 20000000);
        btc.approve(address(market), 2000000);

        market.initMetaGood(address(btc), toBalanceUINT256(20000, 20000), 0);
        market.updatetoValueGood(metagood);
    }
}
