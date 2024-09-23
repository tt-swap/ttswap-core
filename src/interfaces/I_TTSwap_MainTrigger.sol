// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_MainTrigger {
    function setofficialMarket(address _officialMarket) external;

    function main_swaptake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function main_swapmake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function main_invest(
        address triggercontract,
        uint256 investquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);

    function main_divest(
        address triggercontract,
        uint256 divestquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);
}
