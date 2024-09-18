// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/MarketManager.sol";
import {s_share} from "../src/interfaces/I_TTS.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../src/libraries/L_BalanceUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";

contract ttstoken is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodbtc;
    uint256 ttsgood;

    uint256 proofid;

    function setUp() public override {
        BaseSetup.setUp();
        vm.warp(1);
        initmetagood();

        vm.warp(1 + 86410);
        initbtcgood();
        vm.warp(1 + 86410 * 2);
        init_ttstoken();
    }

    function initmetagood() public {
        BaseSetup.setUp();
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 1000000 * 10 ** 6, false);
        usdt.approve(address(market), 50000 * 10 ** 6 + 1);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initMetaGood(
            address(usdt),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(usdt)).toId();
        vm.stopPrank();
    }

    function initbtcgood() public {
        vm.startPrank(users[5]);
        deal(address(btc), users[5], 10 * 10 ** 8, false);
        btc.approve(address(market), 1 * 10 ** 8 + 1);
        deal(address(usdt), users[5], 50000000 * 10 ** 6, false);
        usdt.approve(address(market), 50000000 * 10 ** 6 + 1);
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "before init erc20 good, balance of market error"
        );
        uint256 normalgoodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initGood(
            metagood,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig
        );
        proofid = market.totalSupply();
        normalgoodbtc = S_GoodKey(users[5], address(btc)).toId();
        vm.stopPrank();
    }

    function testttstokensupply() public {
        vm.startPrank(marketcreator);
        console2.log("TTS token supply", tts_token.totalSupply());
        vm.stopPrank();
    }

    function init_ttstoken() public {
        vm.startPrank(users[2]);
        deal(address(usdt), users[2], 2000000 * 10 ** 6, false);
        usdt.approve(address(tts_token), 2000000 * 10 ** 6);
        tts_token.publicSell(100000 * 10 ** 6);
        assertEq(
            usdt.balanceOf(address(tts_token)),
            100000 * 10 ** 6,
            "after public sell1,ttstoken.balance of usdt"
        );

        assertEq(
            tts_token.balanceOf(users[2]),
            120000 * 10 ** 7,
            "after public sell1,users2.balance of tts_token"
        );

        assertEq(
            tts_token.totalSupply(),
            120000 * 10 ** 7,
            "ttstokentotalsupply1"
        );

        tts_token.publicSell(100000 * 10 ** 6);
        snapLastCall("tts_token public sell");
        assertEq(
            usdt.balanceOf(address(tts_token)),
            200000 * 10 ** 6,
            "after public sell2,ttstoken.balance of usdt"
        );

        assertEq(
            tts_token.balanceOf(users[2]),
            2200000 * 10 ** 6,
            "after public sell2,users2.balance of tts_token"
        );

        assertEq(
            tts_token.totalSupply(),
            220000 * 10 ** 7,
            "ttstokentotalsupply2"
        );

        tts_token.publicSell(100000 * 10 ** 6);
        assertEq(
            usdt.balanceOf(address(tts_token)),
            300000 * 10 ** 6,
            "after public sell3,ttstoken.balance of usdt"
        );

        assertEq(
            tts_token.balanceOf(users[2]),
            3200000 * 10 ** 6,
            "after public sell3,users2.balance of tts_token"
        );

        assertEq(
            tts_token.totalSupply(),
            320000 * 10 ** 7,
            "ttstokentotalsupply3"
        );
        tts_token.publicSell(100000 * 10 ** 6);
        assertEq(
            usdt.balanceOf(address(tts_token)),
            400000 * 10 ** 6,
            "after public sell4,ttstoken.balance of usdt"
        );

        assertEq(
            tts_token.balanceOf(users[2]),
            4000000 * 10 ** 6,
            "after public sell4,users2.balance of tts_token"
        );

        assertEq(
            tts_token.totalSupply(),
            400000 * 10 ** 7,
            "ttstokentotalsupply4"
        );
        tts_token.publicSell(100000 * 10 ** 6);
        assertEq(
            usdt.balanceOf(address(tts_token)),
            500000 * 10 ** 6,
            "after public sell5,ttstoken.balance of usdt"
        );

        assertEq(
            tts_token.balanceOf(users[2]),
            4800000 * 10 ** 6,
            "after public sell5,users2.balance of tts_token"
        );

        assertEq(
            tts_token.totalSupply(),
            480000 * 10 ** 7,
            "ttstokentotalsupply5"
        );
        uint256 normalgoodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;

        deal(address(usdt), users[2], 2000000 * 10 ** 6, false);
        usdt.approve(address(market), 2000000 * 10 ** 6);
        tts_token.approve(address(market), 1000000 * 10 ** 6);
        market.initGood(
            metagood,
            toBalanceUINT256(100000 * 10 ** 6, 10000 * 10 ** 6),
            address(tts_token),
            normalgoodconfig
        );
        ttsgood = S_GoodKey(users[2], address(tts_token)).toId();
        market.buyGood(
            metagood,
            ttsgood,
            5000 * 10 ** 6,
            T_BalanceUINT256.wrap(65000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128),
            false,
            address(0)
        );

        vm.stopPrank();

        vm.startPrank(marketcreator);
        s_share memory _share = s_share(users[1], 500000 * 10 ** 6, 0, 6);
        tts_token.addShare(_share);
        tts_token.setEnv(ttsgood, metagood, address(market));
        vm.stopPrank();

        vm.startPrank(users[1]);
        (
            address recipient,
            uint128 leftamount,
            uint120 metric,
            uint8 chips
        ) = tts_token.shares(0);
        tts_token.shareMint(0);
        (recipient, leftamount, metric, chips) = tts_token.shares(0);
        vm.stopPrank();
        vm.startPrank(marketcreator);
        tts_token.burnShare(0);
        (recipient, leftamount, metric, chips) = tts_token.shares(0);
        console2.log("leftamount:", uint256(leftamount));
        console2.log("metric:", uint256(metric));
        console2.log("chips", uint256(chips));
        console2.log("recipient", recipient);
        tts_token.withdrawPublicSell(10000 * 10 ** 6, users[4]);
        console2.log("usdt balance of users4", usdt.balanceOf(users[4]));
        console2.log(
            "usdt balance of ttstoken",
            usdt.balanceOf(address(tts_token))
        );

        vm.stopPrank();

        vm.startPrank(users[5]);

        console2.log(
            "before: LASTTIME ",
            uint256(tts_token.stakestate().amount0())
        );
        console2.log(
            "before: POOLVALUE",
            uint256(tts_token.stakestate().amount1())
        );

        console2.log(
            "before: ALL ASSET",
            uint256(tts_token.poolstate().amount0())
        );
        console2.log(
            "before: CONSTRUCT",
            uint256(tts_token.poolstate().amount1())
        );

        market.disinvestProof(proofid, 1 * 10 ** 7, address(0));

        console2.log(
            "after: LASTTIME ",
            uint256(tts_token.stakestate().amount0())
        );
        console2.log(
            "after: POOLVALUE",
            uint256(tts_token.stakestate().amount1())
        );

        console2.log(
            "after: ALL ASSET",
            uint256(tts_token.poolstate().amount0())
        );
        console2.log(
            "after: CONSTRUCT",
            uint256(tts_token.poolstate().amount1())
        );
        vm.stopPrank();
    }

    function testishigher() public view {
        console2.log(
            "ishigher:",
            market.ishigher(ttsgood, metagood, 1 * 2 ** 128 + 10)
        );
        console2.log(market.getGoodState(ttsgood).currentState.amount0());
        console2.log(market.getGoodState(ttsgood).currentState.amount1());
        console2.log(market.getGoodState(metagood).currentState.amount0());
        console2.log(market.getGoodState(metagood).currentState.amount1());
    }
}
