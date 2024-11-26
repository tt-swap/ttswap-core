// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import {Test} from "forge-std/Test.sol";
import {TTSwap_LimitOrder} from "../src/TTSwap_LimitOrder.sol";
import {I_TTSwap_LimitOrderMaker} from "../src/interfaces/I_TTSwap_LimitOrderMaker.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
contract limitOrderNormalTaker2 is Test, GasSnapshot, BaseSetup {
    function setUp() public override {
        BaseSetup.setUp();
        addlimitorder1();
    }

    function addlimitorder1() internal {
        vm.startPrank(users[1]);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](1);
        deal(address(btc), users[1], 2 * 10 ** 8, false);
        deal(address(btc), users[2], 2, false);
        btc.approve(address(tts_limitorder), 1 * 10 ** 8);
        _order[0].timestamp = uint96(0);
        _order[0].sender = users[1];
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 10 ** 8 * 2 ** 128 + 63000 * 10 ** 6;
        tts_limitorder.addLimitOrder(_order);
        vm.stopPrank();
    }

    function testNormalTakeLimitOrder() public {
        console2.log("adf", tts_limitorder.queryOrderStatus(1));
        vm.startPrank(users[2]);
        deal(address(usdt), users[2], 64000 * 10 ** 6, false);
        deal(address(usdt), users[1], 64000 * 10 ** 6, false);
        usdt.approve(address(tts_limitorder), 64000 * 10 ** 6);
        I_TTSwap_LimitOrderMaker.S_TakeParams[]
            memory orderids = new I_TTSwap_LimitOrderMaker.S_TakeParams[](1);
        orderids[0].orderid = 1;
        orderids[0].transdata = defaultdata;
        assertEq(
            btc.balanceOf(users[1]),
            2 * 10 ** 8,
            'before take,users[1]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[1]),
            64000000000,
            'before take,users[1]"usdt balanceof '
        );
        assertEq(
            btc.balanceOf(users[2]),
            2,
            'before take,users[2]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[2]),
            64000 * 10 ** 6,
            'before take,users[2]"usdt balanceof '
        );
        tts_limitorder.takeLimitOrderNormal(orderids);
        assertEq(
            btc.balanceOf(users[1]),
            1 * 10 ** 8,
            'after take,users[1]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[1]),
            127000000000,
            'after take,users[1]"usdt balanceof '
        );
        assertEq(
            btc.balanceOf(users[2]),
            100000002,
            'after take,users[2]"btc balanceof '
        );

        assertEq(
            usdt.balanceOf(users[2]),
            1000 * 10 ** 6,
            'after take,users[2]"usdt balanceof '
        );
        vm.stopPrank();
        console2.log("adf", tts_limitorder.queryOrderStatus(1));
    }
}
