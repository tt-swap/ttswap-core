// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;
import {I_TTSwap_APP} from "../interfaces/I_TTSwap_APP.sol";
contract MyGoodTriggerAction is I_TTSwap_APP {
    uint256 public befortradeamounttake;
    uint256 public aftertradeamounttake;
    uint256 public befortradeamountmake;
    uint256 public aftertradeamountmake;
    uint256 public investamount;
    uint256 public divestamount;

    constructor() {}
    function swaptake(
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool) {
        befortradeamounttake += trade;

        return false;
    }

    function swapmake(
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool) {
        befortradeamountmake += trade;

        return false;
    }

    function invest(
        uint256 investquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool) {
        investamount += investquanity;

        return false;
    }

    function divest(
        uint256 divestquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool) {
        divestamount += divestquanity;
        return false;
    }
}
