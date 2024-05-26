# I_Proof
**Inherits:**
IERC721, IERC721Metadata, IERC721Enumerable

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


### getProofId

get the invest proof'id ~ 获取投资证明ID


```solidity
function getProofId(S_ProofKey calldata _investproofkey) external view returns (uint256 proof_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_investproofkey`|`S_ProofKey`|  生成投资证明的参数据|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proof_`|`uint256`|投资证明的ID|


### changeProofOwner

改变投资证明的拥有者


```solidity
function changeProofOwner(uint256 _proofid, address _to) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|  生成投资证明的参数据|
|`_to`|`address`|  生成投资证明的参数据|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|proof_ 投资证明的ID|


### getProofState

get the invest proof'id 获取投资证明ID详情


```solidity
function getProofState(uint256 _proof) external view returns (L_Proof.S_ProofState memory proof_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proof`|`uint256`|  证明编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proof_`|`L_Proof.S_ProofState`| 证明信息|


