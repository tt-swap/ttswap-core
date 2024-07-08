# I_MarketManage
**Inherits:**
[I_Good](/Contracts/interfaces/I_Good.sol/interface.I_Good.md), [I_Proof](/Contracts/interfaces/I_Proof.sol/interface.I_Proof.md)

市场管理接口 market manage interface


## Functions
### initMetaGood

initial market's first good~初始化市场中第一个商品


```solidity
function initMetaGood(address _erc20address, T_BalanceUINT256 _initial, uint256 _goodconfig)
    external
    payable
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20address`|`address`|good's contract address~商品合约地址|
|`_initial`|`T_BalanceUINT256`|  initial good.amount0:value,amount1:quantity~初始化的商品的参数,前128位为价值,后128位为数量.|
|`_goodconfig`|`uint256`|  good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)|


### initGood

initial the normal good~初始化市场中的普通商品


```solidity
function initGood(bytes32 _valuegood, T_BalanceUINT256 _initial, address _erc20address, uint256 _goodConfig)
    external
    payable
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_valuegood`|`bytes32`|  valuegood_no:measure the normal good value~价值商品编号:衡量普通商品价值|
|`_initial`|`T_BalanceUINT256`|    initial good.amount0:normalgood quantity,amount1:valuegoodquantity~初始化的商品的参数,前128位为普通商品数量,后128位为价值商品数量.|
|`_erc20address`|`address`| good's contract address~商品合约地址|
|`_goodConfig`|`uint256`|  good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)|


### buyGood

sell _swapQuantity units of good1 to buy good2~用户出售_swapQuantity个_goodid1去购买 _goodid2

*如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1*


```solidity
function buyGood(bytes32 _goodid1, bytes32 _goodid2, uint128 _swapQuantity, uint256 _limitprice, bool _istotal)
    external
    payable
    returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`bytes32`|good1's No~商品1的编号|
|`_goodid2`|`bytes32`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|good1's quantity~商品1的数量|
|`_limitprice`|`uint256`|trade price's limit~交易价格限制|
|`_istotal`|`bool`|is need trade all~是否允许全部成交|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid2Quantity_`|`uint128`| 实际情况|
|`goodid2FeeQuantity_`|`uint128`|实际情况|


### buyGoodForPay

buy _swapQuantity units of good to sell good2 and send good1 to recipent~用户购买_swapQuantity个_goodid1去出售 _goodid2并且把商品转给RECIPENT


```solidity
function buyGoodForPay(
    bytes32 _goodid1,
    bytes32 _goodid2,
    uint128 _swapQuantity,
    uint256 _limitprice,
    address _recipent
) external payable returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`bytes32`|good1's No~商品1的编号|
|`_goodid2`|`bytes32`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|buy good2's quantity~购买商品2的数量|
|`_limitprice`|`uint256`|trade price's limit~交易价格限制|
|`_recipent`|`address`|recipent~收款人|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid1Quantity_`|`uint128`| good1 actual quantity~商品1实际数量|
|`goodid1FeeQuantity_`|`uint128`|good1 actual fee~商品1实际手续费|


### investGood

invest normal good~投资普通商品


```solidity
function investGood(bytes32 _togood, bytes32 _valuegood, uint128 _quantity) external payable returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_togood`|`bytes32`| normal good No~普通商品的编号|
|`_valuegood`|`bytes32`|value good No~价值商品的编号|
|`_quantity`|`uint128`|  invest normal good quantity~投资普通商品的数量|


### disinvestProof

disinvest normal good~撤资商品


```solidity
function disinvestProof(uint256 _proofid, uint128 _goodQuantity, address _gater, address _referal)
    external
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  the invest proof No of normal good ~普通投资证明的编号编号|
|`_goodQuantity`|`uint128`| disinvest quantity~取消普通商品投资数量|
|`_gater`|`address`|  gater address~门户|
|`_referal`|`address`|  referal~推荐人|


### collectProofFee

collect the profit of normal proof~提取普通投资证明的收益


```solidity
function collectProofFee(uint256 _proofid, address _gater, address _referal)
    external
    returns (T_BalanceUINT256 profit_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  the proof No of invest normal good~普通投资证明编号|
|`_gater`|`address`|  gater address~门户|
|`_referal`|`address`|  referal~推荐人|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`T_BalanceUINT256`|  amount0 普通商品的投资收益 amount1价值商品的投资收益|


### enpower

enpower~赋能


```solidity
function enpower(bytes32 _goodid, bytes32 _valuegoodid, uint128 _quantity) external payable returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  enpowered good~赋能商品编号|
|`_valuegoodid`|`bytes32`|  valuegoodid~价值商品id|
|`_quantity`|`uint128`|  valuegood quantity~价值商品数量|


## Events
### e_initMetaGood
emit when metaGood create :当用户创建初始化商品时

*_initial.amount0()'s decimal default 6 ~默认价值的精度为6*


```solidity
event e_initMetaGood(
    uint256 indexed _proofNo, bytes32 _goodNo, address _erc20address, uint256 _goodConfig, T_BalanceUINT256 _initial
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  value invest proof No~投资证明的编号|
|`_goodNo`|`bytes32`|good's id  商品的商品编号|
|`_erc20address`|`address`|  metagood contract address 元商品的合约地址|
|`_goodConfig`|`uint256`|  metagood's config refer white paper~元商品的配置,具体参见白皮书|
|`_initial`|`T_BalanceUINT256`|  market intial para: amount0 value  amount1:quantity~市场初始化参数:amount0为价值,amount1为数量.|

### e_initGood
emit when  good create :当用户创建初始化商品时


```solidity
event e_initGood(
    uint256 indexed _proofNo,
    bytes32 _normalgoodNo,
    bytes32 _valuegoodNo,
    address _erc20address,
    uint256 _goodConfig,
    T_BalanceUINT256 _normalinitial,
    T_BalanceUINT256 _value
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  value invest proof No~投资证明的编号|
|`_normalgoodNo`|`bytes32`|good's id  商品的商品编号|
|`_valuegoodNo`|`bytes32`|good's id  商品的商品编号|
|`_erc20address`|`address`|  metagood contract address 元商品的合约地址|
|`_goodConfig`|`uint256`|  metagood's config refer white paper~元商品的配置,具体参见白皮书|
|`_normalinitial`|`T_BalanceUINT256`|  amount0 quantity  amount1:value~普通商品:amount0为数量,amount1为价值.|
|`_value`|`T_BalanceUINT256`|  amount0():valuegoodfee, amount1 valuegoodquantity~amount0为价值商品投资费用,amount1为价值商品投资数量.|

### e_buyGood
emit when customer buy good :当用户购买商品时触发


```solidity
event e_buyGood(
    bytes32 indexed sellgood,
    bytes32 indexed forgood,
    address fromer,
    uint128 swapvalue,
    T_BalanceUINT256 sellgoodstate,
    T_BalanceUINT256 forgoodstate
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sellgood`|`bytes32`|good's id  商品的商品ID|
|`forgood`|`bytes32`|  initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.|
|`fromer`|`address`|  seller or buyer address 卖家或买家地址|
|`swapvalue`|`uint128`|  trade value  交易价值|
|`sellgoodstate`|`T_BalanceUINT256`|  the sellgood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量|
|`forgoodstate`|`T_BalanceUINT256`|  the forgood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量|

### e_buyGoodForPay
emit when customer buy good pay to the seller :当用户购买商品支付给卖家时触发


```solidity
event e_buyGoodForPay(
    bytes32 indexed buygood,
    bytes32 indexed usegood,
    address fromer,
    address receipt,
    uint128 swapvalue,
    T_BalanceUINT256 buygoodstate,
    T_BalanceUINT256 usegoodstate
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`buygood`|`bytes32`|good's id  商品的商品ID|
|`usegood`|`bytes32`|  initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.|
|`fromer`|`address`|  seller or buyer address 卖家或买家地址|
|`receipt`|`address`|  receipt  收款方|
|`swapvalue`|`uint128`|  trade value  交易价值|
|`buygoodstate`|`T_BalanceUINT256`|  the buygood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量|
|`usegoodstate`|`T_BalanceUINT256`|  the usegood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量|

### e_investGood
emit when customer invest normal good :当用户投资普通商品


```solidity
event e_investGood(
    uint256 indexed _proofNo,
    bytes32 _normalGoodNo,
    bytes32 _valueGoodNo,
    T_BalanceUINT256 _invest,
    T_BalanceUINT256 _valueinvest
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`bytes32`| normal good no~普通商品编号|
|`_valueGoodNo`|`bytes32`| value good no~价值商品编号|
|`_invest`|`T_BalanceUINT256`|    amount0 normal good actual fee ,amount1 normal good actual invest quantity~amount0为投资手续费,amount1为投资数量|
|`_valueinvest`|`T_BalanceUINT256`|  amount0 value good actual fee ,amount1 value good actual invest quantity~amount0为投资手续费,amount1为投资数量|

### e_disinvestProof
emit when customer disinvest normal good :当用户撤资普通商品


```solidity
event e_disinvestProof(
    uint256 indexed _proofNo,
    bytes32 _normalGoodNo,
    bytes32 _valueGoodNo,
    T_BalanceUINT256 _normalgood,
    T_BalanceUINT256 _valuegood,
    T_BalanceUINT256 _profit
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`bytes32`| value good no~价值商品编号|
|`_valueGoodNo`|`bytes32`| value good no~价值商品编号|
|`_normalgood`|`T_BalanceUINT256`|  amount0 actual fee ,amount1 actual invest quantity~amount0为撤资手续费,amount1为撤资数量|
|`_valuegood`|`T_BalanceUINT256`|  amount0 actual fee ,amount1 actual invest quantity~amount0为撤资手续费,amount1为撤资数量|
|`_profit`|`T_BalanceUINT256`|  profit~收益|

### e_collectProofFee
emit when customer disinvest normal good :当用户撤资普通商品


```solidity
event e_collectProofFee(
    uint256 indexed _proofNo, bytes32 _normalGoodNo, bytes32 _valueGoodNo, T_BalanceUINT256 _profit
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`bytes32`| value good no~价值商品编号|
|`_valueGoodNo`|`bytes32`| value good no~价值商品编号|
|`_profit`|`T_BalanceUINT256`|  profit  amount0:normalprofit  amount1:valueprofit|

### e_enpower
emit enpower:赋能


```solidity
event e_enpower(bytes32 _goodid, bytes32 _valuegood, uint256 _quantity, address _sender);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`bytes32`|  proof No~投资证明编号|
|`_valuegood`|`bytes32`| value good no~价值商品编号|
|`_quantity`|`uint256`| enpower value quantity~赋能价值商品数量|
|`_sender`|`address`|msg.sender|

## Errors
### err_total

```solidity
error err_total();
```

