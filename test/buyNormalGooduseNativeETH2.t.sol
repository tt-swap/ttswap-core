// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toUint128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toUint128} from "../src/libraries/L_TTSwapUINT256.sol";
contract buyNormalGooduseNativeETH is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;

    using L_ProofIdLibrary for S_ProofKey;

    address metagood;
    address normalgoodusdt;
    address normalgoodbtc;
    address nativeeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        initnativeethgood();
    }

    function initmetagood() public {
        BaseSetup.setUp();
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 1000000000000000, false);
        usdt.approve(address(market), 1000000000000000);

        market.initMetaGood(
            address(usdt),
            34028236692093846346337460743176821145700000000000,
            57896044629356468522362401382517449047085997165611898926976837769228995002368,
            defaultdata
        );
        metagood = address(usdt);
        vm.stopPrank();
    }

    function initnativeethgood() public {
        vm.startPrank(users[1]);
        deal(users[1], 9 * 10 ** 22);
        deal(address(usdt), users[1], 9000000000000000, false);
        usdt.approve(address(market), 9000000000000000);

        uint256 normalgoodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initGood{value: 1000000000000000}(
            metagood,
            toTTSwapUINT256(1000000000000000, 1000000000000000),
            address(1),
            normalgoodconfig,
            defaultdata,
            defaultdata
        );
        nativeeth = address(1);
        vm.stopPrank();
    }

    function testBuyNormalGoodUsingNativeETHWithChipsaa() public {
        vm.startPrank(users[1]);
        uint256 goodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197 +
            10 *
            2 ** 216 +
            10 *
            2 ** 206;
        market.updateGoodConfig(nativeeth, goodconfig);

        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        assertEq(
            users[1].balance,
            89999999000000000000000,
            "before buy nativeeth_normalgood:btc users[1] account  balance error"
        );
        // assertEq(
        //     usdt.balanceOf(users[1]),
        //     49937000000000,
        //     "before buy nativeeth_normalgood:usdt users[1] account  balance error"
        // );
        // assertEq(
        //     usdt.balanceOf(address(market)),
        //     113000000000,
        //     "before buy nativeeth_normalgood:usdt address(market) account  balance error"
        // );
        // assertEq(
        //     address(market).balance,
        //     100000000,
        //     "before buy nativeeth_normalgood:btc address(market) account  balance error"
        // );

        market.buyGood{value: 1000000000000000}(
            nativeeth,
            metagood,
            1000000000000000,
            // 1 * 10 ** 18 * 2 ** 128 + 2300 * 10 ** 6,
            10000 * 2 ** 128 + 10100,
            false,
            address(0),
            defaultdata
        );
        snapLastCall("buy_nativeeth_normal_good_chips_first_1chips");

        market.buyGood{value: 1000000000000000}(
            nativeeth,
            metagood,
            1000000000000000,
            // 1 * 10 ** 18 * 2 ** 128 + 2300 * 10 ** 6,
            10000 * 2 ** 128 + 20100,
            false,
            address(0),
            defaultdata
        );
        snapLastCall("buy_nativeeth_normal_good_chips_first_4chips");

        // market.buyGood{value: 1000000000000000}(
        //     nativeeth,
        //     metagood,
        //     1000000000000000,
        //     // 1 * 10 ** 18 * 2 ** 128 + 2300 * 10 ** 6,
        //     10000 * 2 ** 128 + 10001,
        //     false,
        //     address(0),
        //     defaultdata
        // );
        // snapLastCall("buy_nativeeth_normal_good_chips_first_1chips");

        // market.buyGood{value: 100000000000000000}(
        //     nativeeth,
        //     metagood,
        //     100000000000000000,
        //     // 1 * 10 ** 18 * 2 ** 128 + 2300 * 10 ** 6,
        //     10000 * 2 ** 128 + 41867417076230,
        //     false,
        //     address(0),
        //     defaultdata
        // );
        // snapLastCall("buy_nativeeth_normal_good_chips_first_1chips");

        // market.buyGood{value: 5000000000000000000}(
        //     nativeeth,
        //     metagood,
        //     5000000000000000000,
        //     // 1 * 10 ** 18 * 2 ** 128 + 2300 * 10 ** 6,
        //     10000 * 2 ** 128 + 418674170762300,
        //     false,
        //     address(0),
        //     defaultdata
        // );
        // snapLastCall("buy_nativeeth_normal_good_chips_first_1chips");
        //     market.buyGood{value: 6300}(
        //         normalgoodbtc,
        //         metagood,
        //         6300,
        //         80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
        //         false,
        //         address(0),
        //         defaultdata
        //     );
        //     snapLastCall("buy_nativeeth_normal_good_chips_second_1chips");

        //     market.buyGood{value: 6300 * 10 ** 1}(
        //         normalgoodbtc,
        //         metagood,
        //         6300 * 10 ** 1,
        //         80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
        //         false,
        //         address(0),
        //         defaultdata
        //     );
        //     snapLastCall("buy_nativeeth_normal_good_chips_second_12chips");

        //     market.buyGood{value: 6300 * 10 ** 2}(
        //         normalgoodbtc,
        //         metagood,
        //         6300 * 10 ** 2,
        //         100000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
        //         false,
        //         address(0),
        //         defaultdata
        //     );
        //     snapLastCall("buy_nativeeth_normal_good_chips_second_10chips");
        //     vm.stopPrank();
        //
    }
}
