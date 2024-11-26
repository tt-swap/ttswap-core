# L_OrderStatus
*Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].*


## Functions
### get

*Returns whether the bit at `index` is set.*


```solidity
function get(mapping(uint256 => uint256) storage _orderStatus, uint256 index) internal view returns (bool);
```

### setTo

*Sets the bit at `index` to the boolean `value`.*


```solidity
function setTo(mapping(uint256 => uint256) storage _orderStatus, uint256 index, bool value) internal;
```

### set

*Sets the bit at `index`.*


```solidity
function set(mapping(uint256 => uint256) storage _orderStatus, uint256 index) internal;
```

### unset

*Unsets the bit at `index`.*


```solidity
function unset(mapping(uint256 => uint256) storage _orderStatus, uint256 index) internal;
```

### getValidOrderId


```solidity
function getValidOrderId(mapping(uint256 => uint256) storage _orderStatus, uint256 index, uint256 _maxslot)
    internal
    returns (uint256 orderid);
```

