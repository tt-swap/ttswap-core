// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_MainTrigger {
    function main_beforeswap(
        address triggercontract,
        uint256 trade,
        uint256 currentstate,
        uint256 depositstate,
        address recipent
    ) external returns (bool);

    function main_afterswap(
        address triggercontract,
        uint256 goodid,
        uint256 state,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function main_beforinvest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);
    function main_afterinvest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function main_befordevest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);

    function main_afterdevest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external returns (bool);
    function main_beforeinitproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function main_beforeupdateproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function main_afterinitproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
    function main_afterupdateproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external returns (bool);
}
