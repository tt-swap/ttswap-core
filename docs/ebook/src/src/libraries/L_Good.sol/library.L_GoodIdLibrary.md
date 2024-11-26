# L_GoodIdLibrary

## Functions
### toId

Convert a good key to an ID

*This function converts a good key to a unique ID using keccak256 hashing*


```solidity
function toId(S_GoodKey memory goodKey) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodKey`|`S_GoodKey`|The good key to be converted|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The unique ID of the good|


