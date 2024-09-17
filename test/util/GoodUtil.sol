// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {console2} from "forge-std/Test.sol";
import {L_Good} from "../../src/libraries/L_Good.sol";
import {L_CurrencyLibrary} from "../../src/libraries/L_Currency.sol";
import {L_GoodConfigLibrary} from "../../src/libraries/L_GoodConfig.sol";

library GoodUtil {
    using L_GoodConfigLibrary for uint256;
    using L_CurrencyLibrary for address;

    function showGood(L_Good.S_GoodTmpState memory p_) public pure {
        console2.log("good owner:", p_.owner);
        //showconfig(p_.goodConfig);
        console2.log("good erc20address:", p_.erc20address);
        console2.log("good currentState:", uint256(p_.currentState.amount0()));
        console2.log("good currentState:", uint256(p_.currentState.amount1()));
        console2.log("good investState:", uint256(p_.investState.amount0()));
        console2.log("good investState:", uint256(p_.investState.amount1()));
        console2.log(
            "good feeQuantityState:",
            uint256(p_.feeQuantityState.amount0())
        );
        console2.log(
            "good feeQuantityState:",
            uint256(p_.feeQuantityState.amount1())
        );
    }
}
