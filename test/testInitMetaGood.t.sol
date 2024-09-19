// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";

import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256} from "../src/libraries/L_BalanceUINT256.sol";

contract testInitMetaGood is BaseSetup {
    using L_ProofIdLibrary for S_ProofKey;
    using L_GoodIdLibrary for S_GoodKey;

    uint256 metagood;

    function setUp() public override {
        BaseSetup.setUp();
    }
    function testinitMetaGood() public {
        vm.startPrank(marketcreator);
        uint256 goodconfig = 2 ** 255;
        usdt.mint(marketcreator, 100000);
        usdt.approve(address(market), 50000 * 10 ** 6);

        assertEq(
            usdt.balanceOf(marketcreator),
            100000 * 10 ** 6,
            "before initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            0,
            "before initial metagood:market account initial balance error"
        );

        market.initMetaGood(
            address(usdt),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig
        );
        snapLastCall("init_erc20_metagood");
        metagood = S_GoodKey(marketcreator, address(usdt)).toId();
        assertEq(
            usdt.balanceOf(marketcreator),
            100000 * 10 ** 6 - 50000 * 10 ** 6,
            "after initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "after initial metagood:market account initial balance error"
        );

        assertEq(
            T_BalanceUINT256.unwrap(market.getGoodState(metagood).currentState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6)
            ),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(market.getGoodState(metagood).investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6)
            ),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(
                market.getGoodState(metagood).feeQuantityState
            ),
            T_BalanceUINT256.unwrap(toBalanceUINT256(0, 0)),
            "after initial metagood:metagood feequnitity error"
        );

        assertEq(
            market.getGoodState(metagood).goodConfig,
            2 ** 255,
            "after initial metagood:metagood goodConfig error"
        );

        assertEq(
            market.getGoodState(metagood).owner,
            marketcreator,
            "after initial metagood:metagood marketcreator error"
        );

        uint256 metaproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(metaproof);
        assertEq(
            _proof1.state.amount0(),
            50000 * 10 ** 6,
            "after initial:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            50000 * 10 ** 6,
            "after initial:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after initial:proof quantity error"
        );

        assertEq(
            market.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            market.ownerOf(metaproof),
            marketcreator,
            "erc721 proof owner error"
        );

        vm.stopPrank();
    }

    function testinitNativeMetaGood() public {
        vm.startPrank(marketcreator);
        address nativeCurrency = address(0);
        uint256 goodconfig = 2 ** 255;
        vm.deal(marketcreator, 100000 * 10 ** 6);
        assertEq(
            marketcreator.balance,
            100000 * 10 ** 6,
            "before initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            0,
            "before initial metagood:market account initial balance error"
        );

        market.initMetaGood{value: 50000 * 10 ** 6}(
            nativeCurrency,
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig
        );
        snapLastCall("init_nativeerc20_metagood");
        metagood = S_GoodKey(marketcreator, nativeCurrency).toId();
        assertEq(
            marketcreator.balance,
            100000 * 10 ** 6 - 50000 * 10 ** 6,
            "after initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            address(market).balance,
            50000 * 10 ** 6,
            "after initial metagood:market account initial balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            T_BalanceUINT256.unwrap(good_.currentState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6)
            ),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(good_.investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6)
            ),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(good_.feeQuantityState),
            T_BalanceUINT256.unwrap(toBalanceUINT256(0, 0)),
            "after initial metagood:metagood feequnitity error"
        );

        assertEq(
            good_.goodConfig,
            2 ** 255,
            "after initial metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after initial metagood:metagood marketcreator error"
        );
        uint256 metaproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(metaproof);
        assertEq(
            _proof1.state.amount0(),
            50000 * 10 ** 6,
            "after initial:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            50000 * 10 ** 6,
            "after initial:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after initial:proof quantity error"
        );
        assertEq(
            market.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            market.ownerOf(metaproof),
            marketcreator,
            "erc721 proof owner error"
        );
        vm.stopPrank();
    }
}
