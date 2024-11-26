// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import "forge-std/Test.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";

import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toInt128} from "../src/libraries/L_TTSwapUINT256.sol";
contract testMarketConfig is Test, GasSnapshot {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;

    uint256 marketconfig;
    function setUp() public pure {}

    function test_getLiquidFee() public pure {
        uint256 a_min = 1 * 2 ** 250;
        uint256 a_mid = 1 * 2 ** 255;
        uint256 a_max = 63 * 2 ** 250;
        assertEq(a_min.getLiquidFee(100), 1);
        assertEq(a_mid.getLiquidFee(100), 32);
        assertEq(a_max.getLiquidFee(100), 63);
    }

    function test_getSellerFee() public pure {
        uint256 a_min = 1 * 2 ** 244;
        uint256 a_mid = 1 * 2 ** 249;
        uint256 a_max = 63 * 2 ** 244;
        assertEq(a_min.getSellerFee(100), 1);
        assertEq(a_mid.getSellerFee(100), 32);
        assertEq(a_max.getSellerFee(100), 63);
    }

    function test_getGaterFee() public pure {
        uint256 a_min = 1 * 2 ** 238;
        uint256 a_mid = 1 * 2 ** 243;
        uint256 a_max = 63 * 2 ** 238;
        assertEq(a_min.getGaterFee(100), 1);
        assertEq(a_mid.getGaterFee(100), 32);
        assertEq(a_max.getGaterFee(100), 63);
    }

    function test_getReferFee() public pure {
        uint256 a_min = 1 * 2 ** 232;
        uint256 a_mid = 1 * 2 ** 237;
        uint256 a_max = 63 * 2 ** 232;
        assertEq(a_min.getReferFee(100), 1);
        assertEq(a_mid.getReferFee(100), 32);
        assertEq(a_max.getReferFee(100), 63);
    }

    function test_getCustomerFee() public pure {
        uint256 a_min = 1 * 2 ** 226;
        uint256 a_mid = 1 * 2 ** 231;
        uint256 a_max = 63 * 2 ** 226;
        assertEq(a_min.getCustomerFee(100), 1);
        assertEq(a_mid.getCustomerFee(100), 32);
        assertEq(a_max.getCustomerFee(100), 63);
    }

    function test_getPlatFee() public pure {
        uint256 a_min = 1 * 2 ** 221;
        uint256 a_mid = 1 * 2 ** 225;
        uint256 a_max = 31 * 2 ** 221;
        uint256 bb = 100;
        assertEq(a_min.getPlatFee256(bb), 1);
        assertEq(a_mid.getPlatFee256(bb), 16);
        assertEq(a_max.getPlatFee256(bb), 31);
    }
}
