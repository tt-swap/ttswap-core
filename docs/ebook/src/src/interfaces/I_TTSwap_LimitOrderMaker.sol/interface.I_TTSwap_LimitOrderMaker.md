# I_TTSwap_LimitOrderMaker

## Functions
### addLimitOrder

User add limitorder


```solidity
function addLimitOrder(S_orderDetails[] memory _orders) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orders`|`S_orderDetails[]`|order's detail|


### updateLimitOrder

owner update his limit order


```solidity
function updateLimitOrder(uint256 _orderid, S_orderDetails memory _order) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|order'sid|
|`_order`|`S_orderDetails`|order's detail|


### removeLimitOrder

owner remove his limit order


```solidity
function removeLimitOrder(uint256 _orderid) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|order'sid|


### takeLimitOrderChips


```solidity
function takeLimitOrderChips(S_OrderChip[] memory _orderChips) external;
```

### takeLimitOrderNormal

normally take the limit order


```solidity
function takeLimitOrderNormal(S_TakeParams[] memory _orderids) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderids`|`S_TakeParams[]`|orders' id|


### takeLimitOrderAMM

amm take the limit order


```solidity
function takeLimitOrderAMM(
    uint256 _orderid,
    uint96 _tolerance,
    I_TTSwap_LimitOrderTaker _takecontract,
    address _takecaller
) external returns (bool _isSuccess);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|order's id|
|`_tolerance`|`uint96`|the caller's tolerance config|
|`_takecontract`|`I_TTSwap_LimitOrderTaker`| the amm's address|
|`_takecaller`|`address`| the caller address|


### takeBatchLimitOrdersAMM

amm take the limit order


```solidity
function takeBatchLimitOrdersAMM(
    uint256[] memory _orderids,
    uint96 _tolerance,
    I_TTSwap_LimitOrderTaker _takecontract,
    address _takecaller,
    bool _isall
) external returns (bool[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderids`|`uint256[]`|orders' id|
|`_tolerance`|`uint96`|the caller's tolerance config|
|`_takecontract`|`I_TTSwap_LimitOrderTaker`| the amm's address|
|`_takecaller`|`address`| the caller address|
|`_isall`|`bool`|  true:must all be deal|


### queryLimitOrder

get limit order's infor


```solidity
function queryLimitOrder(uint256[] memory _ordersids) external view returns (S_orderDetails[] memory _orderdetail);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ordersids`|`uint256[]`|orders' id|


## Events
### e_addLimitOrder
Emitted when User add limit order


```solidity
event e_addLimitOrder(uint256 _orderid, address _sender, address _fromerc20, address _toerc20, uint256 _amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the limit order id|
|`_sender`|`address`|the limit's owner|
|`_fromerc20`|`address`|from erc20|
|`_toerc20`|`address`| to achive the erc20 token|
|`_amount`|`uint256`|fitst 128bit is the from amount,last 128 bit is the to amount|

### e_setmaxfreeremain
Emitted when marketor set maxfreeremaintimestamp


```solidity
event e_setmaxfreeremain(uint96 _maxfreeremain);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxfreeremain`|`uint96`|the max free remain timestamp|

### e_changemarketcreator
Emitted when marketor change marketcreator


```solidity
event e_changemarketcreator(address _newmarketcreator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newmarketcreator`|`address`|the new marketcreator|

### e_addauths
Emitted when marketor grant


```solidity
event e_addauths(address _marketor, uint256 _auths);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketor`|`address`|who will be seted to marketor|
|`_auths`|`uint256`|the priv which be grant|

### e_removeauths
Emitted when marketor be remove


```solidity
event e_removeauths(address _marketor);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketor`|`address`|who will be remove from marketor|

### e_takeOrder
Emitted when limitorder is dealed


```solidity
event e_takeOrder(uint256 _orderid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the id of the limit order|

### e_takeOrderChips
Emitted when limitorder is dealed


```solidity
event e_takeOrderChips(uint256 _orderid, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the id of the limit order|
|`amount`|`uint256`|the id of the limit order|

### e_cleandeadorders
Emitted when limitorder is removed by marketor when order unvalid over time


```solidity
event e_cleandeadorders(uint256[] _orderids);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderids`|`uint256[]`|the ids of the limit order|

### e_cleandeadorder
Emitted when limitorder is removed by marketor when order unvalid over time


```solidity
event e_cleandeadorder(uint256 _orderid, uint256 _feeamount, address _reciver);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the ids of the limit order|
|`_feeamount`|`uint256`|fee amount|
|`_reciver`|`address`|the recieve of fee|

### e_removeLimitOrder
Emitted when limitorder's  removed by it's owner


```solidity
event e_removeLimitOrder(uint256 _orderid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the ids of the limit order|

### e_updateLimitOrder
Emitted when limitorder's  removed by it's owner


```solidity
event e_updateLimitOrder(uint256 _orderid, address _fromerc20, address _toerc20, uint256 _amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|the ids of the limit order|
|`_fromerc20`|`address`|from erc20|
|`_toerc20`|`address`| to achive the erc20 token|
|`_amount`|`uint256`|fitst 128bit is the from amount,last 128 bit is the to amount|

### e_deploy

```solidity
event e_deploy(address marketcreator, uint256 maxfreeremain, uint256);
```

### e_addmaxslot

```solidity
event e_addmaxslot(uint256);
```

## Errors
### lessAmountError
Emitted actual mount under the pridicate amount


```solidity
error lessAmountError(uint256 _orderid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderid`|`uint256`|orderid|

## Structs
### S_TakeParams

```solidity
struct S_TakeParams {
    uint256 orderid;
    bytes transdata;
}
```

### S_orderDetails

```solidity
struct S_orderDetails {
    uint96 timestamp;
    address sender;
    address fromerc20;
    address toerc20;
    uint256 amount;
}
```

### S_OrderChip

```solidity
struct S_OrderChip {
    uint256 orderid;
    uint128 takeamount;
    bytes transdata;
}
```

