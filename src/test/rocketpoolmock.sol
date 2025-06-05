// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.29;

import {IRocketDepositPool} from "../interfaces/IRocketDepositPool.sol";
import {IRocketTokenRETH} from "../interfaces/IRocketTokenRETH.sol";
import {IRocketDAOProtocolSettingsDeposit} from "../interfaces/IRocketDAOProtocolSettingsDeposit.sol";
import {IRocketStorage} from "../interfaces/IRocketStorage.sol";
import {ERC20} from "../base/ERC20.sol";

contract rocketpoolmock is
    IRocketTokenRETH,
    IRocketDepositPool,
    IRocketDAOProtocolSettingsDeposit,
    IRocketStorage,
    ERC20
{
    uint256 public ETHValue = 10 ** 19;
    uint256 public rETHValue = 10 ** 19;

    mapping(bytes32 => address) private addressStorage;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {}

    function getAddress(bytes32 _key) external view override returns (address) {
        return addressStorage[_key];
    }

    function testrocketDAOProtocolSettingsDepositKey() external {
        bytes32 kk = keccak256(abi.encodePacked("contract.address", "rocketDAOProtocolSettingsDeposit"));
        addressStorage[kk] = address(this);
    }

    function testrocketDepositPoolKey() external {
        bytes32 kk = keccak256(abi.encodePacked("contract.address", "rocketDepositPool"));
        addressStorage[kk] = address(this);
    }

    function setAddress(bytes32 _key, address _value) external override {
        addressStorage[_key] = _value;
    }

    function getEthValue(uint256 _rethAmount) public view returns (uint256) {
        return (ETHValue * _rethAmount) / rETHValue;
    }

    function getRethValue(uint256 _ethAmount) public view returns (uint256) {
        return (rETHValue * _ethAmount) / ETHValue;
    }

    function burn(uint256 _rethAmount) external {
        uint256 _ethvalue = getEthValue(_rethAmount);
        ETHValue -= _ethvalue;
        payable(msg.sender).transfer(_ethvalue);
        _burn(msg.sender, _rethAmount);
    }

    function deposit() external payable {
        uint256 addreth = ETHValue == 0 ? msg.value : ((rETHValue * msg.value) / ETHValue);
        rETHValue += addreth;
        ETHValue += msg.value;
        _mint(msg.sender, addreth);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getDepositEnabled() external view returns (bool) {
        return true;
    }

    function getMaximumDepositPoolSize() external view override returns (uint256) {
        return 1000 ether;
    }

    function addreward() external payable {
        ETHValue += msg.value;
    }

    event EtherDeposited(address, uint256, uint256);

    receive() external payable {
        // Emit ether deposited event
        emit EtherDeposited(msg.sender, msg.value, block.timestamp);
    }

    // Mint rETH
    // Only accepts calls from the RocketDepositPool contract
    function mint(uint256 _ethAmount, address _to) external override {
        // Get rETH amount
        uint256 rethAmount = getRethValue(_ethAmount);
        // Check rETH amount
        require(rethAmount > 0, "Invalid token mint amount");
        // Update balance & supply
        _mint(_to, rethAmount);
        // Emit tokens minted event
    }
}
