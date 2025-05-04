// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IRocketDAOProtocolSettingsDeposit {
    function getDepositEnabled() external view returns (bool);
    function getMaximumDepositPoolSize() external view returns (uint256);
}
