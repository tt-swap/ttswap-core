// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {MyToken} from "../src/ERC20.sol";
import {TTSwap_Token} from "../src/TTSwap_Token.sol";
import {TTSwap_Market} from "../src/TTSwap_Market.sol";

contract stakeandunstake is Test, GasSnapshot {
    address payable[8] internal users;
    MyToken btc;
    MyToken usdt;
    MyToken eth;
    address marketcreator;
    TTSwap_Market market;
    TTSwap_Token tts_token;

    function setUp() public virtual {
        vm.warp(1728111156);
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
        tts_token = new TTSwap_Token(
            address(usdt),
            marketcreator,
            2 ** 255 + 10000
        );
        snapStart("depoly Market Manager");
        market = new TTSwap_Market(
            m_marketconfig,
            address(tts_token),
            marketcreator,
            marketcreator
        );
        snapEnd();

        tts_token.addauths(address(market), 1);
        tts_token.addauths(marketcreator, 3);
        vm.stopPrank();
    }

    function teststake() public {
        vm.warp(1728211156);
        vm.startPrank(marketcreator);
        tts_token.addauths(users[1], 1);
        vm.stopPrank();
        vm.startPrank(users[1]);
        tts_token.stake(users[2], 100000);
        vm.stopPrank();
        assertEq(tts_token.stakestate() % 2 ** 128, 100000, "pool value error");
        assertEq(
            tts_token.poolstate() / 2 ** 128,
            10958904109,
            "pool asset error"
        );
        assertEq(tts_token.poolstate() % 2 ** 128, 0, "pool construct error");
        assertEq(tts_token.balanceOf(users[2]), 0, "tts balance error");
        console2.log("pool value", tts_token.stakestate() % 2 ** 128);
        console2.log("pool asset", tts_token.poolstate() / 2 ** 128);
        console2.log("pool construct", tts_token.poolstate() % 2 ** 128);
        console2.log("tts balance", tts_token.poolstate() % 2 ** 128);

        vm.stopPrank();
        vm.startPrank(users[1]);
        tts_token.unstake(users[2], 1000);
        vm.stopPrank();
        console2.log("pool value", tts_token.stakestate() % 2 ** 128);
        console2.log("pool asset", tts_token.poolstate() / 2 ** 128);
        console2.log("pool construct", tts_token.poolstate() % 2 ** 128);
        assertEq(tts_token.stakestate() % 2 ** 128, 99000, "pool value error");
        assertEq(
            tts_token.poolstate() / 2 ** 128,
            10849315068,
            "pool asset error"
        );
        assertEq(tts_token.poolstate() % 2 ** 128, 0, "pool construct error");
        assertEq(tts_token.balanceOf(users[2]), 109589041, "tts balance error");
    }
}
