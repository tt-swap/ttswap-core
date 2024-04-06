// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

abstract contract RefererManage {
    uint256 public cusomerno;
    mapping(address => uint256) public customerno;
    mapping(address => address) public relations;

    constructor() {}

    function addreferer(address referer) external {
        //U001:you refer exists
        require(customerno[msg.sender] == 0, "U0");
        cusomerno += 1;
        customerno[msg.sender] = cusomerno;
        relations[msg.sender] = referer;
    }
}
