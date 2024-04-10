// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./interfaces/I_Referer.sol";
abstract contract RefererManage is I_Referer {
    uint256 public cusomerno;
    mapping(address => uint256) public customerno;
    mapping(address => address) public relations;

    constructor() {}

    function addreferer(address _referer) external override {
        require(customerno[msg.sender] == 0, "U1");
        cusomerno += 1;
        customerno[msg.sender] = cusomerno;
        relations[msg.sender] = _referer;
    }
}
