# I_TTSwap_LimitOrderTaker

## Functions
### takeLimitOrder


```solidity
function takeLimitOrder(S_takeGoodInputPrams memory _inputData, uint96 _tolerance, address _takecaller)
    external
    payable
    returns (bool _isSuccess);
```

### batchTakelimitOrder


```solidity
function batchTakelimitOrder(bytes calldata _inputData, uint96 _tolerance, address _takecaller, uint8 ordernum)
    external
    payable
    returns (bool[] memory);
```

