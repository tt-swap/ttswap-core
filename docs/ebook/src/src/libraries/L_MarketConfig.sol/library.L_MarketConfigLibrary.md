# L_MarketConfigLibrary
Library for managing and calculating various fee configurations for a market


## Functions
### getLiquidFee

Calculate the liquidity provider fee amount


```solidity
function getLiquidFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated liquidity provider fee amount|


### getSellerFee

Calculate the seller fee amount


```solidity
function getSellerFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated seller fee amount|


### getGaterFee

Calculate the gater fee amount


```solidity
function getGaterFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated gater fee amount|


### getReferFee

Calculate the referrer fee amount


```solidity
function getReferFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated referrer fee amount|


### getCustomerFee

Calculate the customer fee amount


```solidity
function getCustomerFee(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated customer fee amount|


### getPlatFee128

Calculate the platform fee amount and return it as a uint128


```solidity
function getPlatFee128(uint256 config, uint256 amount) internal pure returns (uint128 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint128`|The calculated platform fee amount as a uint128|


### getPlatFee256

Calculate the platform fee amount and return it as a uint256


```solidity
function getPlatFee256(uint256 config, uint256 amount) internal pure returns (uint256 a);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`uint256`|The market configuration|
|`amount`|`uint256`|The total amount to calculate the fee from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint256`|The calculated platform fee amount as a uint256|


