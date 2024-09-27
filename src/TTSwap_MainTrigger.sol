// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_TTSwap_APP} from "./interfaces/I_TTSwap_APP.sol";
import {I_TTSwap_MainTrigger} from "./interfaces/I_TTSwap_MainTrigger.sol";
contract TTSwap_MainTrigger is I_TTSwap_MainTrigger {
    address public immutable officialToken;
    address public officialMarket;
    constructor(address _officialToken) {
        officialToken = _officialToken;
    }

    function setofficialMarket(address _officialMarket) external override {
        require(msg.sender == officialToken);
        officialMarket = _officialMarket;
    }

    function main_swaptake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external override returns (bool) {
        require(msg.sender == officialMarket);
        return
            I_TTSwap_APP(triggercontract).swaptake(
                opgood,
                trade,
                currentstate,
                opstate,
                recipent
            );
    }
    function main_swapmake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external override returns (bool) {
        require(msg.sender == officialMarket);
        return
            I_TTSwap_APP(triggercontract).swaptake(
                opgood,
                trade,
                currentstate,
                opstate,
                recipent
            );
    }

    function main_invest(
        address triggercontract,
        uint256 investquanity,
        uint256 currentstate,
        address recipent
    ) external override returns (bool) {
        require(msg.sender == officialMarket);
        return
            I_TTSwap_APP(triggercontract).invest(
                investquanity,
                currentstate,
                recipent
            );
    }

    function main_divest(
        address triggercontract,
        uint256 divestquanity,
        uint256 currentstate,
        address recipent
    ) external override returns (bool) {
        require(msg.sender == officialMarket);
        return
            I_TTSwap_APP(triggercontract).divest(
                divestquanity,
                currentstate,
                recipent
            );
    }
}
