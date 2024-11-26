# L_GoodConfigLibrary
A library for managing and retrieving configuration data for goods

*This library uses bitwise operations and assembly for efficient storage and retrieval of configuration data*


## Functions
### isvaluegood

Check if the good is a value good


```solidity
function isvaluegood(uint256 config) internal pure returns (bool a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`bool`|True if it's a value good, false otherwise|


### isnormalgood

Check if the good is a normal good


```solidity
function isnormalgood(uint256 config) internal pure returns (bool a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`bool`|True if it's a normal good, false otherwise|


### getFlashFee

Calculate the investment fee for a given amount


```solidity
function getFlashFee(uint256 config, uint256 amount) internal pure returns (uint256 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint256`|The investment amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint256`|The calculated investment fee|


### getInvestFee

Calculate the investment fee for a given amount


```solidity
function getInvestFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint256`|The investment amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated investment fee|


### getInvestFullFee


```solidity
function getInvestFullFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```

### getDisinvestFee

Calculate the disinvestment fee for a given amount


```solidity
function getDisinvestFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint256`|The disinvestment amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated disinvestment fee|


### getBuyFee

Calculate the buying fee for a given amount


```solidity
function getBuyFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint256`|The buying amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated buying fee|


### getSellFee

Calculate the selling fee for a given amount


```solidity
function getSellFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint256`|The selling amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated selling fee|


### getSwapChips

Get the swap chips for a given amount


```solidity
function getSwapChips(uint256 config, uint128 amount) internal pure returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint128`|The amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|The swap chips for the given amount|


### getDisinvestChips

Get the disinvestment chips for a given amount


```solidity
function getDisinvestChips(uint256 config, uint128 amount) internal pure returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The configuration value|
|`amount`|`uint128`|The amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|The disinvestment chips for the given amount|


