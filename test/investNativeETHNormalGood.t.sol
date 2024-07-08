// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../Contracts/libraries/L_MarketConfig.sol";

contract investNativeETHNormalGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 nativeeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        initnativeethgood();
    }

    function initmetagood() public {
        BaseSetup.setUp();
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 1000000 * 10 ** 6, false);
        usdt.approve(address(market), 50000 * 10 ** 6 + 1);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 246 +
            3 *
            2 ** 240 +
            5 *
            2 ** 233 +
            7 *
            2 ** 226;
        market.initMetaGood(
            address(usdt),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(usdt)).toId();
        vm.stopPrank();
    }

    function initnativeethgood() public {
        vm.startPrank(users[1]);
        deal(users[1], 10 * 10 ** 8);
        deal(address(usdt), users[1], 50000000 * 10 ** 6, false);
        usdt.approve(address(market), 50000000 * 10 ** 6 + 1);
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "befor init erc20 good, balance of market error"
        );
        uint256 normalgoodconfig = 1 *
            2 ** 246 +
            3 *
            2 ** 240 +
            5 *
            2 ** 233 +
            7 *
            2 ** 226;
        market.initGood{value: 100000000}(
            metagood,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(0),
            normalgoodconfig
        );
        nativeeth = S_GoodKey(users[1], address(0)).toId();
        vm.stopPrank();
    }

    function testinvestOwnNativeETHNormalGood() public {
        vm.startPrank(users[1]);
        usdt.approve(address(market), 800000 * 10 ** 6 + 1);

        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[1], nativeeth, metagood).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            users[1].balance,
            900000000,
            "before invest nativeeth_normalgood:btc users[1] account invest balance error"
        );
        assertEq(
            usdt.balanceOf(users[1]),
            49937000000000,
            "before invest nativeeth_normalgood:usdt users[1] account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before invest nativeeth_normalgood:usdt address(market) account invest balance error"
        );
        assertEq(
            address(market).balance,
            100000000,
            "before invest nativeeth_normalgood:btc address(market) account invest balance error"
        );
        assertEq(
            _proof1.state.amount0(),
            62993700000,
            "before invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            100000000,
            "before invest:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            62993700000,
            "before invest:proof quantity error"
        );

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_own_nativeeth_normalgood_first");
        assertEq(
            users[1].balance,
            800000000,
            "after invest nativeeth_normalgood:btc users[1] account invest balance error"
        );
        assertEq(
            address(market).balance,
            200000000,
            "after invest nativeeth_normalgood:btc market account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            175993700000,
            "after invest nativeeth_normalgood:usdt market account invest balance error"
        );

        assertEq(
            usdt.balanceOf(users[1]),
            49874006300000,
            "after invest nativeeth_normalgood:usdt users[1] account invest balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            175981100630,
            "after invest nativeeth_normalgood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            175981100630,
            "after invest nativeeth_normalgood:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            175981100630,
            "after invest nativeeth_normalgood:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            175981100630,
            "after invest nativeeth_normalgood:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQunitityState.amount0(),
            16111252,
            "after invest nativeeth_normalgood:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            3511882,
            "after invest nativeeth_normalgood:metagood feeQunitityState amount1 error"
        );

        assertEq(
            good_.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 246 +
                3 *
                2 ** 240 +
                5 *
                2 ** 233 +
                7 *
                2 ** 226,
            "after invest nativeeth_normalgood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest nativeeth_normalgood:metagood marketcreator error"
        );

        assertEq(market.goodNum(), 2, "after invest:good num error");

        assertEq(
            good_.erc20address,
            address(usdt),
            "after invest nativeeth_normalgood:metagood erc20 error"
        );
        normalproof = market.proofmapping(
            S_ProofKey(users[1], nativeeth, metagood).toId()
        );
        _proof1 = market.getProofState(normalproof);
        assertEq(
            _proof1.state.amount0(),
            125981100630,
            "after invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount0(),
            0,
            "after invest:cur contruct fee error"
        );
        assertEq(
            _proof1.invest.amount1(),
            199990000,
            "after invest:cur quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount0(),
            3511882,
            "after invest:value contrunt fee quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            125981100630,
            "after invest:value  quantity error"
        );

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_own_nativeeth_normalgood_second");

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_own_nativeeth_normalgood_three");

        vm.stopPrank();
    }
    function testinvestotherNativeETHNormalGood() public {
        vm.startPrank(users[4]);
        deal(address(usdt), users[4], 800000 * 10 ** 6, false);
        deal(users[4], 10 * 10 ** 8);
        usdt.approve(address(market), 800000 * 10 ** 6);

        uint256 normalproof = market.proofmapping(
            S_ProofKey(users[4], nativeeth, metagood).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            users[4].balance,
            1000000000,
            "before invest nativeeth_normalgood:btc users[4] account invest balance error"
        );
        assertEq(
            usdt.balanceOf(users[4]),
            800000000000,
            "before invest nativeeth_normalgood:usdt users[4] account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before invest nativeeth_normalgood:usdt address(market) account invest balance error"
        );
        assertEq(
            address(market).balance,
            100000000,
            "before invest nativeeth_normalgood:btc address(market) account invest balance error"
        );
        assertEq(_proof1.state.amount0(), 0, "before invest:proof value error");
        assertEq(
            _proof1.invest.amount1(),
            0,
            "before invest:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "before invest:proof quantity error"
        );

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_other_nativeeth_normalgood_first");

        assertEq(
            users[4].balance,
            900000000,
            "after invest nativeeth_normalgood:btc users[4] account invest balance error"
        );
        assertEq(
            address(market).balance,
            200000000,
            "after invest nativeeth_normalgood:btc market account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            175993700000,
            "after invest nativeeth_normalgood:usdt market account invest balance error"
        );

        assertEq(
            usdt.balanceOf(users[4]),
            737006300000,
            "after invest nativeeth_normalgood:usdt users[4] account invest balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            175981100630,
            "after invest nativeeth_normalgood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            175981100630,
            "after invest nativeeth_normalgood:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            175981100630,
            "after invest nativeeth_normalgood:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            175981100630,
            "after invest nativeeth_normalgood:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQunitityState.amount0(),
            16111252,
            "after invest nativeeth_normalgood:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            3511882,
            "after invest nativeeth_normalgood:metagood feeQunitityState amount1 error"
        );

        assertEq(
            good_.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 246 +
                3 *
                2 ** 240 +
                5 *
                2 ** 233 +
                7 *
                2 ** 226,
            "after invest nativeeth_normalgood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest nativeeth_normalgood:metagood marketcreator error"
        );

        assertEq(market.goodNum(), 2, "after invest:good num error");

        assertEq(
            good_.erc20address,
            address(usdt),
            "after invest nativeeth_normalgood:metagood erc20 error"
        );
        normalproof = market.proofmapping(
            S_ProofKey(users[4], nativeeth, metagood).toId()
        );
        _proof1 = market.getProofState(normalproof);
        assertEq(
            _proof1.state.amount0(),
            62987400630,
            "after invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount0(),
            0,
            "after invest:cur contruct fee error"
        );
        assertEq(
            _proof1.invest.amount1(),
            99990000,
            "after invest:cur quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount0(),
            3511882,
            "after invest:value contrunt fee quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            62987400630,
            "after invest:value  quantity error"
        );

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_other_nativeeth_normalgood_second");

        market.investGood{value: 100000000}(nativeeth, metagood, 1 * 10 ** 8);
        snapLastCall("invest_other_nativeeth_normalgood_three");

        vm.stopPrank();
    }
}
