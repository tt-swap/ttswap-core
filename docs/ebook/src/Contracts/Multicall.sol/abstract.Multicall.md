# Multicall
Enables calling multiple methods in a single call to the contract


## Functions
### multicall


```solidity
function multicall(Call[] calldata data) public payable returns (bytes[] memory results);
```

## Structs
### Call

```solidity
struct Call {
    address target;
    bytes callData;
}
```

