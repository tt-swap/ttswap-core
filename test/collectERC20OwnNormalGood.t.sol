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

contract collectERC20OwnNormalGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
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
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
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

    function testCollectProof() public {
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
            good_.feeQunitityState.amount0(),
            10000,
            "before collect erc20 good:normalgoodbtc feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            0,
            "before collect erc20 good:normalgoodbtc feeQunitityState amount1 error"
        );
        normalproof = market.proofmapping(
            S_ProofKey(users[1], normalgoodbtc, metagood).toId()
        );

        market.collectProof(normalproof, address(0), address(0));
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
            good_.feeQunitityState.amount0(),
            10000,
            "after collect erc20 good:normalgoodbtc feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            10000,
            "after collect erc20 good:normalgoodbtc feeQunitityState amount1 error"
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
        market.collectProof(normalproof, address(0), address(0));
        snapLastCall("collect_own_erc20_normalgood_second");

        market.investGood(normalgoodbtc, metagood, 1 * 10 ** 8);
        market.collectProof(normalproof, address(0), address(0));
        snapLastCall("collect_own_erc20_normalgood_three");
        vm.stopPrank();
    }
}
