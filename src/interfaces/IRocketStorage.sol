pragma solidity >0.5.0 <0.9.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IRocketStorage {
    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    // Setters
    function setAddress(bytes32 _key, address _value) external;
}
