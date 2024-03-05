// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {S_ProofState} from "../../Contracts/types/S_ProofKey.sol";

library ProofUtil {
    function showproof(S_ProofState memory p_) public pure {
        console2.log("proof address", p_.owner);
        // console2.log('proof currentgood',T_GoodId.unwrap(p_.currentgood));
        // console2.log('proof valuegood',p_.valuegood);
        console2.log("proof extends:", uint256(p_.state.amount0()));
        console2.log("proof extends:", uint256(p_.state.amount1()));
        console2.log("proof invest:", uint256(p_.invest.amount0()));
        console2.log("proof invest:", uint256(p_.invest.amount1()));
        console2.log("proof valueinvest:", uint256(p_.valueinvest.amount0()));
        console2.log("proof valueinvest:", uint256(p_.valueinvest.amount1()));
    }
}
