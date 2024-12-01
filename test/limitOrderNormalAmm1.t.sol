// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import {Test} from "forge-std/Test.sol";
import {TTSwap_LimitOrder} from "../src/TTSwap_LimitOrder.sol";
import {I_TTSwap_LimitOrderMaker} from "../src/interfaces/I_TTSwap_LimitOrderMaker.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";

contract limitOrderNormalAmm1 is Test, GasSnapshot, BaseSetup {
    address metagood;
    address normalgoodusdt;
    address normalgoodbtc;
    using L_TTSwapUINT256Library for uint256;
    function setUp() public override {
        BaseSetup.setUp();
        addlimitorder1();
        initmetagood();
        initbtcgood();
    }

    function addlimitorder1() internal {
        vm.startPrank(users[4]);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](1);
        deal(address(btc), users[4], 2 * 10 ** 8, false);
        deal(address(btc), users[5], 2, false);
        btc.approve(address(tts_limitorder), 1 * 10 ** 8);
        _order[0].timestamp = uint96(0);
        _order[0].sender = users[4];
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 10 ** 2 * 2 ** 128 + 62000;
        tts_limitorder.addLimitOrder(_order);
        vm.stopPrank();
    }
    function initmetagood() public {
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
            _goodconfig,
            defaultdata
        );
        metagood = address(usdt);
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
        market.initGood(
            metagood,
            toTTSwapUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig,
            defaultdata,
            defaultdata
        );
        normalgoodbtc = address(btc);
        vm.stopPrank();
    }

    function testAMMBatchTakeLimitOrder() public {
        vm.startPrank(users[5]);
        deal(address(usdt), users[5], 64000 * 10 ** 6, false);
        usdt.approve(address(tts_limitorder), 63000 * 10 ** 6);
        uint256[] memory orderids = new uint256[](1);
        orderids[0] = 1;
        assertEq(
            btc.balanceOf(users[4]),
            200000000,
            'before take,users[4]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[4]),
            0,
            'before take,users[4]"usdt balanceof '
        );
        assertEq(
            btc.balanceOf(users[5]),
            2,
            'before take,users[5]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[5]),
            64000 * 10 ** 6,
            'before take,users[5]"usdt balanceof '
        );

        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            'before take,address(market)"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(address(market)),
            100000000,
            'before take,address(market)"btc balanceof '
        );

        tts_limitorder.takeBatchLimitOrdersAMM(
            orderids,
            1000,
            market,
            users[5],
            true
        );

        assertEq(
            btc.balanceOf(users[4]),
            199999900,
            'after take,users[4]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[4]),
            62000,
            'after take,users[4]"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(users[5]),
            2,
            'after take,users[5]"btc balanceof '
        );
        assertEq(
            usdt.balanceOf(users[5]),
            64000000481,
            'after take,users[5]"usdt balanceof '
        );
        assertEq(
            usdt.balanceOf(address(market)),
            112999937519,
            'after take,address(this)"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(address(market)),
            100000100,
            'after take,address(this)"btc balanceof '
        );
        vm.stopPrank();
    }

    function testAMMTakeLimitOrder() public {
        vm.startPrank(users[5]);
        deal(address(usdt), users[5], 64000 * 10 ** 6, false);
        usdt.approve(address(tts_limitorder), 63000 * 10 ** 6);
        uint256[] memory orderids = new uint256[](1);
        orderids[0] = 1;
        assertEq(
            btc.balanceOf(users[4]),
            200000000,
            'before take,users[4]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[4]),
            0,
            'before take,users[4]"usdt balanceof '
        );
        assertEq(
            btc.balanceOf(users[5]),
            2,
            'before take,users[5]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[5]),
            64000 * 10 ** 6,
            'before take,users[5]"usdt balanceof '
        );

        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            'before take,address(market)"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(address(market)),
            100000000,
            'before take,address(market)"btc balanceof '
        );

        tts_limitorder.takeLimitOrderAMM(1, 1000, market, users[5]);

        assertEq(
            btc.balanceOf(users[4]),
            199999900,
            'after take,users[1]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[4]),
            62000,
            'after take,users[1]"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(users[5]),
            2,
            'after take,users[5]"btc balanceof '
        );
        assertEq(
            usdt.balanceOf(users[5]),
            64000000481,
            'after take,users[5]"usdt balanceof '
        );
        assertEq(
            usdt.balanceOf(address(market)),
            112999937519,
            'after take,address(this)"usdt balanceof '
        );

        assertEq(
            btc.balanceOf(address(market)),
            100000100,
            'after take,address(this)"btc balanceof '
        );
        vm.stopPrank();
    }
}
