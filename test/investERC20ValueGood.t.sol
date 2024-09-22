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

contract investERC20ValueGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
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
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(usdt)).toId();
        vm.stopPrank();
    }

    function testinvestOwnERC20ValueGood() public {
        vm.startPrank(marketcreator);
        usdt.approve(address(market), 200000 * 10 ** 6 + 1);

        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            usdt.balanceOf(marketcreator),
            950000000000,
            "before invest metagood:marketcreator account invest balance error"
        );
        assertEq(
            _proof1.state.amount0(),
            50000 * 10 ** 6,
            "before invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            50000 * 10 ** 6,
            "before invest:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "before invest:proof quantity error"
        );

        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_erc20_valuegood_first");

        assertEq(
            usdt.balanceOf(marketcreator),
            900000000000,
            "after invest metagood:marketcreator account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            100000000000,
            "after invest metagood:market account invest balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "after invest metagood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "after invest metagood:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "after invest metagood:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "after invest metagood:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "after invest metagood:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after invest metagood:metagood feeQuantityState amount1 error"
        );

        assertEq(
            good_.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 217 +
                3 *
                2 ** 211 +
                5 *
                2 ** 204 +
                7 *
                2 ** 197,
            "after invest metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest metagood:metagood marketcreator error"
        );
        _proof1 = market.getProofState(normalproof);
        assertEq(
            _proof1.state.amount0(),
            99995000000,
            "after invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            99995000000,
            "after invest:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after invest:proof quantity error"
        );

        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_erc20_valuegood_second");
        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_erc20_valuegood_three");
        vm.stopPrank();
    }

    function testinvestotherERC20ValueGood() public {
        vm.startPrank(users[2]);
        deal(address(usdt), users[2], 300000 * 10 ** 6, false);
        usdt.approve(address(market), 300000 * 10 ** 6 + 1);

        uint256 normalproof = market.proofmapping(
            S_ProofKey(users[2], metagood, 0).toId()
        );
        console2.log("1111111", normalproof);
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            usdt.balanceOf(users[2]),
            300000000000,
            "before invest metagood:users[2] account invest balance error"
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

        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_erc20_valuegood_first");

        assertEq(
            usdt.balanceOf(users[2]),
            250000000000,
            "after invest metagood:users[2] account invest balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            100000000000,
            "after invest metagood:market account invest balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "after invest metagood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "after invest metagood:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "after invest metagood:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "after invest metagood:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "after invest metagood:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after invest metagood:metagood feeQuantityState amount1 error"
        );

        assertEq(
            good_.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 217 +
                3 *
                2 ** 211 +
                5 *
                2 ** 204 +
                7 *
                2 ** 197,
            "after invest metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest metagood:metagood marketcreator error"
        );

        normalproof = market.proofmapping(
            S_ProofKey(users[2], metagood, 0).toId()
        );
        _proof1 = market.getProofState(normalproof);
        assertEq(
            _proof1.state.amount0(),
            49995000000,
            "after invest:proof value error"
        );
        assertEq(
            _proof1.invest.amount0(),
            0,
            "after invest:proof contruct fee error"
        );
        assertEq(
            _proof1.invest.amount1(),
            49995000000,
            "after invest:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after invest:proof quantity error"
        );

        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_erc20_valuegood_second");
        market.investGood(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_erc20_valuegood_three");
        vm.stopPrank();
    }
}
