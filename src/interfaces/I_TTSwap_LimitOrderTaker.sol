// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface I_TTSwap_LimitOrderTaker {
    function takeLimitOrder(
        S_takeGoodInputPrams memory _inputData,
        uint96 _tolerance,
        address _takecaller
    ) external payable returns (bool _isSuccess);
    function batchTakelimitOrder(
        bytes calldata _inputData,
        uint96 _tolerance,
        address _takecaller,
        uint8 ordernum
    ) external payable returns (bool[] memory);
}

struct S_takeGoodInputPrams {
    address fromerc20;
    address toerc20;
    uint256 swapQuantity;
    address sender;
}
