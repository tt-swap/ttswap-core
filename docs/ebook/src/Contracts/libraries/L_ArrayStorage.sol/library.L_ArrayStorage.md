# L_ArrayStorage

## Functions
### addvalue


```solidity
function addvalue(S_ArrayStorage storage _self, uint256 _value) internal;
```

### removevalue


```solidity
function removevalue(S_ArrayStorage storage _self, uint256 _value) internal;
```

### removekey


```solidity
function removekey(S_ArrayStorage storage _self, uint256 _key) internal;
```

## Structs
### S_ArrayStorage

```solidity
struct S_ArrayStorage {
    uint256 key;
    mapping(uint256 => uint256) key_value;
    mapping(uint256 => uint256) value_key;
}
```

