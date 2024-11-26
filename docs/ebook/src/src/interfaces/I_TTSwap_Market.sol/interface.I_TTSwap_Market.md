# I_TTSwap_Market
Defines the interface for managing market operations


## Functions
### proofmapping


```solidity
function proofmapping(uint256) external view returns (uint256);
```

### userConfig


```solidity
function userConfig(address) external view returns (uint256);
```

### setMarketor


```solidity
function setMarketor(address _newmarketor) external;
```

### removeMarketor


```solidity
function removeMarketor(address _user) external;
```

### initMetaGood

Initialize the first good in the market


```solidity
function initMetaGood(address _erc20address, uint256 _initial, uint256 _goodconfig, bytes memory data)
    external
    payable
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20address`|`address`|The contract address of the good|
|`_initial`|`uint256`|Initial parameters for the good (amount0: value, amount1: quantity)|
|`_goodconfig`|`uint256`|Configuration of the good|
|`data`|`bytes`|Configuration of the good|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### initGood

Initialize a normal good in the market


```solidity
function initGood(
    address _valuegood,
    uint256 _initial,
    address _erc20address,
    uint256 _goodConfig,
    bytes memory data1,
    bytes memory data2
) external payable returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_valuegood`|`address`|The ID of the value good used to measure the normal good's value|
|`_initial`|`uint256`|Initial parameters (amount0: normal good quantity, amount1: value good quantity)|
|`_erc20address`|`address`|The contract address of the good|
|`_goodConfig`|`uint256`|Configuration of the good|
|`data1`|`bytes`|Configuration of the good|
|`data2`|`bytes`|Configuration of the good|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### buyGood

Sell one good to buy another


```solidity
function buyGood(
    address _goodid1,
    address _goodid2,
    uint128 _swapQuantity,
    uint256 _limitprice,
    bool _istotal,
    address _referal,
    bytes memory data1
) external payable returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`address`|ID of the good to sell|
|`_goodid2`|`address`|ID of the good to buy|
|`_swapQuantity`|`uint128`|Quantity of _goodid1 to sell|
|`_limitprice`|`uint256`|Price limit for the trade|
|`_istotal`|`bool`|Whether to trade all or partial amount|
|`_referal`|`address`|Referral address|
|`data1`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid2Quantity_`|`uint128`|Actual quantity of good2 received|
|`goodid2FeeQuantity_`|`uint128`|Fee quantity for good2|


### buyGoodForPay

Buy a good, sell another, and send to a recipient


```solidity
function buyGoodForPay(
    address _goodid1,
    address _goodid2,
    uint128 _swapQuantity,
    uint256 _limitprice,
    address _recipent,
    bytes memory data1
) external payable returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`address`|ID of the good to buy|
|`_goodid2`|`address`|ID of the good to sell|
|`_swapQuantity`|`uint128`|Quantity of _goodid2 to buy|
|`_limitprice`|`uint256`|Price limit for the trade|
|`_recipent`|`address`|Address of the recipient|
|`data1`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid1Quantity_`|`uint128`|Actual quantity of good1 received|
|`goodid1FeeQuantity_`|`uint128`|Fee quantity for good1|


### investGood

Invest in a normal good


```solidity
function investGood(address _togood, address _valuegood, uint128 _quantity, bytes memory data1, bytes memory data2)
    external
    payable
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_togood`|`address`|ID of the normal good to invest in|
|`_valuegood`|`address`|ID of the value good|
|`_quantity`|`uint128`|Quantity of normal good to invest|
|`data1`|`bytes`||
|`data2`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### disinvestProof

Disinvest from a normal good


```solidity
function disinvestProof(uint256 _proofid, uint128 _goodQuantity, address _gater) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|ID of the investment proof|
|`_goodQuantity`|`uint128`|Quantity to disinvest|
|`_gater`|`address`|Address of the gater|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### collectProof

Collect profit from an investment proof


```solidity
function collectProof(uint256 _proofid, address _gater) external returns (uint256 profit_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|ID of the investment proof|
|`_gater`|`address`|Address of the gater|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`uint256`|Collected profit (amount0: normal good profit, amount1: value good profit)|


### ishigher

Check if the price of a good is higher than a comparison price


```solidity
function ishigher(address goodid, address valuegood, uint256 compareprice) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|ID of the good to check|
|`valuegood`|`address`|ID of the value good|
|`compareprice`|`uint256`|Price to compare against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether the good's price is higher|


### getProofState


```solidity
function getProofState(uint256 proofid) external view returns (S_ProofState memory);
```

### getGoodState


```solidity
function getGoodState(address goodkey) external view returns (S_GoodTmpState memory);
```

### marketconfig

Returns the market configuration

*Can be changed by the market manager*


```solidity
function marketconfig() external view returns (uint256 marketconfig_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`marketconfig_`|`uint256`|The market configuration|


### setMarketConfig

Sets the market configuration


```solidity
function setMarketConfig(uint256 _marketconfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|The new market configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### updateGoodConfig

Updates a good's configuration


```solidity
function updateGoodConfig(address _goodid, uint256 _goodConfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The new configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### modifyGoodConfig

Allows market admin to modify a good's attributes


```solidity
function modifyGoodConfig(address _goodid, uint256 _goodConfig) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The new configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### payGood

Transfers a good to another address


```solidity
function payGood(address _goodid, uint128 _payquanity, address _recipent, bytes memory transdata)
    external
    payable
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_payquanity`|`uint128`|The quantity to transfer|
|`_recipent`|`address`|The recipient's address|
|`transdata`|`bytes`|The recipient's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### changeGoodOwner

Changes the owner of a good


```solidity
function changeGoodOwner(address _goodid, address _to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_to`|`address`|The new owner's address|


### collectCommission

Collects commission for specified goods


```solidity
function collectCommission(address[] memory _goodid) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address[]`|Array of good IDs|


### queryCommission

Queries commission for specified goods and recipient


```solidity
function queryCommission(address[] memory _goodid, address _recipent) external returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address[]`|Array of good IDs|
|`_recipent`|`address`|The recipient's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|Array of commission amounts|


### addbanlist

Adds an address to the ban list


```solidity
function addbanlist(address _user) external returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address to ban|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`is_success_`|`bool`|Success status|


### removebanlist

Removes an address from the ban list


```solidity
function removebanlist(address _user) external returns (bool is_success_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address to unban|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`is_success_`|`bool`|Success status|


### goodWelfare

Delivers welfare to investors


```solidity
function goodWelfare(address goodid, uint128 welfare, bytes memory data1) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|The ID of the good|
|`welfare`|`uint128`|The amount of welfare|
|`data1`|`bytes`||


### delproofdata

*Internal function to handle proof data deletion and updates during transfer.*


```solidity
function delproofdata(uint256 proofid, address from, address to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proofid`|`uint256`|The ID of the proof being transferred.|
|`from`|`address`|The address transferring the proof.|
|`to`|`address`|The address receiving the proof.|


### flashLoan1


```solidity
function flashLoan1(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data,
    bytes memory transdata
) external returns (bool);
```

## Events
### e_changemarketcreator
Emitted when market configuration is set


```solidity
event e_changemarketcreator(address _newmarketor);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newmarketor`|`address`|The marketcreator|

### e_setMarketConfig
Emitted when market configuration is set


```solidity
event e_setMarketConfig(uint256 _marketconfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|The market configuration|

### e_updateGoodConfig
Emitted when a good's configuration is updated


```solidity
event e_updateGoodConfig(address _goodid, uint256 _goodConfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The new configuration|

### e_modifyGoodConfig
Emitted when a good's configuration is modified by market admin


```solidity
event e_modifyGoodConfig(address _goodid, uint256 _goodconfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodconfig`|`uint256`|The new configuration|

### e_changegoodowner
Emitted when a good's owner is changed


```solidity
event e_changegoodowner(address goodid, address to);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|The ID of the good|
|`to`|`address`|The new owner's address|

### e_collectcommission
Emitted when market commission is collected


```solidity
event e_collectcommission(address[] _gooid, uint256[] _commisionamount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_gooid`|`address[]`|Array of good IDs|
|`_commisionamount`|`uint256[]`|Array of commission amounts|

### e_modifiedUserConfig
Emitted when an address is added to the ban list


```solidity
event e_modifiedUserConfig(address _user, uint256 config);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The banned user's address|
|`config`|`uint256`||

### e_goodWelfare
Emitted when welfare is delivered to investors


```solidity
event e_goodWelfare(address goodid, uint128 welfare);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|The ID of the good|
|`welfare`|`uint128`|The amount of welfare|

### e_collectProtocolFee
Emitted when protocol fee is collected


```solidity
event e_collectProtocolFee(address goodid, uint256 feeamount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|The ID of the good|
|`feeamount`|`uint256`|The amount of fee collected|

### e_transferdel
Emitted when proofid deleted when proofid is transfer.


```solidity
event e_transferdel(uint256 delproofid, uint256 existsproofid);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`delproofid`|`uint256`|fromproofid which will be deleted|
|`existsproofid`|`uint256`|conbine to existsproofid|

### e_initMetaGood
Emitted when a meta good is created and initialized

*The decimal precision of _initial.amount0() defaults to 6*


```solidity
event e_initMetaGood(uint256 _proofNo, address _goodid, uint256 _construct, uint256 _goodConfig, uint256 _initial);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|The ID of the investment proof|
|`_goodid`|`address`|A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct|
|`_construct`|`uint256`|A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct|
|`_goodConfig`|`uint256`|The configuration of the meta good (refer to the whitepaper for details)|
|`_initial`|`uint256`|Market initialization parameters: amount0 is the value, amount1 is the quantity|

### e_initGood
Emitted when a good is created and initialized


```solidity
event e_initGood(
    uint256 _proofNo,
    address _goodid,
    address _valuegoodNo,
    uint256 _goodConfig,
    uint256 _construct,
    uint256 _normalinitial,
    uint256 _value
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|The ID of the investment proof|
|`_goodid`|`address`|A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct|
|`_valuegoodNo`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The configuration of the meta good (refer to the whitepaper for details)|
|`_construct`|`uint256`|A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct|
|`_normalinitial`|`uint256`|Normal good initialization parameters: amount0 is the quantity, amount1 is the value|
|`_value`|`uint256`|Value good initialization parameters: amount0 is the investment fee, amount1 is the investment quantity|

### e_buyGood
Emitted when a user buys a good


```solidity
event e_buyGood(
    address indexed sellgood,
    address indexed forgood,
    address fromer,
    uint128 swapvalue,
    uint256 sellgoodstate,
    uint256 forgoodstate
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sellgood`|`address`|The ID of the good being sold|
|`forgood`|`address`|The ID of the good being bought|
|`fromer`|`address`|The address of the buyer|
|`swapvalue`|`uint128`|The trade value|
|`sellgoodstate`|`uint256`|The status of the sold good (amount0: fee, amount1: quantity)|
|`forgoodstate`|`uint256`|The status of the bought good (amount0: fee, amount1: quantity)|

### e_buyGoodForPay
Emitted when a user buys a good and pays the seller


```solidity
event e_buyGoodForPay(
    address indexed buygood,
    address indexed usegood,
    address fromer,
    address receipt,
    uint128 swapvalue,
    uint256 buygoodstate,
    uint256 usegoodstate
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`buygood`|`address`|The ID of the good being bought|
|`usegood`|`address`|The ID of the good being used for payment|
|`fromer`|`address`|The address of the buyer|
|`receipt`|`address`|The address of the recipient (seller)|
|`swapvalue`|`uint128`|The trade value|
|`buygoodstate`|`uint256`|The status of the bought good (amount0: fee, amount1: quantity)|
|`usegoodstate`|`uint256`|The status of the used good (amount0: fee, amount1: quantity)|

### e_investGood
Emitted when a user invests in a normal good


```solidity
event e_investGood(
    uint256 indexed _proofNo,
    address _normalgoodid,
    address _valueGoodNo,
    uint256 _value,
    uint256 _invest,
    uint256 _valueinvest
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|The ID of the investment proof|
|`_normalgoodid`|`address`|Packed data: first 128 bits for good's ID, last 128 bits for stake construct|
|`_valueGoodNo`|`address`|The ID of the value good|
|`_value`|`uint256`|Investment value (amount0: invest value, amount1: restake construct)|
|`_invest`|`uint256`|Normal good investment details (amount0: actual fee, amount1: actual invest quantity)|
|`_valueinvest`|`uint256`|Value good investment details (amount0: actual fee, amount1: actual invest quantity)|

### e_disinvestProof
Emitted when a user disinvests from a normal good


```solidity
event e_disinvestProof(
    uint256 indexed _proofNo,
    address _normalGoodNo,
    address _valueGoodNo,
    uint256 _value,
    uint256 _normalgood,
    uint256 _valuegood,
    uint256 _profit
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|The ID of the investment proof|
|`_normalGoodNo`|`address`|The ID of the normal good|
|`_valueGoodNo`|`address`|The ID of the value good|
|`_value`|`uint256`||
|`_normalgood`|`uint256`|The disinvestment details of the normal good (amount0: actual fee, amount1: actual disinvest quantity)|
|`_valuegood`|`uint256`|The disinvestment details of the value good (amount0: actual fee, amount1: actual disinvest quantity)|
|`_profit`|`uint256`|The profit (amount0: normal good profit, amount1: value good profit)|

### e_collectProof
Emitted when a user collects profit from an investment proof


```solidity
event e_collectProof(uint256 indexed _proofNo, address _normalGoodNo, address _valueGoodNo, uint256 _profit);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofNo`|`uint256`|The ID of the investment proof|
|`_normalGoodNo`|`address`|The ID of the normal good|
|`_valueGoodNo`|`address`|The ID of the value good|
|`_profit`|`uint256`|The collected profit (amount0: normal good profit, amount1: value good profit)|

### e_enpower
Emitted when a good is empowered


```solidity
event e_enpower(uint256 _goodid, uint256 _valuegood, uint256 _quantity);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`uint256`|The ID of the good|
|`_valuegood`|`uint256`|The ID of the value good|
|`_quantity`|`uint256`|The quantity of the value good to empower|

## Errors
### noEnoughOutputError

```solidity
error noEnoughOutputError();
```

