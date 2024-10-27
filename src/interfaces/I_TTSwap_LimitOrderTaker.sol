// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface I_TTSwap_LimitOrderTaker {
    function dealCallBack(uint256[] memory orderid) external;
}
