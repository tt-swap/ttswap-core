# TTSwap_LimitOrder
**Inherits:**
[I_TTSwap_LimitOrderMaker](/src/interfaces/I_TTSwap_LimitOrderMaker.sol/interface.I_TTSwap_LimitOrderMaker.md)

*Implements ERC20 token with additional staking and cross-chain functionality*


## State Variables
### maxslot

```solidity
uint256 public maxslot;
```


### orderpointer

```solidity
uint256 public orderpointer;
```


### marketcreator

```solidity
address public marketcreator;
```


### maxfreeremain

```solidity
uint96 public maxfreeremain;
```


### orderstatus

```solidity
mapping(uint256 => uint256) internal orderstatus;
```


### orders

```solidity
mapping(uint256 => S_orderDetails) public orders;
```


### auths

```solidity
mapping(address => uint256) public auths;
```


### defaultdata

```solidity
bytes internal constant defaultdata = abi.encode(L_CurrencyLibrary.S_transferData(1, "0X"));
```


## Functions
### constructor


```solidity
constructor(address _marketor);
```

### setMaxfreeRemain


```solidity
function setMaxfreeRemain(uint96 times) external;
```

### changemarketcreator


```solidity
function changemarketcreator(address _newmarketor) external;
```

### addauths


```solidity
function addauths(address _marketor, uint256 _auths) external;
```

### removeauths


```solidity
function removeauths(address _marketor) external;
```

### addmaxslot


```solidity
function addmaxslot(uint256 _maxslot) external;
```

### addLimitOrder

User add limitorder


```solidity
function addLimitOrder(S_orderDetails[] memory _orders) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orders`|`S_orderDetails[]`|order's detail|


### updateLimitOrder

owner update his limit order


```solidity
function updateLimitOrder(uint256 orderid, S_orderDetails memory _order) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderid`|`uint256`||
|`_order`|`S_orderDetails`|order's detail|


### removeLimitOrder

owner remove his limit order


```solidity
function removeLimitOrder(uint256 orderid) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderid`|`uint256`||


### takeLimitOrderNormal

normally take the limit order


```solidity
function takeLimitOrderNormal(S_TakeParams[] memory orderids) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderids`|`S_TakeParams[]`||


### takeLimitOrderChips


```solidity
function takeLimitOrderChips(S_OrderChip[] memory _orderChips) external override;
```

### takeLimitOrderAMM

amm take the limit order


```solidity
function takeLimitOrderAMM(
    uint256 orderid,
    uint96 _tolerance,
    I_TTSwap_LimitOrderTaker _takecontract,
    address _takecaller
) external override returns (bool _isSuccess);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderid`|`uint256`||
|`_tolerance`|`uint96`|the caller's tolerance config|
|`_takecontract`|`I_TTSwap_LimitOrderTaker`| the amm's address|
|`_takecaller`|`address`| the caller address|


### takeBatchLimitOrdersAMM

amm take the limit order


```solidity
function takeBatchLimitOrdersAMM(
    uint256[] memory orderids,
    uint96 _tolerance,
    I_TTSwap_LimitOrderTaker _takecontract,
    address _takecaller,
    bool _isall
) external override returns (bool[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderids`|`uint256[]`||
|`_tolerance`|`uint96`|the caller's tolerance config|
|`_takecontract`|`I_TTSwap_LimitOrderTaker`| the amm's address|
|`_takecaller`|`address`| the caller address|
|`_isall`|`bool`|  true:must all be deal|


### cleandeadorder


```solidity
function cleandeadorder(uint256[] memory ids, bool smallorder) public;
```

### queryLimitOrder

get limit order's infor


```solidity
function queryLimitOrder(uint256[] memory _ordersids) external view override returns (S_orderDetails[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ordersids`|`uint256[]`|orders' id|


### queryOrdersStatus


```solidity
function queryOrdersStatus(uint256[] memory _ordersids) external view returns (bool[] memory);
```

### queryOrderStatus


```solidity
function queryOrderStatus(uint256 _ordersid) external view returns (bool);
```

