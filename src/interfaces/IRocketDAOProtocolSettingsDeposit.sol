// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IRocketDAOProtocolSettingsDeposit {
    function getDepositEnabled() external view returns (bool);
    function getMaximumDepositPoolSize() external view returns (uint256);
}
