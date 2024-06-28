pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";
import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";

contract testInitNormalGood is BaseSetup {
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    uint256 metagood;

    function setUp() public override {
        BaseSetup.setUp();
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 100000 * 10 ** 6, false);
        usdt.approve(address(market), 50000 * 10 ** 6 + 1);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 245 +
            3 *
            2 ** 238 +
            5 *
            2 ** 231 +
            7 *
            2 ** 224;
        market.initMetaGood(
            address(usdt),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = 1;
        vm.stopPrank();
    }

    function testinitNormalGood() public {
        vm.startPrank(users[1]);
        deal(address(btc), users[1], 10 * 10 ** 8, false);
        btc.approve(address(market), 1 * 10 ** 8 + 1);
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
        snapStart("init normalgood");
        market.initGood(
            metagood,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig,
            msg.sender
        );
        uint256 normalgood = 2;
        uint256 proofid = 2;
        snapEnd();
        vm.stopPrank();
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6 + 63000 * 10 ** 6,
            "after initial normal good, balance of market error"
        );

        assertEq(
            btc.balanceOf(address(market)),
            1 * 10 ** 8,
            "after initial normal good, balance of market error"
        );

        assertEq(
            usdt.balanceOf(users[1]),
            100000 * 10 ** 6 - 63000 * 10 ** 6,
            "after initial normal good, balance of market error"
        );

        assertEq(
            btc.balanceOf(users[1]),
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
                toBalanceUINT256(((63000 * 10 ** 6) / 10000 / 100) * 45, 0)
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
            63000 * 10 ** 6 - (63000 * 10 ** 6) / 10000,
            "after initial normalgood:normalgood currentState amount0()"
        );

        assertEq(
            normalgoodstate.currentState.amount1(),
            1 * 10 ** 8,
            "after initial normalgood:normalgood currentState amount1()"
        );
        assertEq(
            T_BalanceUINT256.unwrap(normalgoodstate.investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(63000 * 10 ** 6 - 63000 * 10 ** 2, 1 * 10 ** 8)
            ),
            "after initial normalgood:normalgood investState error"
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

        bytes32 normalgoodkey = S_GoodKey(address(btc), users[1]).toId();
        assertEq(
            market.goodNum(),
            2,
            "after initial normal:normalgoodgood num error"
        );
        assertEq(
            market.goodseq(normalgoodkey),
            2,
            "after initial normal:normalgood good num error"
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
            "after initial:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            63000 * 10 ** 6 - 63000 * 10 ** 2,
            "after initial:proof quantity error"
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

    function testinitNativeETHNormalGood() public {
        vm.startPrank(users[1]);
        deal(users[1], 10 * 10 ** 8);
        deal(address(usdt), users[1], 100000 * 10 ** 6, false);
        usdt.approve(address(market), 63000 * 10 ** 6 + 1);
        assertEq(
            users[1].balance,
            10 * 10 ** 8,
            "befor init erc20 good, balance of users[1] error"
        );
        assertEq(
            address(market).balance,
            0,
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
        uint256 normalgood = 2;
        uint256 proofid = 2;
        market.initGood{value: 1 * 10 ** 8}(
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
