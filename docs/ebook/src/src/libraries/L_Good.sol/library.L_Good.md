# L_Good
This library provides functions for investing, disinvesting, swapping, and fee management for goods

*A library for managing goods in a decentralized marketplace*


## Functions
### updateGoodConfig

Update the good configuration

*Preserves the top 33 bits of the existing config and updates the rest*


```solidity
function updateGoodConfig(S_GoodState storage _self, uint256 _goodConfig) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_goodConfig`|`uint256`|New configuration value to be applied|


### init

Initialize the good state

*Sets up the initial state, configuration, and owner of the good*


```solidity
function init(S_GoodState storage self, uint256 _init, uint256 _goodConfig) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`self`|`S_GoodState`|Storage pointer to the good state|
|`_init`|`uint256`|Initial balance state|
|`_goodConfig`|`uint256`|Configuration of the good|


### swapCompute1

Compute the swap result from good1 to good2

*Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts*


```solidity
function swapCompute1(swapCache memory _stepCache, uint256 _limitPrice) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stepCache`|`swapCache`|A cache structure containing swap state and configurations|
|`_limitPrice`|`uint256`|The price limit for the swap|


### swapCompute2

Compute the swap result from good2 to good1

*Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts*


```solidity
function swapCompute2(swapCache memory _stepCache, uint256 _limitPrice) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stepCache`|`swapCache`|A cache structure containing swap state and configurations|
|`_limitPrice`|`uint256`|The price limit for the swap|


### swapCommit

Commit the result of a swap operation to the good's state

*Updates the current state and fee state of the good after a swap*


```solidity
function swapCommit(S_GoodState storage _self, uint256 _swapstate, uint128 _fee) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_swapstate`|`uint256`|The new state of the good after the swap|
|`_fee`|`uint128`|The fee amount collected from the swap|


### investGood

Invest in a good

*Calculates fees, updates states, and returns investment results*


```solidity
function investGood(S_GoodState storage _self, uint128 _invest, S_GoodInvestReturn memory investResult_) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_invest`|`uint128`|Amount to invest|
|`investResult_`|`S_GoodInvestReturn`||


### disinvestGood

Disinvest from a good and potentially its associated value good

*This function handles the complex process of disinvesting from a good, including fee calculations and state updates*


```solidity
function disinvestGood(
    S_GoodState storage _self,
    S_GoodState storage _valueGoodState,
    S_ProofState storage _investProof,
    S_GoodDisinvestParam memory _params
)
    internal
    returns (
        S_GoodDisinvestReturn memory normalGoodResult1_,
        S_GoodDisinvestReturn memory valueGoodResult2_,
        uint128 disinvestvalue
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the main good state|
|`_valueGoodState`|`S_GoodState`|Storage pointer to the value good state (if applicable)|
|`_investProof`|`S_ProofState`|Storage pointer to the investment proof state|
|`_params`|`S_GoodDisinvestParam`|Struct containing disinvestment parameters|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`normalGoodResult1_`|`S_GoodDisinvestReturn`|Struct containing disinvestment results for the main good|
|`valueGoodResult2_`|`S_GoodDisinvestReturn`|Struct containing disinvestment results for the value good (if applicable)|
|`disinvestvalue`|`uint128`|The total value being disinvested|


### collectGoodFee

Collect fees for a good and its associated value good

*This function handles the process of collecting fees for a good and its associated value good, if applicable*


```solidity
function collectGoodFee(
    S_GoodState storage _self,
    S_GoodState storage _valuegood,
    S_ProofState storage _investProof,
    address _gater,
    address _referral,
    uint256 _marketconfig,
    address _marketcreator
) internal returns (uint256 profit);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the main good state|
|`_valuegood`|`S_GoodState`|Storage pointer to the value good state (if applicable)|
|`_investProof`|`S_ProofState`|Storage pointer to the investment proof state|
|`_gater`|`address`|The address of the gater (if applicable)|
|`_referral`|`address`|The address of the referrer (if applicable)|
|`_marketconfig`|`uint256`|The market configuration|
|`_marketcreator`|`address`|The address of the market creator|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit`|`uint256`|The total profit collected|


### allocateFee

Allocate fees to various parties

*This function handles the allocation of fees to the market creator, gater, referrer, and liquidity providers*


```solidity
function allocateFee(
    S_GoodState storage _self,
    uint128 _profit,
    uint256 _marketconfig,
    address _gater,
    address _referral,
    address _marketcreator,
    uint128 _divestQuantity
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_profit`|`uint128`|The total profit to be allocated|
|`_marketconfig`|`uint256`|The market configuration|
|`_gater`|`address`|The address of the gater (if applicable)|
|`_referral`|`address`|The address of the referrer (if applicable)|
|`_marketcreator`|`address`|The address of the market creator|
|`_divestQuantity`|`uint128`|The quantity of goods being divested (if applicable)|


### modifyGoodConfig

Modify the good configuration

*This function modifies the good configuration by preserving the top 33 bits and updating the rest*


```solidity
function modifyGoodConfig(S_GoodState storage _self, uint256 _goodconfig) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_goodconfig`|`uint256`|The new configuration value to be applied|


### fillFee

fill good

*Preserves the top 33 bits of the existing config and updates the rest*


```solidity
function fillFee(S_GoodState storage _self, uint256 _fee) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_GoodState`|Storage pointer to the good state|
|`_fee`|`uint256`|New configuration value to be applied|


## Structs
### swapCache
*Struct to cache swap-related data*


```solidity
struct swapCache {
    uint128 remainQuantity;
    uint128 outputQuantity;
    uint128 feeQuantity;
    uint128 swapvalue;
    uint256 good1currentState;
    uint256 good1config;
    uint256 good2currentState;
    uint256 good2config;
}
```

### S_GoodInvestReturn
Struct to hold the return values of an investment operation

*Used to store and return the results of investing in a good*


```solidity
struct S_GoodInvestReturn {
    uint128 actualFeeQuantity;
    uint128 constructFeeQuantity;
    uint128 actualInvestValue;
    uint128 actualInvestQuantity;
}
```

### S_GoodDisinvestReturn
Struct to hold the return values of a disinvestment operation

*Used to store and return the results of disinvesting from a good*


```solidity
struct S_GoodDisinvestReturn {
    uint128 profit;
    uint128 actual_fee;
    uint128 actualDisinvestQuantity;
}
```

### S_GoodDisinvestParam
Struct to hold the parameters for a disinvestment operation

*Used to pass multiple parameters to the disinvestGood function*


```solidity
struct S_GoodDisinvestParam {
    uint128 _goodQuantity;
    address _gater;
    address _referral;
    uint256 _marketconfig;
    address _marketcreator;
}
```

