pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../src/libraries/L_BalanceUINT256.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";

contract testInitNormalGood is BaseSetup {
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    uint256 metagoodkey;

    function setUp() public override {
        BaseSetup.setUp();
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 100000 * 10 ** 6, false);
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
        metagoodkey = S_GoodKey(marketcreator, address(usdt)).toId();
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
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initGood(
            metagoodkey,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig
        );
        snapLastCall("init_erc20_normalgood");

        //normal good
        uint256 normalgoodkey = S_GoodKey(users[1], address(btc)).toId();

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

        L_Good.S_GoodTmpState memory metagoodkeystate = market.getGoodState(
            metagoodkey
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.currentState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagoodkey currentState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagoodkey investState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.feeQuantityState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(((63000 * 10 ** 6) / 10000), 0)
            ),
            "after initial normalgood:metagoodkey feequnitity error"
        );

        assertEq(
            metagoodkeystate.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 217 +
                3 *
                2 ** 211 +
                5 *
                2 ** 204 +
                7 *
                2 ** 197,
            "after initial normalgood:metagoodkey goodConfig error"
        );

        assertEq(
            metagoodkeystate.owner,
            marketcreator,
            "after initial normalgood:metagoodkey marketcreator error"
        );

        ////////////////////////////////////////
        L_Good.S_GoodTmpState memory normalgoodstate = market.getGoodState(
            normalgoodkey
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
            T_BalanceUINT256.unwrap(normalgoodstate.feeQuantityState),
            T_BalanceUINT256.unwrap(toBalanceUINT256(0, 0)),
            "after initial normalgood:normalgood feequnitity error"
        );

        assertEq(
            normalgoodstate.goodConfig,
            1 * 2 ** 217 + 3 * 2 ** 211 + 5 * 2 ** 204 + 7 * 2 ** 197,
            "after initial normalgood:normalgood goodConfig error"
        );

        assertEq(
            normalgoodstate.owner,
            users[1],
            "after initial normalgood:normalgood owner error"
        );

        assertEq(
            market.goodNum(),
            2,
            "after initial normal:normalgoodgood num error"
        );

        ///////////////////////////
        uint256 normalproof = market.proofmapping(
            S_ProofKey(users[1], normalgoodkey, metagoodkey).toId()
        );
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
            market.balanceOf(users[1]),
            1,
            "erc721 users[1] balance error"
        );

        assertEq(
            market.ownerOf(normalproof),
            users[1],
            "erc721 proof owner error"
        );
        vm.stopPrank();
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
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initGood{value: 1 * 10 ** 8}(
            metagoodkey,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(0),
            normalgoodconfig
        );
        snapLastCall("init_nativeETH_normalgood");
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

        L_Good.S_GoodTmpState memory metagoodkeystate = market.getGoodState(
            metagoodkey
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.currentState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagoodkey currentState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.investState),
            T_BalanceUINT256.unwrap(
                toBalanceUINT256(
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2,
                    50000 * 10 ** 6 + 63000 * 10 ** 6 - 63000 * 10 ** 2
                )
            ),
            "after initial normalgood:metagoodkey investState error"
        );
        assertEq(
            T_BalanceUINT256.unwrap(metagoodkeystate.feeQuantityState),
            T_BalanceUINT256.unwrap(toBalanceUINT256(((63000 * 10 ** 2)), 0)),
            "after initial normalgood:metagoodkey feequnitity error"
        );

        assertEq(
            metagoodkeystate.goodConfig,
            (2 ** 255) +
                1 *
                2 ** 217 +
                3 *
                2 ** 211 +
                5 *
                2 ** 204 +
                7 *
                2 ** 197,
            "after initial normalgood:metagoodkey goodConfig error"
        );

        assertEq(
            metagoodkeystate.owner,
            marketcreator,
            "after initial normalgood:metagoodkey marketcreator error"
        );

        assertEq(market.goodNum(), 2, "after initial:good num error");

        uint256 normalgoodkey = S_GoodKey(users[1], address(0)).toId();

        ////////////////////////////////////////
        L_Good.S_GoodTmpState memory normalgoodstate = market.getGoodState(
            normalgoodkey
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
            T_BalanceUINT256.unwrap(normalgoodstate.feeQuantityState),
            T_BalanceUINT256.unwrap(toBalanceUINT256(0, 0)),
            "after initial normalgood:normalgood feequnitity error"
        );

        assertEq(
            normalgoodstate.goodConfig,
            1 * 2 ** 217 + 3 * 2 ** 211 + 5 * 2 ** 204 + 7 * 2 ** 197,
            "after initial normalgood:normalgood goodConfig error"
        );

        assertEq(
            normalgoodstate.owner,
            users[1],
            "after initial normalgood:normalgood owner error"
        );

        assertEq(market.goodNum(), 2, "after initial normal:good num error");

        ///////////////////////////

        uint256 normalproof = market.proofmapping(
            S_ProofKey(users[1], normalgoodkey, metagoodkey).toId()
        );

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
            market.balanceOf(users[1]),
            1,
            "erc721 users[1] balance error"
        );

        assertEq(
            market.ownerOf(normalproof),
            users[1],
            "erc721 proof owner error"
        );
    }
}
