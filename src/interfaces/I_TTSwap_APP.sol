// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_APP {
    function swaptake(
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);

    function swapmake(
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
