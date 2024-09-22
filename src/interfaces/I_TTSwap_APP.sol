// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_APP {
    function beforeswaptake(
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function beforeswapmake(
        uint256 oppositiongood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function afterswaptake(
        uint256 oppositiongood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);
    
    function afterswapmake(
        uint256 oppositiongood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function invest(
        uint256 investquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);

    function divest(
        uint256 divestquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);
}
