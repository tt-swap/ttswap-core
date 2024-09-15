// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {L_CurrencyLibrary} from "../Contracts/libraries/L_Currency.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract nativeGoodPay is Test, BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    using L_CurrencyLibrary for address;
    using L_BalanceUINT256Library for T_BalanceUINT256;

    uint256 metagood;
    uint256 nativenormalgood;
    uint256 normalgoodbtc;
    uint256 normalgoodeth;
    uint256 normalgoodusdt;

    uint256 metaproofid;

    function setUp() public override {
        BaseSetup.setUp();
        NativeETHInitMetagood();
        NativeETHInitNormalgood();
        initnormalgood();
        //goodInfo(metagood);
        //goodInfo(normalgoodbtc);
        //goodInfo(normalgoodeth);
    }

    function NativeETHInitMetagood() public {
        vm.startPrank(marketcreator);
        uint256 sentBalance = 2 ether;
        address nativeCurrency = address(0);

        vm.deal(marketcreator, 1000 ether);
        nativeCurrency.safeTransfer(address(1), sentBalance);
        console2.log(
            "1marketcreator.balance before swap",
            marketcreator.balance
        );
        console2.log("1address(1).balance before swap", address(1).balance);
        console2.log("1market.balance before swap", address(market).balance);
        uint256 _goodConfig = (2 ** 255) +
            8 *
            2 ** 217 +
            8 *
            2 ** 211 +
            8 *
            2 ** 204 +
            8 *
            2 ** 197;
        console2.log("good config is valueGood?:", _goodConfig.isvaluegood());

        market.initMetaGood{value: 1 ether}(
            nativeCurrency,
            toBalanceUINT256(uint128(4000 * 10 ** 6), 1 * 10 ** 18),
            _goodConfig
        );
        metagood = S_GoodKey(marketcreator, nativeCurrency).toId();
        vm.stopPrank();

        console2.log(
            "1marketcreator.balance after swap",
            marketcreator.balance
        );
        console2.log("1address(1).balance after swap", address(1).balance);
        console2.log("1market.balance after swap", address(market).balance);
        assertEq(
            marketcreator.balance,
            997000000000000000000,
            "marketCreateor balance"
        );
        assertEq(address(1).balance, 2000000000000000000, "address(1).balance");
        assertEq(
            address(market).balance,
            1000000000000000000,
            "address(market).balance"
        );
    }

    function NativeETHInitNormalgood() public {
        address jeck = address(99);
        vm.deal(jeck, 1 ether);
        uint256 _goodConfig = 8 *
            2 ** 217 +
            8 *
            2 ** 211 +
            8 *
            2 ** 204 +
            8 *
            2 ** 197;

        console2.log("2jeck.balance before swap", jeck.balance);
        console2.log("2market.balance before swap", address(market).balance);
        console2.log("2good config is valueGood?:", _goodConfig.isvaluegood());

        market.initGood{value: 0.9 ether}(
            metagood,
            toBalanceUINT256(9 * 10 ** 17, 9 * 10 ** 17),
            address(0),
            _goodConfig
        );
        nativenormalgood = 2;
        console2.log("2jeck.balance before swap", jeck.balance);
        console2.log("2market.balance before swap", address(market).balance);
        console2.log("2good config is valueGood?:", _goodConfig.isvaluegood());
        assertEq(
            marketcreator.balance,
            997000000000000000000,
            "marketCreateor balance"
        );
        assertEq(jeck.balance, 1000000000000000000, "jeck.balance");
        assertEq(
            address(market).balance,
            1900000000000000000,
            "address(market).balance"
        );
    }

    function initnormalgood() public {
        address edson = address(101);
        deal(address(usdt), edson, 100000 * 10 ** 6, false);
        vm.deal(edson, 10 ether);
        vm.startPrank(edson);
        usdt.approve(address(market), 50000 * 10 ** 6);
        uint256 _goodConfig = 8 *
            2 ** 217 +
            8 *
            2 ** 211 +
            8 *
            2 ** 204 +
            8 *
            2 ** 197;
        market.initGood{value: 2 ether}(
            metagood,
            toBalanceUINT256(8000 * 10 ** 6, 2 ether),
            address(usdt),
            _goodConfig
        );
        normalgoodusdt = S_GoodKey(edson, address(usdt)).toId();
        goodInfo(normalgoodusdt);
        console2.log("usdt good id:", normalgoodusdt);
        vm.stopPrank();
    }

    function testbuymetagood1() public {
        address york = address(105);
        deal(address(usdt), york, 100000 * 10 ** 6, false);
        vm.startPrank(york);
        usdt.approve(address(market), 10000 * 10 ** 6);

        console2.log("3york.balance before swap", york.balance);
        console2.log("3market.balance before swap", address(market).balance);
        console2.log("3york.usdt balance before swap", usdt.balanceOf(york));
        console2.log(
            "3market.usdt before swap",
            usdt.balanceOf(address(market))
        );
        console2.log(
            "tbalance.amount0()",
            T_BalanceUINT256.wrap(10000 * 2 ** 128 + 1).amount0()
        );

        console2.log(
            "tbalance.amount0()",
            T_BalanceUINT256.wrap(10000 * 2 ** 128 + 1).amount1()
        );
        market.buyGood(
            normalgoodusdt,
            metagood,
            4000 * 10 ** 6,
            T_BalanceUINT256.wrap(
                90000 * 1 * 10 ** 6 * 2 ** 128 + 1 * 10 ** 18
            ),
            false,
            address(0)
        );
        vm.stopPrank();
        console2.log("3york.balance after swap", york.balance);
        console2.log("3market.balance after swap", address(market).balance);
        console2.log("3york.usdt balance after swap", usdt.balanceOf(york));
        console2.log(
            "3market.usdt after swap",
            usdt.balanceOf(address(market))
        );
        assertEq(usdt.balanceOf(york), 96000000000, "3york.balance after swap");
        assertEq(
            usdt.balanceOf(address(market)),
            12000000000,
            "market.balance after swap"
        );
    }

    function testNativeGoodPay() public {
        address Tom = address(100);
        address Jeck = address(200);
        vm.startPrank(Tom);
        deal(Tom, 1000);
        console2.log("5-1Tom balance : ", Tom.balance);
        console2.log("5-1Jeck balance : ", Jeck.balance);
        console2.log("5-1market balance : ", address(market).balance);
        market.payGood{value: 50}(metagood, 50, Jeck);
        snapLastCall("pay_nativeeth_good_first");
        assertEq(Tom.balance, 950);
        assertEq(Jeck.balance, 50);
        console2.log("5-2Tom balance : ", Tom.balance);
        console2.log("5-2Jeck balance : ", Jeck.balance);
        console2.log("5-2market balance : ", address(market).balance);
        market.payGood{value: 50}(metagood, 50, Jeck);
        snapLastCall("pay_nativeeth_good_second");
        vm.stopPrank();
    }

    function testErc20GoodPay() public {
        address Tom = address(100);
        address Jeck = address(200);
        vm.startPrank(Tom);
        deal(address(usdt), Tom, 100);
        usdt.approve(address(market), 100);
        console2.log("6-1Tom balance : ", usdt.balanceOf(Tom));
        console2.log("6-1Jeck balance : ", usdt.balanceOf(Jeck));
        console2.log("6-1market balance : ", usdt.balanceOf(address(market)));
        market.payGood(normalgoodusdt, 50, Jeck);
        snapLastCall("pay_erc20_good_first");
        console2.log("6-2Tom balance : ", usdt.balanceOf(Tom));
        console2.log("6-2Jeck balance : ", usdt.balanceOf(Jeck));
        console2.log("6-2market balance : ", usdt.balanceOf(address(market)));
        market.payGood(normalgoodusdt, 50, Jeck);
        snapLastCall("pay_erc20_good_second");
        vm.stopPrank();
    }

    function goodInfo(uint256 _good1) public view {
        console2.log(_good1, "************************");
        console2.log(
            "price good1's value",
            market.getGoodState(_good1).currentState.amount0()
        );
        console2.log(
            "price good1's quantity",
            market.getGoodState(_good1).currentState.amount1()
        );

        console2.log(
            "price good1's invest value",
            market.getGoodState(_good1).investState.amount0()
        );
        console2.log(
            "price good1's invest quantity",
            market.getGoodState(_good1).investState.amount1()
        );

        console2.log(
            "price good1's fee",
            market.getGoodState(_good1).feeQuantityState.amount0()
        );

        console2.log(
            "price good1's contrunct fee",
            market.getGoodState(_good1).feeQuantityState.amount1()
        );
    }

    function proofInfo(uint256 _proofid) public view {
        console2.log(_proofid, "*********proof***************");
        console2.log(
            "getProofState's state amount0",
            market.getProofState(_proofid).state.amount0()
        );
        console2.log(
            "getProofState's state amount1 ",
            market.getProofState(_proofid).state.amount1()
        );

        console2.log(
            "getProofState's invest amount0",
            market.getProofState(_proofid).invest.amount0()
        );
        console2.log(
            "getProofState's invest amount1",
            market.getProofState(_proofid).invest.amount1()
        );

        console2.log(
            "getProofState's valueinvest amount0",
            market.getProofState(_proofid).valueinvest.amount0()
        );

        console2.log(
            "getProofState's valueinvest amount1",
            market.getProofState(_proofid).valueinvest.amount1()
        );

        console2.log(
            "getProofState's currentgood",
            market.getProofState(_proofid).currentgood
        );

        console2.log(
            "getProofState's valuegood",
            market.getProofState(_proofid).valuegood
        );
    }

    function getcompareprice(uint256 good1, uint256 good2) public view {
        console2.log(
            market.getGoodState(good1).currentState.amount0() *
                market.getGoodState(good2).currentState.amount1(),
            market.getGoodState(good1).currentState.amount1() *
                market.getGoodState(good2).currentState.amount0()
        );
    }
}
