// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";

contract disinvestERC20OtherValueGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofKeyLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        investOwnERC20ValueGood();
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

    function investOwnERC20ValueGood() public {
        vm.startPrank(users[1]);
        deal(address(usdt), users[1], 1000000 * 10 ** 6, false);
        usdt.approve(address(market), 200000 * 10 ** 6 + 1);
        market.investGood(metagood, 0, 50000 * 10 ** 6);
        vm.stopPrank();
    }

    function testDistinvestProof() public {
        vm.startPrank(users[1]);
        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[1], metagood, 0).toKey()
        );
        L_Proof.S_ProofState memory _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            49995000000,
            "before disinvest:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            49995000000,
            "before disinvest:proof quantity error"
        );

        assertEq(
            _proof.invest.amount0(),
            0,
            "before disinvest:proof contruct error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "before disinvest erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "before disinvest erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "before disinvest erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "before disinvest erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "before disinvest erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "before disinvest erc20 good:metagood feeQuantityState amount1 error"
        );

        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_erc20_valuegood_first");
        good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            89995000000,
            "after disinvest erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            89995000000,
            "after disinvest erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            89995000000,
            "after disinvest erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            89995000000,
            "after disinvest erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            7499975,
            "after disinvest erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after disinvest erc20 good:metagood feeQuantityState amount1 error"
        );

        _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            39995000000,
            "after disinvest:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            39995000000,
            "after disinvest:proof quantity error"
        );
        assertEq(
            _proof.invest.amount0(),
            0,
            "after disinvest:proof contruct error"
        );
        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_erc20_valuegood_second");

        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_erc20_valuegood_three");
        vm.stopPrank();
    }
}
