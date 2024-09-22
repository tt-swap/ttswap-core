// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";

contract commissionNormalGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodbtc;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        initbtcgood();
        investOwnERC20NormalGood();
        collectProof();
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
            normalgoodconfig
        );
        normalgoodbtc = S_GoodKey(users[1], address(btc)).toId();
        vm.stopPrank();
    }

    function investOwnERC20NormalGood() public {
        vm.startPrank(users[1]);
        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);
        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        vm.stopPrank();
    }

    function collectProof() public {
        vm.startPrank(users[1]);
        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[1], normalgoodbtc, metagood).toId()
        );
        L_Proof.S_ProofState memory _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            125981100630,
            "before collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            199990000,
            "before collect:proof quantity error"
        );

        assertEq(
            _proof.invest.amount0(),
            0,
            "before collect:proof contruct error"
        );
        assertEq(
            _proof.valueinvest.amount1(),
            125981100630,
            "before collect:proof valueinvest quantity error"
        );

        assertEq(
            _proof.valueinvest.amount0(),
            3511882,
            "before collect:proof  valueinvest contruct error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(normalgoodbtc);
        assertEq(
            good_.currentState.amount0(),
            125981100630,
            "before collect erc20 good:normalgoodbtc currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            199990000,
            "before collect erc20 good:normalgoodbtc currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            125981100630,
            "before collect erc20 good:normalgoodbtc investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            199990000,
            "before collect erc20 good:normalgoodbtc investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            10000,
            "before collect erc20 good:normalgoodbtc feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "before collect erc20 good:normalgoodbtc feeQuantityState amount1 error"
        );
        normalproof = market.proofmapping(
            S_ProofKey(users[1], normalgoodbtc, metagood).toId()
        );

        market.collectProof(normalproof, address(0));
        snapLastCall("collect_own_erc20_normalgood_first");
        good_ = market.getGoodState(normalgoodbtc);
        assertEq(
            good_.currentState.amount0(),
            125981100630,
            "after collect erc20 good:normalgoodbtc currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            199990000,
            "after collect erc20 good:normalgoodbtc currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            125981100630,
            "after collect erc20 good:normalgoodbtc investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            199990000,
            "after collect erc20 good:normalgoodbtc investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            10000,
            "after collect erc20 good:normalgoodbtc feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            10000,
            "after collect erc20 good:normalgoodbtc feeQuantityState amount1 error"
        );

        _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            125981100630,
            "after collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            199990000,
            "after collect:proof quantity error"
        );
        assertEq(
            _proof.invest.amount0(),
            10000,
            "after collect:proof contruct error"
        );
        assertEq(
            _proof.valueinvest.amount1(),
            125981100630,
            "after collect:proof quantity error"
        );
        assertEq(
            _proof.valueinvest.amount0(),
            11533700,
            "after collect:proof contruct error"
        );

        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_own_erc20_normalgood_second");

        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_own_erc20_normalgood_three");
        vm.stopPrank();
    }

    function testQueryCommission1() public {
        uint256[] memory goodid = new uint256[](2);

        emit log("1");
        goodid[0] = metagood;

        emit log("1");
        goodid[1] = normalgoodbtc;

        emit log("1");
        uint256[] memory cm = market.queryCommission(goodid, marketcreator);

        console2.log("meta", cm[0]);
        console2.log("btc", cm[1]);
    }

    function testCollectCommission1() public {
        vm.startPrank(marketcreator);
        uint256[] memory goodid = new uint256[](2);

        emit log("1");
        goodid[0] = metagood;

        emit log("1");
        goodid[1] = normalgoodbtc;

        emit log("1");
        uint256[] memory cm = market.queryCommission(goodid, marketcreator);

        console2.log("meta before", cm[0]);
        console2.log("btc  before", cm[1]);

        market.collectCommission(goodid);

        cm = market.queryCommission(goodid, marketcreator);

        console2.log("meta after", cm[0]);
        console2.log("btc after", cm[1]);
    }
}
