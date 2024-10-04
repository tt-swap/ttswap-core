# I_Good
包含商品的一系列接口  contain good's all interfaces


## Functions
### marketconfig

Returns the config of the market~返回市场的配置

*Can be changed by the marketmanager~可以被管理员调整*


```solidity
function marketconfig() external view returns (uint256 marketconfig_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`marketconfig_`|`uint256`|the config of market(according the white paper)~市场配置(参见白皮书)|


### marketcreator

Returns the manger of market 返回市场管理者 返回市场商品总数


```solidity
function marketcreator() external view returns (address marketcreator_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`marketcreator_`|`address`|The address of the factory manager|


### goodNum

Returns the good's total number of the market 返回市场商品总数


```solidity
function goodNum() external view returns (uint256 goodNum_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodNum_`|`uint256`|the good number of the market~市场商品总数|


### setMarketConfig

config market config 设置市场中市场配置


```solidity
function setMarketConfig(uint256 _marketconfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|  the market config ~市场配置|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|是否成功|


### updateGoodConfig

update good's config 更新商品配置


```solidity
function updateGoodConfig(bytes32 _goodid, uint256 _goodConfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  good's id 商品的商品ID|
|`_goodConfig`|`uint256`|  商品配置|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### updatetoValueGood

update normal good to value good 更新普通商品为价值商品


```solidity
function updatetoValueGood(bytes32 _goodid) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### updatetoNormalGood

update normal good to value good 更新价值商品为普通商品


```solidity
function updatetoNormalGood(bytes32 _goodid) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### payGood

pay good to  转给


```solidity
function payGood(bytes32 _goodid, uint256 _payquanity, address _recipent) external payable returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  商品的商品ID|
|`_payquanity`|`uint256`|  数量|
|`_recipent`|`address`|  接收者|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result|


### changeGoodOwner

set good's Owner 改变商品的拥有者


```solidity
function changeGoodOwner(bytes32 _goodid, address _to) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`| good's id 商品的商品ID|
|`_to`|`address`| recipent 接收者|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result|


### collectProtocolFee

collect protocalFee 收益协议手续费


```solidity
function collectProtocolFee(bytes32 _goodid) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`| good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the result 手续费数量|


### addbanlist

add ban list  增加禁止名单


```solidity
function addbanlist(address _user) external returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`| address 地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`is_success_`|`bool`|是否成功|


### removebanlist

rm ban list  移除禁止名单


```solidity
function removebanlist(address _user) external returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`| address 地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`is_success_`|`bool`|是否成功|


### goodWelfare

为投资者发福利


```solidity
function goodWelfare(bytes32 goodid, uint128 welfare) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`bytes32`|  商品编号|
|`welfare`|`uint128`|  用户地址|


## Events
### e_changeOwner
emitted when good's user tranfer the good to another 商品拥有者转移关系给另一人


```solidity
event e_changeOwner(bytes32 indexed _goodid, address _owner, address _to);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|good number,商品编号|
|`_owner`|`address`|the older owner,原拥有者|
|`_to`|`address`|the new owner,新拥有者|

### e_setMarketConfig
Config Market Config~ 进行市场配置


```solidity
event e_setMarketConfig(uint256 _marketconfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|市场配置|

### e_updateGoodConfig
Config good 商品配置


```solidity
event e_updateGoodConfig(bytes32 _goodid, uint256 _goodConfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|Good No,商品编号|
|`_goodConfig`|`uint256`|Good config 市场配置|

### e_updatetoValueGood
update good to value good~ 更新商品为价值商品


```solidity
event e_updatetoValueGood(bytes32 _goodid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|good No,商品编号配|

### e_updatetoNormalGood
update good to normal good~ 更新商品为普通商品


```solidity
event e_updatetoNormalGood(bytes32 _goodid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|good No,商品编号配|

### e_addbanlist
add ban list~添加黑名单


```solidity
event e_addbanlist(address _user);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`| address ~用户地址|

### e_removebanlist
remove  out address from banlist~ 移出黑名单


```solidity
event e_removebanlist(address _user);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|user address ~用户地址|

### e_goodWelfare
preject or seller deliver welfare to investor


```solidity
event e_goodWelfare(bytes32 goodid, uint128 welfare);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`bytes32`|商品编号|
|`welfare`|`uint128`|福利数量|

### e_collectProtocolFee
collect fee


```solidity
event e_collectProtocolFee(bytes32 goodid, uint256 feeamount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`bytes32`|商品编号|
|`feeamount`|`uint256`|福利数量|

### e_addreferal

```solidity
event e_addreferal(address referals);
```

