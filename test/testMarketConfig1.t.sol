// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-gas-snapshot/GasSnapshot.sol";
import "forge-std/Test.sol";
import {L_MarketConfigLibrary} from "../Contracts/libraries/L_MarketConfig.sol";
import {T_BalanceUINT256, toBalanceUINT256, L_BalanceUINT256Library} from "../Contracts/libraries/L_BalanceUINT256.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";

contract testconfig is Test, GasSnapshot {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_BalanceUINT256Library for T_BalanceUINT256;
    uint256 marketconfig =
        81562183917421901855786361352751956561780156203962646020495653018153967943680;
    uint256 goodconfig =
        58014493144340224047723362035128774673999617126840714024924520715586495315968;
    uint256 kk =
        (2 ** 255) + 1 * 2 ** 246 + 3 * 2 ** 240 + 5 * 2 ** 233 + 7 * 2 ** 226;

    T_BalanceUINT256 aa =
        T_BalanceUINT256.wrap(
            34028236692093846346337460743176821145700000000000
        );
    // function testmarketconfig() public {
    //     console2.log("1", marketconfig.getLiquidFee());
    //     console2.log("2", marketconfig.getSellerFee());
    //     console2.log("3", marketconfig.getGaterFee());
    //     console2.log("4", marketconfig.getReferFee());
    //     console2.log("5", marketconfig.getCustomerFee());
    //     console2.log("6", marketconfig.getPlatFee());
    // }
    // function testBalance() public {
    //     console2.log("1", aa.amount0());
    //     console2.log("2", aa.amount1());
    // }

    function testgoodconfig() public view {
        console2.log(goodconfig.isvaluegood());
        console2.log("goodconfig2", goodconfig.getInvestFee());
        console2.log("goodconfig3", goodconfig.getDisinvestFee());
        console2.log("goodconfig4", goodconfig.getBuyFee());
        console2.log("goodconfig4", goodconfig.getSellFee());
        console2.log("goodconfig5", goodconfig.getSwapChips());
        console2.log("goodconfig6", goodconfig.getDisinvestChips());
    }
}
