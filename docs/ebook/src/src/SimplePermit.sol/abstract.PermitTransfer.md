# PermitTransfer
**Inherits:**
[EIP712](/src/EIP712.sol/contract.EIP712.md), [I_SimplePermit](/src/interfaces/I_SimplePermit.sol/interface.I_SimplePermit.md)


## State Variables
### allowance

```solidity
mapping(address owner => mapping(address token => mapping(address spender => S_PackedAllowance data))) public allowance;
```


## Functions
### approve


```solidity
function approve(address token, address spender, uint128 amount, uint48 expiration) external;
```

### transferFrom


```solidity
function transferFrom(address token, address owner, address to, uint128 amount) external;
```

### PermitAllanceTransferFrom


```solidity
function PermitAllanceTransferFrom(address token, address owner, address spender, uint128 amount, bytes calldata data)
    external;
```

