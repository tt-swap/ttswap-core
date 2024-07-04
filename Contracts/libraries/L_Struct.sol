// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import {T_BalanceUINT256} from "./L_BalanceUINT256.sol";

struct S_GoodKey {
    address owner;
    address erc20address;
}

struct S_ProofKey {
    address owner;
    bytes32 currentgood;
    bytes32 valuegood;
}

struct S_Ralate {
    address gater;
    address refer;
}
