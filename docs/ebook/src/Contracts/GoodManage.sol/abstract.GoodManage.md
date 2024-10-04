# GoodManage
**Inherits:**
[I_Good](/Contracts/interfaces/I_Good.sol/interface.I_Good.md)


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
mapping(bytes32 => L_Good.S_GoodState) internal goods;
```


### locked

```solidity
uint256 internal locked;
```


### banlist

```solidity
mapping(address => uint256) public banlist;
```


### referals

```solidity
mapping(address => address) public referals;
```


## Functions
### constructor


```solidity
constructor(address _marketcreator, uint256 _marketconfig);
```

### noReentrant


```solidity
modifier noReentrant();
```

### getGoodState


```solidity
function getGoodState(bytes32 goodkey) external view returns (L_Good.S_GoodTmpState memory gooddetail);
```

### addbanlist

add ban list  增加禁止名单


```solidity
function addbanlist(address _user) external override returns (bool);
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
function removebanlist(address _user) external override returns (bool);
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
function setMarketConfig(uint256 _marketconfig) external override returns (bool);
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


```solidity
function updateGoodConfig(bytes32 _goodid, uint256 _goodConfig) external override returns (bool);
```

### updatetoValueGood

update normal good to value good 更新普通商品为价值商品


```solidity
function updatetoValueGood(bytes32 _goodid) external override returns (bool);
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
function updatetoNormalGood(bytes32 _goodid) external override returns (bool);
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
function changeGoodOwner(bytes32 _goodid, address _to) external override returns (bool);
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


```solidity
function collectProtocolFee(bytes32 _goodid) external override returns (uint256 feeamount);
```

### goodWelfare


```solidity
function goodWelfare(bytes32 goodid, uint128 welfare) external payable override noReentrant;
```

