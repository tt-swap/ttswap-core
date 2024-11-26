# L_CurrencyLibrary
*This library allows for transferring and holding native tokens and ERC20 tokens*


## State Variables
### NATIVE

```solidity
address public constant NATIVE = address(1);
```


### simplepermit

```solidity
address public constant simplepermit = address(2);
```


## Functions
### balanceof


```solidity
function balanceof(address token, address _sender) internal view returns (uint256 amount);
```

### transferFrom


```solidity
function transferFrom(address token, address from, address to, uint256 amount, bytes memory detail) internal;
```

### transferFrom


```solidity
function transferFrom(address token, address from, uint256 amount, bytes memory trandata) internal;
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

### ERC20TransferFailed
Thrown when an ERC20 transfer fails


```solidity
error ERC20TransferFailed();
```

## Structs
### SimplePermit

```solidity
struct SimplePermit {
    uint8 transfertype;
    bytes detail;
}
```

### S_Permit

```solidity
struct S_Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
}
```

### S_transferData

```solidity
struct S_transferData {
    uint8 transfertype;
    bytes transdata;
}
```

