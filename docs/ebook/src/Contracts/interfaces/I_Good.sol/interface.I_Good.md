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


### check_banlist

Returns the address's status 查询地址是否被禁止提手续费


```solidity
function check_banlist(address _user) external view returns (bool _isban);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|用户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_isban`|`bool`|the address status~地址是否被禁|


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


### getGoodIdByAddress

get seller's good~获取卖家的商品列表


```solidity
function getGoodIdByAddress(address _owner, uint256 _seq) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|  seller address~卖家地址|
|`_seq`|`uint256`|  seller's good index~第几个商品|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|goods No~商品编号|


### getGoodState

get good's state 获取商品状态


```solidity
function getGoodState(uint256 _goodid) external view returns (L_Good.S_GoodTmpState memory good_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`| good's id  商品的商品编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`good_`|`L_Good.S_GoodTmpState`|goodinfo 商品的状态信息|


### updateGoodConfig

update good's config 更新商品配置


```solidity
function updateGoodConfig(uint256 _goodid, uint256 _goodConfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  good's id 商品的商品ID|
|`_goodConfig`|`uint256`|  商品配置|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### updatetoValueGood

update normal good to value good 更新普通商品为价值商品


```solidity
function updatetoValueGood(uint256 _goodid) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### updatetoNormalGood

update normal good to value good 更新价值商品为普通商品


```solidity
function updatetoNormalGood(uint256 _goodid) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result  更新结果|


### payGood

pay good to  转给


```solidity
function payGood(uint256 _goodid, uint256 _payquanity, address _recipent) external payable returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  商品的商品ID|
|`_payquanity`|`uint256`|  数量|
|`_recipent`|`address`|  接收者|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result|


### changeGoodOwner

set good's Owner 改变商品的拥有者


```solidity
function changeGoodOwner(uint256 _goodid, address _to) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`| good's id 商品的商品ID|
|`_to`|`address`| recipent 接收者|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result|


### collectProtocolFee

collect protocalFee 收益协议手续费


```solidity
function collectProtocolFee(uint256 _goodid) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`| good's id 商品的商品ID|

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


### getGoodsFee

获取商品的用户协议手续费


```solidity
function getGoodsFee(uint256 _goodid, address _user) external view returns (uint256 fee_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  商品编号|
|`_user`|`address`|  用户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fee_`|`uint256`|是否成功|


## Events
### e_changeOwner
emitted when good's user tranfer the good to another 商品拥有者转移关系给另一人


```solidity
event e_changeOwner(uint256 indexed _goodid, address _owner, address _to);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|good number,商品编号|
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
event e_updateGoodConfig(uint256 _goodid, uint256 _goodConfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|Good No,商品编号|
|`_goodConfig`|`uint256`|Good config 市场配置|

### e_updatetoValueGood
update good to value good~ 更新商品为价值商品


```solidity
event e_updatetoValueGood(uint256 _goodid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|good No,商品编号配|

### e_updatetoNormalGood
update good to normal good~ 更新商品为普通商品


```solidity
event e_updatetoNormalGood(uint256 _goodid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|good No,商品编号配|

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

