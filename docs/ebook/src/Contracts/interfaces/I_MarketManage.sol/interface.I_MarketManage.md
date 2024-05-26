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
    returns (uint256 metagood_no_, uint256 proof_no_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20address`|`address`|good's contract address~商品合约地址|
|`_initial`|`T_BalanceUINT256`|  initial good.amount0:value,amount1:quantity~初始化的商品的参数,前128位为价值,后128位为数量.|
|`_goodconfig`|`uint256`|  good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`metagood_no_`|`uint256`| good_no~商品编号|
|`proof_no_`|`uint256`| proof_no~投资证明编号|


### initGood

initial the normal good~初始化市场中的普通商品


```solidity
function initGood(
    uint256 _valuegood,
    T_BalanceUINT256 _initial,
    address _erc20address,
    uint256 _goodConfig,
    address _gater
) external payable returns (uint256 goodNo_, uint256 proofNo_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_valuegood`|`uint256`|  valuegood_no:measure the normal good value~价值商品编号:衡量普通商品价值|
|`_initial`|`T_BalanceUINT256`|    initial good.amount0:normalgood quantity,amount1:valuegoodquantity~初始化的商品的参数,前128位为普通商品数量,后128位为价值商品数量.|
|`_erc20address`|`address`| good's contract address~商品合约地址|
|`_goodConfig`|`uint256`|  good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)|
|`_gater`|`address`|  gater address~门户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodNo_`|`uint256`|the_normal_good_No ~普通物品的编号|
|`proofNo_`|`uint256`|the_proof_of_initial_good~初始化普通物品的投资证明|


### buyGood

sell _swapQuantity units of good1 to buy good2~用户出售_swapQuantity个_goodid1去购买 _goodid2

*如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1*


```solidity
function buyGood(
    uint256 _goodid1,
    uint256 _goodid2,
    uint128 _swapQuantity,
    uint256 _limitprice,
    bool _istotal,
    address _gater
) external returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`uint256`|good1's No~商品1的编号|
|`_goodid2`|`uint256`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|good1's quantity~商品1的数量|
|`_limitprice`|`uint256`|trade price's limit~交易价格限制|
|`_istotal`|`bool`|is need trade all~是否允许全部成交|
|`_gater`|`address`|  gater address~门户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid2Quantity_`|`uint128`| 实际情况|
|`goodid2FeeQuantity_`|`uint128`|实际情况|


### buyGoodForPay

buy _swapQuantity units of good to sell good2 and send good1 to recipent~用户购买_swapQuantity个_goodid1去出售 _goodid2并且把商品转给RECIPENT


```solidity
function buyGoodForPay(
    uint256 _goodid1,
    uint256 _goodid2,
    uint128 _swapQuantity,
    uint256 _limitprice,
    address _recipent,
    address _gater
) external returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`uint256`|good1's No~商品1的编号|
|`_goodid2`|`uint256`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|buy good2's quantity~购买商品2的数量|
|`_limitprice`|`uint256`|trade price's limit~交易价格限制|
|`_recipent`|`address`|recipent~收款人|
|`_gater`|`address`|  gater address~门户地址|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid1Quantity_`|`uint128`| good1 actual quantity~商品1实际数量|
|`goodid1FeeQuantity_`|`uint128`|good1 actual fee~商品1实际手续费|


### investGood

invest normal good~投资普通商品


```solidity
function investGood(uint256 _togood, uint256 _valuegood, uint128 _quantity, address _gater)
    external
    returns (
        L_Good.S_GoodInvestReturn memory normalInvest_,
        L_Good.S_GoodInvestReturn memory valueInvest_,
        uint256 normalProofno_
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_togood`|`uint256`| normal good No~普通商品的编号|
|`_valuegood`|`uint256`|value good No~价值商品的编号|
|`_quantity`|`uint128`|  invest normal good quantity~投资普通商品的数量|
|`_gater`|`address`|  gater address~门户|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`normalInvest_`|`L_Good.S_GoodInvestReturn`|normalInvest_ normalInvest_.actualFeeQuantity //actutal fee quantity 实际手续费 normalInvest_.contructFeeQuantity //contrunct fee quantity 构建手续费 normalInvest_.actualinvestValue //value of invest 实际投资价值 normalInvest_.actualinvestQuantity //the quantity of invest 实际投资数量|
|`valueInvest_`|`L_Good.S_GoodInvestReturn`|valueInvest_ valueInvest_.actualFeeQuantity //actutal fee quantity 实际手续费 valueInvest_.contructFeeQuantity //contrunct fee quantity 构建手续费 valueInvest_.actualinvestValue //value of invest 实际投资价值 valueInvest_.actualinvestQuantity //the quantity of invest 实际投资数量|
|`normalProofno_`|`uint256`| 证明编号|


### disinvestGood

disinvest normal good~撤资普通商品


```solidity
function disinvestGood(uint256 _togood, uint256 _valuegood, uint128 _goodQuantity, address _gater)
    external
    returns (
        L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
        L_Good.S_GoodDisinvestReturn memory disinvestResult2_,
        uint256 proofno_
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_togood`|`uint256`|  normal good No~普通商品编号|
|`_valuegood`|`uint256`|  value Good No~价值商品编号|
|`_goodQuantity`|`uint128`| disinvest quantity~取消普通商品投资数量|
|`_gater`|`address`|  gater address~门户|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`disinvestResult1_`|`L_Good.S_GoodDisinvestReturn`|普通商品结果 disinvestResult1_.profit; // profit of stake 投资收入 disinvestResult1_.actual_fee; // actual fee 实际手续费 disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`disinvestResult2_`|`L_Good.S_GoodDisinvestReturn`|价值商品结果 disinvestResult2_.profit; // profit of stake 投资收入 disinvestResult2_.actual_fee; // actual fee 实际手续费 disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`proofno_`|`uint256`| 证明编号|


### disinvestProof

disinvest normal good~撤资商品


```solidity
function disinvestProof(uint256 _proofid, uint128 _goodQuantity, address _gater)
    external
    returns (
        L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
        L_Good.S_GoodDisinvestReturn memory disinvestResult2_
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  the invest proof No of normal good ~普通投资证明的编号编号|
|`_goodQuantity`|`uint128`| disinvest quantity~取消普通商品投资数量|
|`_gater`|`address`|  gater address~门户|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`disinvestResult1_`|`L_Good.S_GoodDisinvestReturn`|普通商品结果 disinvestResult1_.profit; // profit of stake 投资收入 disinvestResult1_.actual_fee; // actual fee 实际手续费 disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`disinvestResult2_`|`L_Good.S_GoodDisinvestReturn`|价值商品结果 disinvestResult2_.profit; // profit of stake 投资收入 disinvestResult2_.actual_fee; // actual fee 实际手续费 disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量|


### collectProofFee

collect the profit of normal proof~提取普通投资证明的收益


```solidity
function collectProofFee(uint256 _proofid) external returns (T_BalanceUINT256 profit_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  the proof No of invest normal good~普通投资证明编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`T_BalanceUINT256`|  amount0 普通商品的投资收益 amount1价值商品的投资收益|


## Events
### e_initMetaGood
emit when metaGood create :当用户创建初始化商品时

*_initial.amount0()'s decimal default 6 ~默认价值的精度为6*


```solidity
event e_initMetaGood(
    uint256 indexed _proofNo, uint256 _goodNo, address _erc20address, uint256 _goodConfig, T_BalanceUINT256 _initial
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  value invest proof No~投资证明的编号|
|`_goodNo`|`uint256`|good's id  商品的商品编号|
|`_erc20address`|`address`|  metagood contract address 元商品的合约地址|
|`_goodConfig`|`uint256`|  metagood's config refer white paper~元商品的配置,具体参见白皮书|
|`_initial`|`T_BalanceUINT256`|  market intial para: amount0 value  amount1:quantity~市场初始化参数:amount0为价值,amount1为数量.|

### e_initGood
emit when  good create :当用户创建初始化商品时


```solidity
event e_initGood(
    uint256 indexed _proofNo,
    uint256 _normalgoodNo,
    uint256 _valuegoodNo,
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
|`_normalgoodNo`|`uint256`|good's id  商品的商品编号|
|`_valuegoodNo`|`uint256`|good's id  商品的商品编号|
|`_erc20address`|`address`|  metagood contract address 元商品的合约地址|
|`_goodConfig`|`uint256`|  metagood's config refer white paper~元商品的配置,具体参见白皮书|
|`_normalinitial`|`T_BalanceUINT256`|  amount0 quantity  amount1:value~普通商品:amount0为数量,amount1为价值.|
|`_value`|`T_BalanceUINT256`|  amount0():valuegoodfee, amount1 valuegoodquantity~amount0为价值商品投资费用,amount1为价值商品投资数量.|

### e_buyGood
emit when customer buy good :当用户购买商品时触发


```solidity
event e_buyGood(
    uint256 indexed sellgood,
    uint256 indexed forgood,
    address fromer,
    uint128 swapvalue,
    T_BalanceUINT256 sellgoodstate,
    T_BalanceUINT256 forgoodstate
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sellgood`|`uint256`|good's id  商品的商品ID|
|`forgood`|`uint256`|  initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.|
|`fromer`|`address`|  seller or buyer address 卖家或买家地址|
|`swapvalue`|`uint128`|  trade value  交易价值|
|`sellgoodstate`|`T_BalanceUINT256`|  the sellgood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量|
|`forgoodstate`|`T_BalanceUINT256`|  the forgood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量|

### e_buyGoodForPay
emit when customer buy good pay to the seller :当用户购买商品支付给卖家时触发


```solidity
event e_buyGoodForPay(
    uint256 indexed buygood,
    uint256 indexed usegood,
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
|`buygood`|`uint256`|good's id  商品的商品ID|
|`usegood`|`uint256`|  initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.|
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
    uint256 _normalGoodNo,
    uint256 _valueGoodNo,
    T_BalanceUINT256 _invest,
    T_BalanceUINT256 _valueinvest
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`uint256`| normal good no~普通商品编号|
|`_valueGoodNo`|`uint256`| value good no~价值商品编号|
|`_invest`|`T_BalanceUINT256`|    amount0 normal good actual fee ,amount1 normal good actual invest quantity~amount0为投资手续费,amount1为投资数量|
|`_valueinvest`|`T_BalanceUINT256`|  amount0 value good actual fee ,amount1 value good actual invest quantity~amount0为投资手续费,amount1为投资数量|

### e_disinvestProof
emit when customer disinvest normal good :当用户撤资普通商品


```solidity
event e_disinvestProof(
    uint256 indexed _proofNo,
    uint256 _normalGoodNo,
    uint256 _valueGoodNo,
    T_BalanceUINT256 _normalgood,
    T_BalanceUINT256 _valuegood,
    T_BalanceUINT256 _profit
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`uint256`| value good no~价值商品编号|
|`_valueGoodNo`|`uint256`| value good no~价值商品编号|
|`_normalgood`|`T_BalanceUINT256`|  amount0 actual fee ,amount1 actual invest quantity~amount0为撤资手续费,amount1为撤资数量|
|`_valuegood`|`T_BalanceUINT256`|  amount0 actual fee ,amount1 actual invest quantity~amount0为撤资手续费,amount1为撤资数量|
|`_profit`|`T_BalanceUINT256`|  profit~收益|

### e_collectProofFee
emit when customer disinvest normal good :当用户撤资普通商品


```solidity
event e_collectProofFee(
    uint256 indexed _proofNo,
    uint256 _normalGoodNo,
    uint256 _valueGoodNo,
    T_BalanceUINT256 _profit,
    T_BalanceUINT256 _protocalfee
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|  proof No~投资证明编号|
|`_normalGoodNo`|`uint256`| value good no~价值商品编号|
|`_valueGoodNo`|`uint256`| value good no~价值商品编号|
|`_profit`|`T_BalanceUINT256`|  profit  amount0:normalprofit  amount1:valueprofit|
|`_protocalfee`|`T_BalanceUINT256`|  protocalfee  amount0:normalprofit  amount1:valueprofit|

## Errors
### err_total

```solidity
error err_total();
```

