// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface I_TTSwap_LimitOrderTaker {
    function takeLimitOrder(
        bytes memory _inputData,
        uint96 _tolerance,
        address _takecaller
    ) external payable returns (bool _isSuccess);

    function batchTakelimitOrder(
        bytes[] memory _inputData,
        uint96 _tolerance,
        address _takecaller
    ) external payable returns (bool[] memory result);
}

struct S_takeGoodInputPrams {
    address _goodid1;
    address _goodid2;
    uint256 _swapQuantity;
    address _orderowner;
}
