// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/src/console2.sol";
import "forge-std/src/Script.sol";
import {Permit2} from "permit2/src/Permit2.sol";

bytes32 constant SALT = bytes32(uint256(0x0000000000000000000000000000000000000000d3af2663da51c10215000000));

contract DeployPermit2 is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        Permit2 permit2 = new Permit2{salt: SALT}();

        console2.log("Permit2  Deployed:", address(permit2));
        vm.stopBroadcast();
    }
}
