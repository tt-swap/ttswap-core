# I_SimplePermit

## Functions
### transferFrom


```solidity
function transferFrom(address token, address owner, address spender, uint128 amount) external;
```

### PermitAllanceTransferFrom


```solidity
function PermitAllanceTransferFrom(address token, address owner, address spender, uint128 amount, bytes memory data)
    external;
```

### PermitTransferFrom


```solidity
function PermitTransferFrom(address token, address owner, address spender, uint128 amount, bytes memory detail)
    external;
```

## Structs
### S_PackedAllowance

```solidity
struct S_PackedAllowance {
    uint128 amount;
    uint48 expiration;
    uint48 deadline;
    uint48 nonce;
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

