# L_TakeLimitPriceOrder
This library provides functions for investing, disinvesting, swapping, and fee management for goods

*A library for managing goods in a decentralized marketplace*


## Functions
### init_takeGoodCache


```solidity
function init_takeGoodCache(
    S_takeGoodCache memory _stepCache,
    S_takeGoodInputPrams memory inputdata,
    uint256 _good1curstate,
    uint256 _good1config,
    uint256 _good2curstate,
    uint256 _good2config,
    uint96 _tolerance
) internal pure;
```

### takeGoodCompute

Compute the swap result from good1 to good2

*Implements a complex swap algorithm considering price limits, fees, and minimum swap amounts*


```solidity
function takeGoodCompute(S_takeGoodCache memory _stepCache) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stepCache`|`S_takeGoodCache`|A cache structure containing swap state and configurations|


### isOverPrice


```solidity
function isOverPrice(S_takeGoodCache memory _stepCache) internal pure returns (bool);
```

## Structs
### S_takeGoodCache

```solidity
struct S_takeGoodCache {
    uint128 remainQuantity;
    uint128 outputQuantity;
    uint128 feeQuantity;
    uint128 swapvalue;
    uint128 goodid2FeeQuantity_;
    uint128 goodid2Quantity_;
    uint256 good1currentState;
    uint256 good1config;
    uint256 good2currentState;
    uint256 good2config;
    uint256 limitPrice;
}
```

