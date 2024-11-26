# TTSwap_NFT
**Inherits:**
[I_TTSwap_NFT](/src/interfaces/I_TTSwap_NFT.sol/interface.I_TTSwap_NFT.md), ERC721Permit

*Abstract contract for managing proofs as ERC721 tokens with additional functionality.
Inherits from I_Proof and ERC721Permit.*


## State Variables
### proofsource
*record which contract is storing the tokenid*


```solidity
mapping(uint256 => address) public override proofsource;
```


### officialTokenContract

```solidity
address internal immutable officialTokenContract;
```


## Functions
### constructor

*Constructor to initialize the ProofManage contract.*


```solidity
constructor(address _officialTokenContract) ERC721Permit("TTSwap NFT", "TTN");
```

### _baseURI

*Returns the base URI for computing {tokenURI}.*


```solidity
function _baseURI() internal pure override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string The base URI string.|


### transferFrom

*Transfers ownership of a token from one address to another address.*


```solidity
function transferFrom(address from, address to, uint256 tokenId) public override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The current owner of the token.|
|`to`|`address`|The new owner.|
|`tokenId`|`uint256`|The ID of the token being transferred.|


### safeTransferFrom

*Safely transfers the ownership of a given token ID to another address.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The current owner of the token.|
|`to`|`address`|The new owner.|
|`tokenId`|`uint256`|The ID of the token to be transferred.|
|`data`|`bytes`|Additional data with no specified format.|


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
) external override;
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


### mint

*mint nft for recipent*


```solidity
function mint(address recipent, uint256 tokenid) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipent`|`address`|who is  the tokenid  minted the tokenid for .|
|`tokenid`|`uint256`|the tokenid.|


### isApprovedOrOwner

*get the token  approved to the spender*


```solidity
function isApprovedOrOwner(address spender, uint256 tokenId) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spender`|`address`|who|
|`tokenId`|`uint256`|The new owner.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|result|


### burn

*burn tokenid*


```solidity
function burn(uint256 tokenId) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|which tokenid will be burned.|


