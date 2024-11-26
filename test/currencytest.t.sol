// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
// import {IAllowanceTransfer} from "../interfaces/IAllowanceTransfer.sol";
// import {ISignatureTransfer} from "../interfaces/ISignatureTransfer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {L_CurrencyLibrary} from "../src/libraries/L_Currency.sol";
import {ERC20PermitTest} from "../src/ERC20PermitTest.sol";
contract currenccytest is Test {
    using L_CurrencyLibrary for address;
    ERC20Permit internal usdt;

    function setUp() external {
        usdt = new ERC20PermitTest("USDT", "USDT");
    }

    function testaddress0() public {
        address nativecurrency = address(1);
        address user10 = address(100);
        vm.startPrank(user10);
        deal(user10, 10);
        console2.log("before user10's native balance1:", user10.balance);
        console2.log(
            "before address(this)'s native balance1:",
            address(this).balance
        );
        nativecurrency.transferFrom(user10, address(this), 1, "0x");

        console2.log("after user10's native balance1:", user10.balance);
        console2.log(
            "after address(this)'s native balance1:",
            address(this).balance
        );
        vm.stopPrank();
    }
}
