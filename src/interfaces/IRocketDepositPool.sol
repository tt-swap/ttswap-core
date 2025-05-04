// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IRocketDepositPool {
    function deposit() external payable;
    function getBalance() external view returns (uint256);
}
