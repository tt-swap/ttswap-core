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

contract buyNativeETHNormalGood is BaseSetup {
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
        initnativeethgood();
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

    function initnativeethgood() public {
        vm.startPrank(users[1]);
        deal(users[1], 10 * 10 ** 8);
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
        market.initGood{value: 100000000}(
            metagood,
            toBalanceUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(0),
            normalgoodconfig
        );
        normalgoodbtc = S_GoodKey(users[1], address(0)).toId();
        vm.stopPrank();
    }

    function testBuyNativeETHGoodWithoutChips() public {
        vm.startPrank(users[1]);
        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);
        assertEq(
            users[1].balance,
            900000000,
            "before buy nativeeth_normalgood:btc users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(users[1]),
            49937000000000,
            "before buy nativeeth_normalgood:usdt users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before buy nativeeth_normalgood:usdt address(market) account  balance error"
        );
        assertEq(
            address(market).balance,
            100000000,
            "before buy nativeeth_normalgood:btc address(market) account  balance error"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            T_BalanceUINT256.wrap(65000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_without_chips_first");
        assertEq(
            usdt.balanceOf(users[1]),
            49930700000000,
            "after buy nativeeth_normalgood:usdt users[1] account  balance error"
        );
        assertEq(
            users[1].balance,
            909989003,
            "after buy nativeeth_normalgood:btc users[1] account  balance error"
        );
        assertEq(
            address(market).balance,
            90010997,
            "after buy nativeeth_normalgood:btc market account  balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            119300000000,
            "after buy nativeeth_normalgood:usdt market account  balance error"
        );

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            106698110000,
            "after buy nativeeth_normalgood:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            119289290000,
            "after buy nativeeth_normalgood:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            112993700000,
            "after buy nativeeth_normalgood:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            112993700000,
            "after buy nativeeth_normalgood:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            10710000,
            "after buy nativeeth_normalgood:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after buy nativeeth_normalgood:metagood feeQuantityState amount1 error"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            T_BalanceUINT256.wrap(
                120000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128
            ),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_without_chips_second");

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            T_BalanceUINT256.wrap(
                180000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128
            ),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_without_chips_three");

        vm.stopPrank();
    }

    function testBuyNativeETHGoodWithChips() public {
        vm.startPrank(users[1]);
        uint256 goodconfig = 1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197 +
            2 *
            2 ** 216 +
            3 *
            2 ** 206;
        market.updateGoodConfig(normalgoodbtc, goodconfig);

        usdt.approve(address(market), 800000 * 10 ** 6 + 1);
        btc.approve(address(market), 10 * 10 ** 8 + 1);
        assertEq(
            users[1].balance,
            900000000,
            "before buy nativeeth_normalgood:btc users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(users[1]),
            49937000000000,
            "before buy nativeeth_normalgood:usdt users[1] account  balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            113000000000,
            "before buy nativeeth_normalgood:usdt address(market) account  balance error"
        );
        assertEq(
            address(market).balance,
            100000000,
            "before buy nativeeth_normalgood:btc address(market) account  balance error"
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            T_BalanceUINT256.wrap(65000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_chips_first_1chips");

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            T_BalanceUINT256.wrap(80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_chips_second_1chips");

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            T_BalanceUINT256.wrap(80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_chips_second_12chips");

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            T_BalanceUINT256.wrap(
                100000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128
            ),
            false,
            address(0)
        );
        snapLastCall("buy_nativeeth_normal_good_chips_second_10chips");
        vm.stopPrank();
    }
}
