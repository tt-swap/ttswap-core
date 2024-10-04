# I_Referer

## Functions
### addreferer

user add referer~用户添加推荐人


```solidity
function addreferer(address _referer) external returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_referer`|`address`|  address or referer~推荐人地址|


## Events
### e_addreferer
user addrefer~ 用户添加推荐人


```solidity
event e_addreferer(address _user, address _referer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|User address,用户地址|
|`_referer`|`address`|referer address,推荐人地址|

