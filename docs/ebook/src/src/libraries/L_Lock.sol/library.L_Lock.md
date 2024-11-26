# L_Lock
This is a temporary library that allows us to use transient storage (tstore/tload)
TODO: This library can be deleted when we have the transient keyword support in solidity.


## State Variables
### LOCK_SLOT

```solidity
bytes32 constant LOCK_SLOT = 0xcfdbe78f31bc5efa50605e8b11a7b6843971370ea97eb24de6e1a1eb9d235645;
```


## Functions
### set


```solidity
function set(address locker) internal;
```

### get


```solidity
function get() internal view returns (address locker);
```

