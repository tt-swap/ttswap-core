// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_TTSwap_APP} from "./interfaces/I_TTSwap_APP.sol";
import {I_TTSwap_MainTrigger} from "./interfaces/I_TTSwap_MainTrigger.sol";
contract officialTrigge is I_TTSwap_MainTrigger {
    function main_beforeswap(
        address triggercontract,
        uint256 state,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).beforeswap(state, feestate, recipent);
    }
    function main_afterswap(
        address triggercontract,
        uint256 goodid,
        uint256 state,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).afterswap(
                goodid,
                state,
                feestate,
                recipent
            );
    }
    function main_beforinvest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).beforinvest(
                goodid,
                investstate,
                feestate,
                recipent
            );
    }
    function main_afterinvest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).afterinvest(
                goodid,
                investstate,
                feestate,
                recipent
            );
    }

    function main_befordevest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).befordevest(
                goodid,
                investstate,
                feestate,
                recipent
            );
    }

    function main_afterdevest(
        address triggercontract,
        uint256 goodid,
        uint256 investstate,
        uint256 feestate,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).afterdevest(
                goodid,
                investstate,
                feestate,
                recipent
            );
    }
    function main_beforeinitproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).beforeinitproof(
                proofid,
                investstate,
                amount,
                recipent
            );
    }
    function main_beforeupdateproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).beforeupdateproof(
                proofid,
                investstate,
                amount,
                recipent
            );
    }
    function main_afterinitproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).afterinitproof(
                proofid,
                investstate,
                amount,
                recipent
            );
    }
    function main_afterupdateproof(
        address triggercontract,
        uint256 proofid,
        uint256 investstate,
        uint128 amount,
        address recipent
    ) external override returns (bool) {
        return
            I_TTSwap_APP(triggercontract).afterupdateproof(
                proofid,
                investstate,
                amount,
                recipent
            );
    }
}
