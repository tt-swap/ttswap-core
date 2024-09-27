// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";

contract testGoodConfig is Test {
    using L_GoodConfigLibrary for uint256;

    function test_isvaluegood() public pure {
        uint256 a_min = 1 * 2 ** 255;
        assertEq(a_min.isvaluegood(), true);
        a_min = 0 * 2 ** 255;
        assertEq(a_min.isvaluegood(), false);
    }

    function test_getInvestFee() public pure {
        uint256 a_min = 1 * 2 ** 217;
        uint256 a_mid = 32 * 2 ** 217;
        uint256 a_max = 63 * 2 ** 217;
        // assertEq(a_min.getInvestFee(), 1);
        // assertEq(a_mid.getInvestFee(), 32);
        // assertEq(a_max.getInvestFee(), 63);
        assertEq(a_min.getInvestFee(10000), 1);
        assertEq(a_mid.getInvestFee(10000), 32);
        assertEq(a_max.getInvestFee(10000), 63);
    }

    function test_getDisinvestFee() public pure {
        uint256 a_min = 2 ** 211;
        uint256 a_mid = 32 * 2 ** 211;
        uint256 a_max = 63 * 2 ** 211;
        // assertEq(a_min.getDisinvestFee(), 1);
        // assertEq(a_mid.getDisinvestFee(), 32);
        // assertEq(a_max.getDisinvestFee(), 63);
        assertEq(a_min.getDisinvestFee(10000), 1);
        assertEq(a_mid.getDisinvestFee(10000), 32);
        assertEq(a_max.getDisinvestFee(10000), 63);
    }

    function test_getBuyFee() public pure {
        uint256 a_min = 1 * 2 ** 204;
        uint256 a_mid = 64 * 2 ** 204;
        uint256 a_max = 127 * 2 ** 204;
        // assertEq(a_min.getBuyFee(), 1);
        // assertEq(a_mid.getBuyFee(), 64);
        // assertEq(a_max.getBuyFee(), 127);
        assertEq(a_min.getBuyFee(10000), 1);
        assertEq(a_mid.getBuyFee(10000), 64);
        assertEq(a_max.getBuyFee(10000), 127);
    }

    function test_getSellFee() public pure {
        uint256 a_min = 1 * 2 ** 197;
        uint256 a_mid = 64 * 2 ** 197;
        uint256 a_max = 127 * 2 ** 197;
        // assertEq(a_min.getSellFee(), 1);
        // assertEq(a_mid.getSellFee(), 64);
        // assertEq(a_max.getSellFee(), 127);
        assertEq(a_min.getSellFee(10000), 1);
        assertEq(a_mid.getSellFee(10000), 64);
        assertEq(a_max.getSellFee(10000), 127);
    }

    function test_getSwapChips() public pure {
        uint256 a_min = 1 * 2 ** 187;
        uint256 a_mid = 2 * 2 ** 187;
        uint256 a_max = 1023 * 2 ** 187;
        // assertEq(a_min.getSwapChips(), 1 * 2 ** 6);
        // assertEq(a_mid.getSwapChips(), 2 * 2 ** 6);
        // assertEq(a_max.getSwapChips(), 1023 * 2 ** 6);
        assertEq(a_min.getSwapChips(10000), 156);
        assertEq(a_mid.getSwapChips(10000), 78);
        assertEq(a_max.getSwapChips(10000), 0);
    }

    function test_getDisinvestChips() public pure {
        uint256 a_min = 1 * 2 ** 177;
        uint256 a_mid = 2 * 2 ** 177;
        uint256 a_max = 1023 * 2 ** 177;
        // assertEq(a_min.getDisinvestChips(), 1);
        // assertEq(a_mid.getDisinvestChips(), 2);
        // assertEq(a_max.getDisinvestChips(), 1023);
        assertEq(a_min.getDisinvestChips(10000), 10000);
        assertEq(a_mid.getDisinvestChips(10000), 5000);
        assertEq(a_max.getDisinvestChips(10000), 9);
    }

    // function test_getGoodType() public pure {
    //     uint256 a_min = 1 * 2 ** 144;
    //     uint256 a_mid = 2 * 2 ** 144;
    //     uint256 a_max = 8589934591 * 2 ** 144;
    //     assertEq(a_min.getGoodType(), 1);
    //     assertEq(a_mid.getGoodType(), 2);
    //     assertEq(a_max.getGoodType(), 8589934591);
    // }

    // function test_getTell() public pure {
    //     uint256 a_min = 1 * 2 ** 96;
    //     uint256 a_mid = 2 * 2 ** 96;
    //     uint256 a_max = 281474976710655 * 2 ** 96;
    //     assertEq(a_min.getTell(), 1);
    //     assertEq(a_mid.getTell(), 2);
    //     assertEq(a_max.getTell(), 281474976710655);
    // }

    // function test_getLongitude() public pure {
    //     uint256 a_min = 1 * 2 ** 48;
    //     uint256 a_mid = 2 * 2 ** 48;
    //     uint256 a_max = 281474976710655 * 2 ** 48;
    //     assertEq(a_min.getLongitude(), 1);
    //     assertEq(a_mid.getLongitude(), 2);
    //     assertEq(a_max.getLongitude(), 281474976710655);
    // }

    // function test_getLatitude() public pure {
    //     uint256 a_min = 1 * 2 ** 0;
    //     uint256 a_mid = 2 * 2 ** 0;
    //     uint256 a_max = 281474976710655 * 2 ** 0;
    //     assertEq(a_min.getLatitude(), 1);
    //     assertEq(a_mid.getLatitude(), 2);
    //     assertEq(a_max.getLatitude(), 281474976710655);
    // }
}
