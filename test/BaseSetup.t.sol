// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/MarketManager.sol";
import {TTS} from "../src/TTSwap_Token.sol";

contract BaseSetup is Test, GasSnapshot {
    address payable[8] internal users;
    MyToken btc;
    MyToken usdt;
    MyToken eth;
    address marketcreator;
    MarketManager market;
    TTS tts_token;

    function setUp() public virtual {
        uint256 m_marketconfig = (45 << 250) +
            (5 << 244) +
            (10 << 238) +
            (15 << 232) +
            (25 << 226) +
            (20 << 220);

        users[0] = payable(address(1));
        users[1] = payable(address(2));
        users[2] = payable(address(3));
        users[3] = payable(address(4));
        users[4] = payable(address(5));
        users[5] = payable(address(15));
        users[6] = payable(address(16));
        users[7] = payable(address(17));
        marketcreator = payable(address(6));
        btc = new MyToken("BTC", "BTC", 8);
        usdt = new MyToken("USDT", "USDT", 6);
        eth = new MyToken("ETH", "ETH", 18);
        vm.startPrank(marketcreator);
        tts_token = new TTS(address(usdt), marketcreator, 2 ** 255);
        snapStart("depoly Market Manager");
        market = new MarketManager(m_marketconfig, address(tts_token));
        snapEnd();
        tts_token.addauths(address(market), 1);
        vm.stopPrank();
    }
}
