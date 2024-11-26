// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";

import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256} from "../src/libraries/L_TTSwapUINT256.sol";

contract testInitMetaGood is BaseSetup {
    using L_ProofKeyLibrary for S_ProofKey;
    using L_GoodIdLibrary for S_GoodKey;
    using L_TTSwapUINT256Library for uint256;

    address metagood;

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
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig,
            defaultdata
        );
        snapLastCall("init_erc20_metagood");
        metagood = address(usdt);
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
            market.getGoodState(metagood).currentState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            market.getGoodState(metagood).investState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            market.getGoodState(metagood).feeQuantityState,
            0,
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
            S_ProofKey(marketcreator, metagood, address(0)).toKey()
        );
        S_ProofState memory _proof1 = market.getProofState(metaproof);
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
            tts_nft.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            tts_nft.ownerOf(metaproof),
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
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig,
            defaultdata
        );
        snapLastCall("init_nativeerc20_metagood");
        metagood = nativeCurrency;
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

        S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            good_.investState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            good_.feeQuantityState,
            0,
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
            S_ProofKey(marketcreator, metagood, address(0)).toKey()
        );
        S_ProofState memory _proof1 = market.getProofState(metaproof);
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
            tts_nft.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            tts_nft.ownerOf(metaproof),
            marketcreator,
            "erc721 proof owner error"
        );
        vm.stopPrank();
    }
}
