// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.29;

import {IRocketDepositPool} from "../interfaces/IRocketDepositPool.sol";
import {IRocketTokenRETH} from "./IRocketTokenRETH.sol";
import {IRocketDAOProtocolSettingsDeposit} from "../interfaces/IRocketDAOProtocolSettingsDeposit.sol";
import {ERC20} from "../base/ERC20.sol";

contract rocketpoolmock is
    ERC20,
    IRocketTokenRETH,
    IRocketDepositPool,
    IRocketDAOProtocolSettingsDeposit
{
    uint256 public ETHValue;
    uint256 public rETHValue;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

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
    event deubggdeposit(uint256, uint256);
    function deposit() external payable {
        uint256 addreth = ETHValue == 0
            ? msg.value
            : ((rETHValue * msg.value) / ETHValue);
        rETHValue += addreth;
        ETHValue += msg.value;
        _mint(msg.sender, addreth);
        emit deubggdeposit(rETHValue, ETHValue);
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getDepositEnabled() external view returns (bool) {
        return true;
    }
    function getMaximumDepositPoolSize() external view returns (uint256) {
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
}
