// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_APP {
    function beforeswap(
        uint256 state,
        uint256 feestate1,
        uint256 feestate2,
        address recipent
    ) external returns (bool);

    function afterswap(
        uint256 goodid,
        uint256 state,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function beforinvest(
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);
    function afterinvest(
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function befordevest(
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function afterdevest(
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);
    function beforeinitproof(
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function beforeupdateproof(
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function afterinitproof(
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function afterupdateproof(
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
}
