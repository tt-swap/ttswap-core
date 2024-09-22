// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

// Import necessary contracts and libraries
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

import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";
/**
 * @title collectERC20OtherNormalGood
 * @dev Test contract for collecting ERC20 tokens from normal goods
 */
contract collectERC20OtherNormalGood is BaseSetup {
    // Use libraries
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;

    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    // State variables
    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodbtc;

    /**
     * @dev Setup function to initialize the test environment
     */
    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        initbtcgood();
        investOwnERC20NormalGood();
    }

    /**
     * @dev Initialize the meta good
     */
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

    /**
     * @dev Initialize the BTC good
     */
    function initbtcgood() public {
        vm.startPrank(users[1]);
        deal(address(btc), users[1], 10 * 10 ** 8, false);
        btc.approve(address(market), 1 * 10 ** 8 + 1);
        deal(address(usdt), users[1], 50000000 * 10 ** 6, false);
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
            toTTSwapUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig
        );
        normalgoodbtc = S_GoodKey(users[1], address(btc)).toId();
        vm.stopPrank();
    }

    /**
     * @dev Invest in own ERC20 normal good
     */
    function investOwnERC20NormalGood() public {
        vm.startPrank(users[2]);
        deal(address(btc), users[2], 10 * 10 ** 8, false);
        deal(address(usdt), users[2], 50000000 * 10 ** 6, false);
        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);
        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        vm.stopPrank();
    }

    /**
     * @dev Test disinvesting proof
     */
    function testDistinvestProof() public {
        vm.startPrank(users[2]);
        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[2], normalgoodbtc, metagood).toId()
        );

        // Check initial proof state
        L_Proof.S_ProofState memory _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            62987400630,
            "before collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            99990000,
            "before collect:proof quantity error"
        );

        assertEq(
            _proof.invest.amount0(),
            0,
            "before collect:proof contruct error"
        );
        assertEq(
            _proof.valueinvest.amount1(),
            62987400630,
            "before collect:proof valueinvest quantity error"
        );

        assertEq(
            _proof.valueinvest.amount0(),
            3511882,
            "before collect:proof  valueinvest contruct error"
        );

        // Check initial good state
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
            S_ProofKey(users[2], normalgoodbtc, metagood).toId()
        );

        // Collect proof first time
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_normalgood_first");
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
            4999,
            "after collect erc20 good:normalgoodbtc feeQuantityState amount1 error"
        );

        // Check proof state after first collection
        _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            62987400630,
            "after collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            99990000,
            "after collect:proof quantity error"
        );
        assertEq(
            _proof.invest.amount0(),
            4999,
            "after collect:proof contruct error"
        );
        assertEq(
            _proof.valueinvest.amount1(),
            62987400630,
            "after collect:proof quantity error"
        );
        assertEq(
            _proof.valueinvest.amount0(),
            5766561,
            "after collect:proof contruct error"
        );

        // Invest and collect proof second time
        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_normalgood_second");

        // Invest and collect proof third time
        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_normalgood_three");
        vm.stopPrank();
    }
}
