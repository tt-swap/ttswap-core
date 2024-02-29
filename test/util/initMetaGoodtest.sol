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

contract initMetaGoodtest {
    using L_GoodIdLibrary for S_GoodKey;

    address public marketcreator;
    MyToken public btc;
    MyToken public USDT;
    MyToken public WETH;
    T_GoodId public metagood;
    T_GoodId public normalGood1;
    T_GoodId public normalGood2;

    MarketManager market;

    function initMetaGoodtest1(string memory aa) public {
        marketcreator = address(this);
        market = new MarketManager(marketcreator, 1);
        btc = new MyToken(aa, aa);
        btc.mint(marketcreator, 20000000);
        btc.approve(address(market), 2000000);
        S_GoodKey memory goodkey = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator});
        market.initMetaGood(goodkey, toBalanceUINT256(20000, 20000), 0);
        market.updatetoValueGood(metagood);
        metagood = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator}).toId();
    }
}
