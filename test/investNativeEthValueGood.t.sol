// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../Contracts/libraries/L_MarketConfig.sol";

contract investNativeETHValueGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
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
        BaseSetup.setUp();
        deal(marketcreator, 1000000 * 10 ** 6);
        vm.startPrank(marketcreator);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 246 +
            3 *
            2 ** 240 +
            5 *
            2 ** 233 +
            7 *
            2 ** 226;
        market.initMetaGood{value: 50000 * 10 ** 6}(
            address(0),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(0)).toId();
        vm.stopPrank();
    }

    function testinvestOwnNativeETHValueGood() public {
        vm.startPrank(marketcreator);

        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            marketcreator.balance,
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

        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_nativeeth_valuegood_first");
        assertEq(market.goodNum(), 1, "befor invest:good num error");
        assertEq(
            marketcreator.balance,
            900000000000,
            "after invest metagood:marketcreator account invest balance error"
        );
        assertEq(
            address(market).balance,
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
            good_.feeQunitityState.amount0(),
            5000000,
            "after invest metagood:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            0,
            "after invest metagood:metagood feeQunitityState amount1 error"
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
            "after invest metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest metagood:metagood marketcreator error"
        );

        assertEq(market.goodNum(), 1, "after invest:good num error");

        uint256 goodkey = S_GoodKey(address(0), marketcreator).toId();

        assertEq(
            good_.erc20address,
            address(0),
            "after invest metagood:metagood nativeeth error"
        );
        normalproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, 0).toId()
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

        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_nativeeth_valuegood_second");
        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_own_nativeeth_valuegood_three");
        vm.stopPrank();
    }

    function testinvestotherNativeETHValueGood() public {
        vm.startPrank(users[2]);
        deal(users[2], 300000 * 10 ** 6);

        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[2], metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);

        assertEq(
            users[2].balance,
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

        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_nativeeth_valuegood_first");

        assertEq(
            users[2].balance,
            250000000000,
            "after invest metagood:users[2] account invest balance error"
        );
        assertEq(
            address(market).balance,
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
            good_.feeQunitityState.amount0(),
            5000000,
            "after invest metagood:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            0,
            "after invest metagood:metagood feeQunitityState amount1 error"
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
            "after invest metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after invest metagood:metagood marketcreator error"
        );

        assertEq(market.goodNum(), 1, "after invest:good num error");

        uint256 goodkey = S_GoodKey(marketcreator, address(0)).toId();
        assertEq(
            good_.erc20address,
            address(0),
            "after invest metagood:metagood nativeeth error"
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

        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_nativeeth_valuegood_second");
        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        snapLastCall("invest_other_nativeeth_valuegood_three");

        vm.stopPrank();
    }
}
