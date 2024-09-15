// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

// Import necessary contracts and libraries
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

// Test contract for collecting ERC20 other value good
contract collectERC20OtherValueGood is BaseSetup {
    // Use libraries
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    // Define state variables
    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodeth;

    // Setup function
    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        investOwnERC20ValueGood();
    }

    // Initialize meta good
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

    // Invest in own ERC20 value good
    function investOwnERC20ValueGood() public {
        vm.startPrank(users[1]);
        deal(address(usdt), users[1], 1000000 * 10 ** 6, false);
        usdt.approve(address(market), 200000 * 10 ** 6 + 1);
        market.investGood(metagood, 0, 50000 * 10 ** 6);
        vm.stopPrank();
    }

    // Test disinvest proof
    function testDistinvestProof() public {
        vm.startPrank(users[1]);

        // Get normal proof
        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[1], metagood, 0).toId()
        );

        // Check initial proof state
        L_Proof.S_ProofState memory _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            49995000000,
            "before collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            49995000000,
            "before collect:proof quantity error"
        );

        assertEq(
            _proof.invest.amount0(),
            0,
            "before collect:proof contruct error"
        );

        // Check initial good state
        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "before collect erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "before collect erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "before collect erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "before collect erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "before collect erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "before collect erc20 good:metagood feeQuantityState amount1 error"
        );

        // Collect proof first time
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_valuegood_first");

        // Check good state after first collection
        good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "after collect erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "after collect erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "after collect erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "after collect erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "after collect erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            2499874,
            "after collect erc20 good:metagood feeQuantityState amount1 error"
        );

        // Check proof state after first collection
        _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            49995000000,
            "after collect:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            49995000000,
            "after collect:proof quantity error"
        );
        assertEq(
            _proof.invest.amount0(),
            2499874,
            "after collect:proof contruct error"
        );

        // Invest again
        market.investGood(metagood, 0, 50000 * 10 ** 6);

        // Collect proof second time
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_valuegood_second");

        // Invest third time
        market.investGood(metagood, 0, 50000 * 10 ** 6);

        // Collect proof third time
        market.collectProof(normalproof, address(0));
        snapLastCall("collect_other_erc20_valuegood_three");

        vm.stopPrank();
    }
}
