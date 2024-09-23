// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import "../src/example/MyGoodTriggerAction.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";

contract goodApptrigger is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofKeyLibrary for S_ProofKey;
    using L_TTSwapUINT256Library for uint256;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodbtc;

    MyGoodTriggerAction mytrigger;

    function setUp() public override {
        console2.log("1");
        mytrigger = new MyGoodTriggerAction();
        console2.log("2");
        BaseSetup.setUp();
        console2.log("3");
        initmetagood();
        console2.log("4");
        initbtcgood();
        console2.log("5");
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
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(usdt)).toId();
        market.setGoodTrigger(metagood, address(mytrigger), 15);
        vm.stopPrank();
    }

    function initbtcgood() public {
        vm.startPrank(users[1]);
        deal(address(btc), users[1], 10 * 10 ** 8, false);
        btc.approve(address(market), 1 * 10 ** 8 + 1);
        deal(address(usdt), users[1], 50000000 * 10 ** 6, false);
        usdt.approve(address(market), 50000000 * 10 ** 6 + 1);
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "befor init erc20 good, balance of market error"
        );
        uint256 normalgoodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        console2.log("6");
        market.initGood(
            metagood,
            toTTSwapUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig
        );
        console2.log("7");
        normalgoodbtc = S_GoodKey(users[1], address(btc)).toId();

        market.setGoodTrigger(normalgoodbtc, address(mytrigger), 15);
        vm.stopPrank();
    }

    function testBuyERC20GoodWithoutChips() public {
        vm.startPrank(users[1]);
        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);
        assertEq(
            btc.balanceOf(users[1]),
            900000000,
            "before buy erc20_normalgood:btc users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(users[1]),
            49937000000000,
            "before buy erc20_normalgood:usdt users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before buy erc20_normalgood:usdt address(market) account  balance error"
        );
        assertEq(
            btc.balanceOf(address(market)),
            100000000,
            "before buy erc20_normalgood:btc address(market) account  balance error"
        );

        console2.log(
            "metagood",
            market.getGoodState(metagood).goodConfig.swaptake()
        );
        console2.log(
            "metagood",
            market.getGoodState(metagood).goodConfig.swapmake()
        );

        console2.log(
            "metagood",
            market.getGoodState(metagood).goodConfig.invest()
        );
        console2.log(
            "metagood",
            market.getGoodState(metagood).goodConfig.divest()
        );

        console2.log(
            "normalgoodbtc",
            market.getGoodState(normalgoodbtc).goodConfig.swaptake()
        );
        console2.log(
            "normalgoodbtc",
            market.getGoodState(normalgoodbtc).goodConfig.swapmake()
        );

        console2.log(
            "normalgoodbtc",
            market.getGoodState(normalgoodbtc).goodConfig.invest()
        );
        console2.log(
            "normalgoodbtc",
            market.getGoodState(normalgoodbtc).goodConfig.divest()
        );
        console2.log(
            "normalgoodbtc",
            market.getGoodState(normalgoodbtc).trigger
        );
        console2.log("normalgoodbtc", market.getGoodState(metagood).trigger);

        console2.log("triggeraddress", address(mytrigger));
        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            65000 * 10 ** 6 + 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_without_chips_first_withtwotrigger"
        );
        console2.log("bbbbbbb");
        assertEq(
            usdt.balanceOf(users[1]),
            49930700000000,
            "after buy erc20_normalgood:usdt users[1] account  balance error1"
        );
        assertEq(
            btc.balanceOf(users[1]),
            909989003,
            "after buy erc20_normalgood:btc users[1] account  balance error"
        );
        assertEq(
            btc.balanceOf(address(market)),
            90010997,
            "after buy erc20_normalgood:btc market account  balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            119300000000,
            "after buy erc20_normalgood:usdt market account  balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            106698110000,
            "after buy erc20_normalgood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            119289290000,
            "after buy erc20_normalgood:metagood currentState amount1 error"
        );

        assertEq(
            good_.feeQuantityState.amount0(),
            10710000,
            "after buy erc20_normalgood:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after buy erc20_normalgood:metagood feeQuantityState amount1 error"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            180000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_without_chips_second_withtwotrigger"
        );
        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            180000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_without_chips_three_withtwotrigger"
        );
        vm.stopPrank();
    }

    function testBuyERC20GoodWithChips() public {
        vm.startPrank(users[1]);
        uint256 goodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197 +
            2 *
            2 ** 216 +
            3 *
            2 ** 206;
        market.updateGoodConfig(normalgoodbtc, goodconfig);

        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);

        assertEq(
            btc.balanceOf(users[1]),
            900000000,
            "before buy erc20_normalgood:btc users[1] account  balance error"
        );

        assertEq(
            usdt.balanceOf(users[1]),
            49937000000000,
            "before buy erc20_normalgood:usdt users[1] account  balance error"
        );

        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before buy erc20_normalgood:usdt address(market) account  balance error"
        );

        assertEq(
            btc.balanceOf(address(market)),
            100000000,
            "before buy erc20_normalgood:btc address(market) account  balance error"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            65000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall("buy_erc20_normal_good_chips_first_1chips_withtwotrigger");

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_chips_second_1chips_withtwotrigger"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_chips_second_12chips_withtwotrigger"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            1000000000,
            90000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        snapLastCall(
            "buy_erc20_normal_good_chips_second_2chips_withtwotrigger"
        );
        vm.stopPrank();
    }
}
