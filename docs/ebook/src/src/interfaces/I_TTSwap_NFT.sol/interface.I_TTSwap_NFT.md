# I_TTSwap_NFT
Contains a series of interfaces for goods


## Functions
### mint

*mint nft for recipent*


```solidity
function mint(address recipent, uint256 tokenid) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipent`|`address`|who is  the tokenid  minted the tokenid for .|
|`tokenid`|`uint256`|the tokenid.|


### proofsource

*record which contract is storing the tokenid*


```solidity
function proofsource(uint256 tokenid) external view returns (address cd);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenid`|`uint256`|The current owner of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`cd`|`address`|the contract address of tokenid|


### isApprovedOrOwner

*get the token  approved to the spender*


```solidity
function isApprovedOrOwner(address spender, uint256 tokenId) external returns (bool result);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spender`|`address`|who|
|`tokenId`|`uint256`|The new owner.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`bool`|result|


### burn

*burn tokenid*


```solidity
function burn(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|which tokenid will be burned.|


### safeTransferFromWithPermit

*Safely transfers the ownership of a given token ID to another address with a permit.*


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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The current owner of the token.|
|`to`|`address`|The new owner.|
|`tokenId`|`uint256`|The ID of the token to be transferred.|
|`_data`|`bytes`|Additional data with no specified format.|
|`deadline`|`uint256`|The time at which the signature expires.|
|`signature`|`bytes`|A valid EIP712 signature.|


