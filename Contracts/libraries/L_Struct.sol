// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct S_GoodKey {
    address owner;
    address erc20address;
}

struct S_ProofKey {
    address owner;
    uint256 currentgood;
    uint256 valuegood;
}
