// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import {Test} from "forge-std/Test.sol";
import {TTSwap_LimitOrder} from "../src/TTSwap_LimitOrder.sol";
import {I_TTSwap_LimitOrderMaker} from "../src/interfaces/I_TTSwap_LimitOrderMaker.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
contract normallimitorder is Test, GasSnapshot, BaseSetup {
    function setUp() public override {
        BaseSetup.setUp();
    }
    function testsetMaxfreeremain() public {
        uint96 maxfreeremian = tts_limitorder.maxfreeremain();
        vm.startPrank(marketcreator);
        console2.log("maxfreeremian", maxfreeremian);
        maxfreeremian = 40445300;
        tts_limitorder.setMaxfreeRemain(40445300);

        vm.stopPrank();
        assertEq(
            tts_limitorder.maxfreeremain(),
            40445300,
            "the maxfreeremain set error"
        );
    }
    function testchangemarketcreator() public {
        vm.startPrank(marketcreator);
        tts_limitorder.changemarketcreator(users[5]);
        assertEq(
            tts_limitorder.marketcreator(),
            users[5],
            "market change  set error"
        );
        vm.stopPrank();
    }

    function testaddauths() public {
        vm.startPrank(marketcreator);
        tts_limitorder.addauths(users[5], 1);
        assertEq(tts_limitorder.auths(users[5]), 1, "market set auths error");
        vm.stopPrank();
    }

    function testremoveauths() public {
        vm.startPrank(marketcreator);
        tts_limitorder.addauths(users[5], 1);
        tts_limitorder.removeauths(users[5]);
        assertEq(
            tts_limitorder.auths(users[5]),
            0,
            "market remove auths error"
        );
        vm.stopPrank();
    }
    function testaddlimitorder1() public {
        vm.startPrank(marketcreator);
        tts_limitorder.addauths(users[1], 1);
        vm.stopPrank();

        console2.log(1, 1);
        vm.startPrank(users[1]);
        console2.log(2, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](1);
        console2.log(3, 1);
        //  S_orderDetails[] memory _order_output;
        console2.log(4, 1);
        _order[0].timestamp = uint96(0);
        _order[0].sender = msg.sender;
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 2 ** 128 + 1;
        // _order.push(S_orderDetails(0, address(0), address(0), address(0), 0));
        console2.log(5, 1);
        tts_limitorder.addLimitOrder(_order);
        console2.log(6, 1);
        uint256[] memory orderid = new uint256[](1);
        console2.log(7, 1);
        orderid[0] = 1;
        console2.log(8, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order_output = tts_limitorder.queryLimitOrder(orderid);
        console2.log(9, 1);
        assertEq(
            _order[0].sender,
            _order_output[0].sender,
            "order sender eroor"
        );
        assertEq(
            _order[0].fromerc20,
            _order_output[0].fromerc20,
            "order fromerc20 eroor"
        );
        assertEq(
            _order[0].toerc20,
            _order_output[0].toerc20,
            "order toerc20 eroor"
        );
        assertEq(
            _order[0].amount,
            _order_output[0].amount,
            "order toerc20 eroor"
        );
        vm.warp(block.timestamp + 40525200);
        tts_limitorder.cleandeadorder(orderid, false);
        vm.stopPrank();
    }
    function testaddlimitorder2() public {
        console2.log(1, 1);
        vm.startPrank(users[1]);
        console2.log(2, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](2);
        console2.log(3, 1);
        //  S_orderDetails[] memory _order_output;
        console2.log(4, msg.sender);

        _order[0].timestamp = uint96(0);
        _order[0].sender = msg.sender;
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 2 ** 128 + 1;

        _order[1].timestamp = uint96(0);
        _order[1].sender = msg.sender;
        _order[1].fromerc20 = address(btc);
        _order[1].toerc20 = address(usdt);
        _order[1].amount = 1 * 2 ** 128 + 1;
        // _order.push(S_orderDetails(0, address(0), address(0), address(0), 0));
        console2.log(5, 1);
        tts_limitorder.addLimitOrder(_order);
        console2.log(6, 1);
        uint256[] memory orderid = new uint256[](2);
        console2.log(7, 1);
        orderid[0] = 1;
        orderid[1] = 2;
        console2.log(8, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order_output = new I_TTSwap_LimitOrderMaker.S_orderDetails[](
                2
            );
        _order_output = tts_limitorder.queryLimitOrder(orderid);
        console2.log(9, 1);
        assertEq(
            _order[0].sender,
            _order_output[0].sender,
            "order sender eroor"
        );
        assertEq(
            _order[0].fromerc20,
            _order_output[0].fromerc20,
            "order fromerc20 eroor"
        );
        assertEq(
            _order[0].toerc20,
            _order_output[0].toerc20,
            "order toerc20 eroor"
        );
        assertEq(
            _order[0].amount,
            _order_output[0].amount,
            "order amount eroor"
        );
        vm.stopPrank();
    }

    function testaddlimitorder3() public {
        console2.log(1, 1);
        vm.startPrank(users[1]);
        console2.log(2, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](3);
        console2.log(3, 1);
        //  S_orderDetails[] memory _order_output;
        console2.log(4, 1);
        _order[0].timestamp = uint96(0);
        _order[0].sender = users[1];
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 2 ** 128 + 1;
        _order[1].timestamp = uint96(0);
        _order[1].sender = users[1];
        _order[1].fromerc20 = address(btc);
        _order[1].toerc20 = address(usdt);
        _order[1].amount = 1 * 2 ** 128 + 1;
        _order[2].timestamp = uint96(0);
        _order[2].sender = users[1];
        _order[2].fromerc20 = address(btc);
        _order[2].toerc20 = address(usdt);
        _order[2].amount = 1 * 2 ** 128 + 1;
        // _order.push(S_orderDetails(0, address(0), address(0), address(0), 0));
        console2.log(5, 1);
        tts_limitorder.addLimitOrder(_order);
        console2.log(6, 1);
        uint256[] memory orderid = new uint256[](3);
        console2.log(7, 1);
        orderid[0] = 1;
        orderid[1] = 2;
        orderid[2] = 3;
        console2.log(8, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order_output = tts_limitorder.queryLimitOrder(orderid);
        console2.log(9, 1);
        assertEq(
            _order[0].sender,
            _order_output[0].sender,
            "order sender eroor"
        );
        assertEq(
            _order[0].fromerc20,
            _order_output[0].fromerc20,
            "order fromerc20 eroor"
        );
        assertEq(
            _order[0].toerc20,
            _order_output[0].toerc20,
            "order toerc20 eroor"
        );
        assertEq(
            _order[0].amount,
            _order_output[0].amount,
            "order toerc20 eroor"
        );

        I_TTSwap_LimitOrderMaker.S_orderDetails memory _orderkk;
        _orderkk.timestamp = uint96(0);
        _orderkk.sender = msg.sender;
        _orderkk.fromerc20 = address(usdt);
        _orderkk.toerc20 = address(btc);
        _orderkk.amount = 2 * 2 ** 128 + 2;
        tts_limitorder.updateLimitOrder(2, _orderkk);
        tts_limitorder.removeLimitOrder(2);
        vm.stopPrank();
        vm.startPrank(marketcreator);
        vm.warp(block.timestamp + 40525200);
        tts_limitorder.addauths(marketcreator, 1);
        tts_limitorder.cleandeadorder(orderid, false);
        vm.stopPrank();
    }

    function testaddlimitorder4() public {
        console2.log(1, block.timestamp);
        vm.startPrank(users[1]);

        vm.warp(1);
        console2.log(2, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order = new I_TTSwap_LimitOrderMaker.S_orderDetails[](3);
        console2.log(3, 1);
        //  S_orderDetails[] memory _order_output;
        console2.log(4, 1);
        _order[0].timestamp = uint96(0);
        _order[0].sender = users[1];
        _order[0].fromerc20 = address(btc);
        _order[0].toerc20 = address(usdt);
        _order[0].amount = 1 * 2 ** 128 + 1;
        _order[1].timestamp = uint96(0);
        _order[1].sender = users[1];
        _order[1].fromerc20 = address(btc);
        _order[1].toerc20 = address(usdt);
        _order[1].amount = 1 * 2 ** 128 + 1;
        _order[2].timestamp = uint96(0);
        _order[2].sender = users[1];
        _order[2].fromerc20 = address(btc);
        _order[2].toerc20 = address(usdt);
        _order[2].amount = 1 * 2 ** 128 + 1;
        // _order.push(S_orderDetails(0, address(0), address(0), address(0), 0));
        console2.log(5, 1);
        tts_limitorder.addLimitOrder(_order);
        console2.log(6, 1);
        uint256[] memory orderid = new uint256[](3);
        console2.log(7, 1);
        orderid[0] = 1;
        orderid[1] = 2;
        orderid[2] = 3;
        console2.log(8, 1);
        I_TTSwap_LimitOrderMaker.S_orderDetails[]
            memory _order_output = tts_limitorder.queryLimitOrder(orderid);
        console2.log(9, 1);
        assertEq(
            _order[0].sender,
            _order_output[0].sender,
            "order sender eroor"
        );
        assertEq(
            _order[0].fromerc20,
            _order_output[0].fromerc20,
            "order fromerc20 eroor"
        );
        assertEq(
            _order[0].toerc20,
            _order_output[0].toerc20,
            "order toerc20 eroor"
        );
        assertEq(
            _order[0].amount,
            _order_output[0].amount,
            "order toerc20 eroor"
        );

        I_TTSwap_LimitOrderMaker.S_orderDetails memory _orderkk;
        _orderkk.timestamp = uint96(0);
        _orderkk.sender = msg.sender;
        _orderkk.fromerc20 = address(usdt);
        _orderkk.toerc20 = address(btc);
        _orderkk.amount = 2 * 2 ** 128 + 2;
        tts_limitorder.updateLimitOrder(2, _orderkk);
        tts_limitorder.removeLimitOrder(2);
        vm.stopPrank();
        vm.startPrank(marketcreator);
        vm.warp(40625200);
        tts_limitorder.addauths(marketcreator, 1);
        tts_limitorder.cleandeadorder(orderid, false);
        vm.stopPrank();
    }
}
