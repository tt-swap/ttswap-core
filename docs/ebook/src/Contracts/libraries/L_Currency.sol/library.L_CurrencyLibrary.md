# L_CurrencyLibrary
*This library allows for transferring and holding native tokens and ERC20 tokens*


## State Variables
### NATIVE

```solidity
address public constant NATIVE = address(0);
```


## Functions
### transferFrom


```solidity
function transferFrom(address token, address from, uint256 amount) internal;
```

### safeTransfer


```solidity
function safeTransfer(address currency, address to, uint256 amount) internal;
```

### isNative


```solidity
function isNative(address currency) internal pure returns (bool);
```

## Errors
### NativeTransferFailed
Thrown when a native transfer fails


```solidity
error NativeTransferFailed();
```

### ValueToBiggerthanUint128

```solidity
error ValueToBiggerthanUint128();
```

### ERC20TransferFailed
Thrown when an ERC20 transfer fails


```solidity
error ERC20TransferFailed();
```

