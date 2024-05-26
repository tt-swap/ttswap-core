# MarketManager
**Inherits:**
[Multicall](/Contracts/Multicall.sol/abstract.Multicall.md), [GoodManage](/Contracts/GoodManage.sol/abstract.GoodManage.md), [ProofManage](/Contracts/ProofManage.sol/abstract.ProofManage.md), [I_MarketManage](/Contracts/interfaces/I_MarketManage.sol/interface.I_MarketManage.md)


## Functions
### constructor


```solidity
constructor(address _marketcreator, uint256 _marketconfig) GoodManage(_marketcreator, _marketconfig);
```

### initMetaGood

initial market's first good~初始化市场中第一个商品


```solidity
function initMetaGood(address _erc20address, T_BalanceUINT256 _initial, uint256 _goodConfig)
    external
    payable
    override
    onlyMarketCreator
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20address`|`address`|good's contract address~商品合约地址|
|`_initial`|`T_BalanceUINT256`|  initial good.amount0:value,amount1:quantity~初始化的商品的参数,前128位为价值,后128位为数量.|
|`_goodConfig`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|metagood_no_  good_no~商品编号|
|`<none>`|`uint256`|proof_no_  proof_no~投资证明编号|


### initGood

initial the normal good~初始化市场中的普通商品


```solidity
function initGood(
    uint256 _valuegood,
    T_BalanceUINT256 _initial,
    address _erc20address,
    uint256 _goodConfig,
    address _gater
) external payable override noReentrant returns (uint256, uint256);
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
|`<none>`|`uint256`|goodNo_ the_normal_good_No ~普通物品的编号|
|`<none>`|`uint256`|proofNo_ the_proof_of_initial_good~初始化普通物品的投资证明|


### buyGood

sell _swapQuantity units of good1 to buy good2~用户出售_swapQuantity个_goodid1去购买 _goodid2

*如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1*


```solidity
function buyGood(
    uint256 _goodid1,
    uint256 _goodid2,
    uint128 _swapQuantity,
    uint256 _limitPrice,
    bool _istotal,
    address _gater
) external override noReentrant returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`uint256`|good1's No~商品1的编号|
|`_goodid2`|`uint256`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|good1's quantity~商品1的数量|
|`_limitPrice`|`uint256`||
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
    uint256 _limitPrice,
    address _recipent,
    address _gater
) external override noReentrant returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`uint256`|good1's No~商品1的编号|
|`_goodid2`|`uint256`|good2's No~商品2的编号|
|`_swapQuantity`|`uint128`|buy good2's quantity~购买商品2的数量|
|`_limitPrice`|`uint256`||
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
    override
    noReentrant
    returns (
        L_Good.S_GoodInvestReturn memory normalInvest_,
        L_Good.S_GoodInvestReturn memory valueInvest_,
        uint256 proofno_
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
|`proofno_`|`uint256`|normalProofno_  证明编号|


### disinvestGood

disinvest normal good~撤资普通商品


```solidity
function disinvestGood(uint256 _togood, uint256 _valuegood, uint128 _goodQuantity, address _gater)
    external
    override
    returns (
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_,
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_,
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
|`disinvestNormalResult1_`|`L_Good.S_GoodDisinvestReturn`|disinvestResult1_ 普通商品结果 disinvestResult1_.profit; // profit of stake 投资收入 disinvestResult1_.actual_fee; // actual fee 实际手续费 disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`disinvestValueResult2_`|`L_Good.S_GoodDisinvestReturn`|disinvestResult2_ 价值商品结果 disinvestResult2_.profit; // profit of stake 投资收入 disinvestResult2_.actual_fee; // actual fee 实际手续费 disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`proofno_`|`uint256`| 证明编号|


### disinvestProof

disinvest normal good~撤资商品


```solidity
function disinvestProof(uint256 _proofid, uint128 _goodQuantity, address _gater)
    public
    override
    noReentrant
    returns (
        L_Good.S_GoodDisinvestReturn memory disinvestNormalResult1_,
        L_Good.S_GoodDisinvestReturn memory disinvestValueResult2_
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
|`disinvestNormalResult1_`|`L_Good.S_GoodDisinvestReturn`|disinvestResult1_ 普通商品结果 disinvestResult1_.profit; // profit of stake 投资收入 disinvestResult1_.actual_fee; // actual fee 实际手续费 disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量|
|`disinvestValueResult2_`|`L_Good.S_GoodDisinvestReturn`|disinvestResult2_ 价值商品结果 disinvestResult2_.profit; // profit of stake 投资收入 disinvestResult2_.actual_fee; // actual fee 实际手续费 disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值 disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量|


### collectProofFee

collect the profit of normal proof~提取普通投资证明的收益


```solidity
function collectProofFee(uint256 _proofid) external override returns (T_BalanceUINT256 profit_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  the proof No of invest normal good~普通投资证明编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`T_BalanceUINT256`|  amount0 普通商品的投资收益 amount1价值商品的投资收益|


