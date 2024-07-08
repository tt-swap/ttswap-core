# I_Proof
包含商品的一系列接口  contain good's all interfaces


## Functions
### totalSupply

Returns the total number of market's proof 返回市场证明总数


```solidity
function totalSupply() external view returns (uint256 proofnum_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proofnum_`|`uint256`|The address of the factory manager|


### safeTransferFromWithPermit


```solidity
function safeTransferFromWithPermit(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data,
    uint256 deadline,
    bytes memory signature
) external;
```

