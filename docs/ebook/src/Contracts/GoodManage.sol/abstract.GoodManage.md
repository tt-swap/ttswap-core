# GoodManage
**Inherits:**
[I_Good](/Contracts/interfaces/I_Good.sol/interface.I_Good.md), [RefererManage](/Contracts/RefererManage.sol/abstract.RefererManage.md)


## State Variables
### marketconfig
Returns the config of the market~返回市场的配置

*Can be changed by the marketmanager~可以被管理员调整*


```solidity
uint256 public override marketconfig;
```


### goodNum
Returns the good's total number of the market 返回市场商品总数


```solidity
uint256 public override goodNum;
```


### marketcreator
Returns the manger of market 返回市场管理者 返回市场商品总数


```solidity
address public override marketcreator;
```


### goods

```solidity
mapping(uint256 => L_Good.S_GoodState) internal goods;
```


### ownergoods

```solidity
mapping(address => L_ArrayStorage.S_ArrayStorage) internal ownergoods;
```


### goodseq

```solidity
mapping(bytes32 => uint256) internal goodseq;
```


### locked

```solidity
uint256 internal locked;
```


### banlist

```solidity
mapping(address => uint256) private banlist;
```


## Functions
### constructor


```solidity
constructor(address _marketcreator, uint256 _marketconfig);
```

### onlyMarketCreator


```solidity
modifier onlyMarketCreator();
```

### noReentrant


```solidity
modifier noReentrant();
```

### noblacklist


```solidity
modifier noblacklist();
```

### addbanlist

add ban list  增加禁止名单


```solidity
function addbanlist(address _user) external override onlyMarketCreator returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`| address 地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|is_success_ 是否成功|


### removebanlist

rm ban list  移除禁止名单


```solidity
function removebanlist(address _user) external override onlyMarketCreator returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`| address 地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|is_success_ 是否成功|


### setMarketConfig

config market config 设置市场中市场配置


```solidity
function setMarketConfig(uint256 _marketconfig) external override onlyMarketCreator returns (bool);
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
function getGoodIdByAddress(address _owner, uint256 _key) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|  seller address~卖家地址|
|`_key`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|goods No~商品编号|


### getGoodState

get good's state 获取商品状态


```solidity
function getGoodState(uint256 _goodid) external view override returns (L_Good.S_GoodTmpState memory good_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`| good's id  商品的商品编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`good_`|`L_Good.S_GoodTmpState`|goodinfo 商品的状态信息|


### getGoodsFee

获取商品的用户协议手续费


```solidity
function getGoodsFee(uint256 _goodid, address user) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|  商品编号|
|`user`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|fee_ 是否成功|


### updateGoodConfig


```solidity
function updateGoodConfig(uint256 _goodid, uint256 _goodConfig) external override returns (bool);
```

### updatetoValueGood

update normal good to value good 更新普通商品为价值商品


```solidity
function updatetoValueGood(uint256 _goodid) external override onlyMarketCreator returns (bool);
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
function updatetoNormalGood(uint256 _goodid) external override onlyMarketCreator returns (bool);
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
function changeGoodOwner(uint256 _goodid, address _to) external override returns (bool);
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
function collectProtocolFee(uint256 _goodid) external override noblacklist returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`| good's id 商品的商品ID|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the result 手续费数量|


### check_banlist

Returns the address's status 查询地址是否被禁止提手续费


```solidity
function check_banlist(address _user) external view override returns (bool _isban);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|用户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_isban`|`bool`|the address status~地址是否被禁|


