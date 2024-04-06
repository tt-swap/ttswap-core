// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";

contract testMarketConfig is Test {
    using L_GoodConfigLibrary for uint256;

    function test_isvaluegood() public {
        uint256 a_min = 1 * 2 ** 255;
        assertEq(a_min.isvaluegood(), true);
        a_min = 0 * 2 ** 255;
        assertEq(a_min.isvaluegood(), false);
    }

    function test_getInvestFee() public {
        uint256 a_min = 1 * 2 ** 245;
        uint256 a_mid = 1 * 2 ** 254;
        uint256 a_max = 1023 * 2 ** 245;
        assertEq(a_min.getInvestFee(), 1);
        assertEq(a_mid.getInvestFee(), 512);
        assertEq(a_max.getInvestFee(), 1023);
        assertEq(a_min.getInvestFee(10000), 1);
        assertEq(a_mid.getInvestFee(10000), 512);
        assertEq(a_max.getInvestFee(10000), 1023);
    }

    function test_getDisinvestFee() public {
        uint256 a_min = 1 * 2 ** 235;
        uint256 a_mid = 1 * 2 ** 244;
        uint256 a_max = 1023 * 2 ** 235;
        assertEq(a_min.getDisinvestFee(), 1);
        assertEq(a_mid.getDisinvestFee(), 512);
        assertEq(a_max.getDisinvestFee(), 1023);
        assertEq(a_min.getDisinvestFee(10000), 1);
        assertEq(a_mid.getDisinvestFee(10000), 512);
        assertEq(a_max.getDisinvestFee(10000), 1023);
    }

    function test_getBuyFee() public {
        uint256 a_min = 1 * 2 ** 225;
        uint256 a_mid = 1 * 2 ** 234;
        uint256 a_max = 1023 * 2 ** 225;
        assertEq(a_min.getBuyFee(), 1);
        assertEq(a_mid.getBuyFee(), 512);
        assertEq(a_max.getBuyFee(), 1023);
        assertEq(a_min.getBuyFee(10000), 1);
        assertEq(a_mid.getBuyFee(10000), 512);
        assertEq(a_max.getBuyFee(10000), 1023);
    }

    function test_getSellFee() public {
        uint256 a_min = 1 * 2 ** 215;
        uint256 a_mid = 1 * 2 ** 224;
        uint256 a_max = 1023 * 2 ** 215;
        assertEq(a_min.getSellFee(), 1);
        assertEq(a_mid.getSellFee(), 512);
        assertEq(a_max.getSellFee(), 1023);
        assertEq(a_min.getSellFee(10000), 1);
        assertEq(a_mid.getSellFee(10000), 512);
        assertEq(a_max.getSellFee(10000), 1023);
    }

    function test_getSwapChips() public {
        uint256 a_min = 1 * 2 ** 205;
        uint256 a_mid = 1 * 2 ** 214;
        uint256 a_max = 1023 * 2 ** 205;
        assertEq(a_min.getSwapChips(), 1 * 2 ** 6);
        assertEq(a_mid.getSwapChips(), 512 * 2 ** 6);
        assertEq(a_max.getSwapChips(), 1023 * 2 ** 6);
        assertEq(a_min.getSwapChips(10000), 156);
        assertEq(a_mid.getSwapChips(10000), 0);
        assertEq(a_max.getSwapChips(10000), 0);
    }
}
