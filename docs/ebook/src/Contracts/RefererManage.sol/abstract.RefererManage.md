# RefererManage
**Inherits:**
[I_Referer](/Contracts/interfaces/I_Referer.sol/interface.I_Referer.md)


## State Variables
### customernum

```solidity
uint256 public customernum;
```


### customerno

```solidity
mapping(address => uint256) public customerno;
```


### relations

```solidity
mapping(address => address) public relations;
```


## Functions
### constructor


```solidity
constructor();
```

### addreferer

user add referer~用户添加推荐人


```solidity
function addreferer(address _referer) external override returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_referer`|`address`|  address or referer~推荐人地址|


