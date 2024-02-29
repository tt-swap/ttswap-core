// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {T_GoodId} from "./T_GoodId.sol";
import {T_BalanceUINT256} from "./T_BalanceUINT256.sol";

struct S_ProofKey {
    address owner;
    T_GoodId currentgood;
    T_GoodId togood;
}

struct S_ProofState {
    address owner;
    T_GoodId currentgood;
    T_GoodId valuegood;
    T_BalanceUINT256 extends; //value
    T_BalanceUINT256 invest; //normalgood   contruct:investquanity
    T_BalanceUINT256 valueinvest; //valuegood contruct:investquanity
}
