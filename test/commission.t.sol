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

contract commission is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodbtc;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        initbtcgood();
        buyERC20GoodWithChips();
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

    function initbtcgood() public {
        vm.startPrank(users[1]);
        deal(address(btc), users[1], 10 * 10 ** 8, false);
        btc.approve(address(market), 1 * 10 ** 8 + 1);
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
        market.initGood(
            metagood,
            toTTSwapUINT256(1 * 10 ** 8, 63000 * 10 ** 6),
            address(btc),
            normalgoodconfig
        );
        normalgoodbtc = S_GoodKey(users[1], address(btc)).toId();
        vm.stopPrank();
    }

    function buyERC20GoodWithChips() public {
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

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            65000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300,
            80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            6300 * 10 ** 6,
            80000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );

        market.buyGood(
            metagood,
            normalgoodbtc,
            1000000000,
            90000 * 1 * 10 ** 6 + 1 * 10 ** 8 * 2 ** 128,
            false,
            address(0)
        );
        vm.stopPrank();
    }

    function testQueryCommission() public {
        uint256[] memory goodid = new uint256[](2);

        emit log("1");
        goodid[0] = metagood;

        emit log("1");
        goodid[1] = normalgoodbtc;

        emit log("1");
        uint256[] memory cm = market.queryCommission(goodid, marketcreator);

        console2.log("meta", cm[0]);
        console2.log("btc", cm[1]);
    }
}
// function appendToArray(
//     uint256[] memory memoryArray,
//     uint256 element
// ) public pure returns (uint256[] memory) {
//     uint256[] memory newArray = new uint256[](memoryArray.length + 1);

//     for (uint i = 0; i < memoryArray.length; i++) {
//         newArray[i] = memoryArray[i];
//     }

//     newArray[memoryArray.length] = element;

//     return newArray;
// }
