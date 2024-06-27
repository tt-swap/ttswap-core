// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";

import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

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

        snapStart("init_metagood");
        (metagood, ) = market.initMetaGood(
            address(usdt),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig
        );
        snapEnd();

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
            T_BalanceUINT256.unwrap(good_.feeQunitityState),
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

        assertEq(market.goodNum(), 1, "after initial:good num error");
        bytes32 goodkey = S_GoodKey(address(usdt), marketcreator).toId();
        assertEq(
            market.goodseq(goodkey),
            1,
            "after initial:good key num error"
        );
        assertEq(
            market.getSellerGoodId(marketcreator, 1),
            1,
            "after initial:owner key id error"
        );
        uint256 normalproof = market.proofseq(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);
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
            market.proofseq(S_ProofKey(marketcreator, metagood, 0).toId()),
            1,
            "after initial:proof key num error"
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

        snapStart("init_metagood");
        (metagood, ) = market.initMetaGood{value: 50000 * 10 ** 6}(
            nativeCurrency,
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig
        );
        snapEnd();

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
            T_BalanceUINT256.unwrap(good_.feeQunitityState),
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

        assertEq(market.goodNum(), 1, "after initial:good num error");

        bytes32 goodkey = S_GoodKey(address(0), marketcreator).toId();
        assertEq(
            market.goodseq(goodkey),
            1,
            "after initial:good key num error"
        );

        uint256 normalproof = market.proofseq(
            S_ProofKey(marketcreator, metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);
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
            market.proofseq(S_ProofKey(marketcreator, metagood, 0).toId()),
            1,
            "after initial:proof key num error"
        );
        vm.stopPrank();
    }
    function testinitNativeETHNormalGood() public {
        vm.startPrank(users[1]);
        deal(users[1], 10 * 10 ** 8);
        deal(address(usdt), users[1], 100000 * 10 ** 6, false);
        usdt.approve(address(market), 63000 * 10 ** 6 + 1);
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "befor init erc20 good, balance of market error"
        );
        uint256 normalgoodconfig = 1 *
            2 ** 245 +
            3 *
            2 ** 238 +
            5 *
            2 ** 231 +
            7 *
            2 ** 224;
        snapStart("init normal good");
        (uint256 normalgood, uint256 proofid) = market.initGood{
            value: 1 * 10 ** 8
        }(
            metagood,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(0),
            normalgoodconfig,
            msg.sender
        );
        snapEnd();
        vm.stopPrank();

        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6 + 63000 * 10 ** 6,
            "after initial normal good, balance of market error"
        );

        assertEq(
            address(market).balance,
            1 * 10 ** 8,
            "after initial normal good, balance of market error"
        );

        assertEq(
            usdt.balanceOf(users[1]),
            100000 * 10 ** 6 - 63000 * 10 ** 6,
            "after initial normal good, balance of market error"
        );

        assertEq(
            users[1].balance,
            10 * 10 ** 8 - 1 * 10 ** 8,
            "after initial normal good, balance of market error"
        );

        L_Good.S_GoodTmpState memory metagoodstate = market.getGoodState(
            metagood
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodstate.currentState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagood currentState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodstate.investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagood investState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodstate.feeQunitityState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(((63000 * 10 ** 2) / 100) * 45, 0)
            ),
            "after initial normalgood:metagood feequnitity error"
        );

        assertEq(
            metagoodstate.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 245 +
                3 *
                2 ** 238 +
                5 *
                2 ** 231 +
                7 *
                2 ** 224,
            "after initial normalgood:metagood goodConfig error"
        );

        assertEq(
            metagoodstate.owner,
            marketcreator,
            "after initial normalgood:metagood marketcreator error"
        );

        assertEq(market.goodNum(), 2, "after initial:good num error");

        bytes32 goodkey = S_GoodKey(address(usdt), marketcreator).toId();
        assertEq(
            market.goodseq(goodkey),
            1,
            "after initial:good key num error"
        );

        ////////////////////////////////////////
        L_Good.S_GoodTmpState memory normalgoodstate = market.getGoodState(
            normalgood
        );
        assertEq(
            normalgoodstate.currentState.amount0(),
            63000 * 10 ** 6 - ((63000 * 10 ** 6) / 10000),
            "after initial normalgood:normalgood currentState amount0()"
        );

        assertEq(
            normalgoodstate.currentState.amount1(),
            1 * 10 ** 8,
            "after initial normalgood:normalgood currentState amount1()"
        );
        assertEq(
            T_BalanceUINT256.unwrap(normalgoodstate.feeQunitityState),
            T_BalanceUINT256.unwrap(toBalanceUINT256(0, 0)),
            "after initial normalgood:normalgood feequnitity error"
        );

        assertEq(
            normalgoodstate.goodConfig,
            1 * 2 ** 245 + 3 * 2 ** 238 + 5 * 2 ** 231 + 7 * 2 ** 224,
            "after initial normalgood:normalgood goodConfig error"
        );

        assertEq(
            normalgoodstate.owner,
            users[1],
            "after initial normalgood:normalgood owner error"
        );

        bytes32 normalgoodkey = S_GoodKey(address(0), users[1]).toId();
        assertEq(market.goodNum(), 2, "after initial normal:good num error");
        assertEq(
            market.goodseq(normalgoodkey),
            2,
            "after initial normal:good num error"
        );
        ///////////////////////////

        uint256 normalproof = market.proofseq(
            S_ProofKey(users[1], normalgood, metagood).toId()
        );

        assertEq(normalproof, proofid, "proof not match");
        L_Proof.S_ProofState memory _proof1 = market.getProofState(normalproof);
        assertEq(
            _proof1.state.amount0(),
            63000 * 10 ** 6 - 63000 * 10 ** 2,
            "after initial:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            1 * 10 ** 8,
            "after initial:proof normal error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            63000 * 10 ** 6 - 63000 * 10 ** 2,
            "after initial:proof value quantity error"
        );
        assertEq(
            _proof1.currentgood,
            2,
            "after initial:proof current good error"
        );
        assertEq(_proof1.valuegood, 1, "after initial:proof value good error");
        assertEq(
            market.proofseq(S_ProofKey(marketcreator, metagood, 0).toId()),
            1,
            "after initial:proof key num error"
        );
    }
}
