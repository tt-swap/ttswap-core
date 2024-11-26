# S_GoodState
*Struct representing the state of a good*


```solidity
struct S_GoodState {
    uint256 goodConfig;
    address owner;
    uint256 currentState;
    uint256 investState;
    uint256 feeQuantityState;
    mapping(address => uint256) commission;
}
```

