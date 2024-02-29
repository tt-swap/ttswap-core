// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {S_GoodState} from "../../Contracts/types/S_GoodKey.sol";
import {T_Currency} from "../../Contracts/types/T_Currency.sol";
import {L_GoodConfigLibrary} from "../../Contracts/libraries/L_GoodConfig.sol";

library GoodUtil {
    using L_GoodConfigLibrary for uint256;

    function showGood(S_GoodState memory p_) public pure {
        console2.log("good owner:", p_.owner);
        //showconfig(p_.goodConfig);
        console2.log("good erc20address:", T_Currency.unwrap(p_.erc20address));
        console2.log("good currentState:", uint256(p_.currentState.amount0()));
        console2.log("good currentState:", uint256(p_.currentState.amount1()));
        console2.log("good investState:", uint256(p_.investState.amount0()));
        console2.log("good investState:", uint256(p_.investState.amount1()));
        console2.log(
            "good feeQunitityState:",
            uint256(p_.feeQunitityState.amount0())
        );
        console2.log(
            "good feeQunitityState:",
            uint256(p_.feeQunitityState.amount1())
        );
    }

    function showconfig(uint256 _goodConfig) public pure {
        console2.log("good goodConfig:isvaluegood:", _goodConfig.isvaluegood());
        console2.log(
            "good goodConfig:getInvestFee:",
            uint256(_goodConfig.getInvestFee())
        );
        console2.log(
            "good goodConfig:getDisinvestFee:",
            uint256(_goodConfig.getDisinvestFee())
        );
        console2.log(
            "good goodConfig:getBuyFee:",
            uint256(_goodConfig.getBuyFee())
        );
        console2.log(
            "good goodConfig:getSellFee:",
            uint256(_goodConfig.getSellFee())
        );
        console2.log(
            "good goodConfig:getSwapChips:",
            uint256(_goodConfig.getSwapChips())
        );
    }
}
