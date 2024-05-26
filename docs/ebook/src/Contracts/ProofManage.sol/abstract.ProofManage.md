# ProofManage
**Inherits:**
[I_Proof](/Contracts/interfaces/I_Proof.sol/interface.I_Proof.md), Context, ERC165


## State Variables
### _name

```solidity
string private constant _name = "TTSWAP NFT";
```


### _symbol

```solidity
string private constant _symbol = "TTN";
```


### totalSupply

```solidity
uint256 public override totalSupply;
```


### proofs

```solidity
mapping(uint256 => L_Proof.S_ProofState) internal proofs;
```


### ownerproofs

```solidity
mapping(address => L_ArrayStorage.S_ArrayStorage) internal ownerproofs;
```


### proofseq

```solidity
mapping(bytes32 => uint256) public proofseq;
```


### _operatorApprovals

```solidity
mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner(uint256 proofid);
```

### onlyApproval


```solidity
modifier onlyApproval(uint256 proofid);
```

### constructor


```solidity
constructor();
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool);
```

### tokenURI

*See [IERC721Metadata-tokenURI](/lib/forge-std/test/mocks/MockERC721.t.sol/contract.Token_ERC721.md#tokenuri).*


```solidity
function tokenURI(uint256 proofId) external view onlyOwner(proofId) returns (string memory);
```

### balanceOf

*Base URI for computing [tokenURI](/Contracts/ProofManage.sol/abstract.ProofManage.md#tokenuri). If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `proofId`. Empty
by default, can be overridden in child contracts.*


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### ownerOf


```solidity
function ownerOf(uint256 proofId) external view returns (address);
```

### tokenByIndex


```solidity
function tokenByIndex(uint256 _index) external pure returns (uint256);
```

### tokenOfOwnerByIndex


```solidity
function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
```

### getProofId

get the invest proof'id ~ 获取投资证明ID


```solidity
function getProofId(S_ProofKey calldata _investproofkey) external view override returns (uint256 proof_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_investproofkey`|`S_ProofKey`|  生成投资证明的参数据|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proof_`|`uint256`|投资证明的ID|


### name


```solidity
function name() external pure returns (string memory);
```

### symbol


```solidity
function symbol() external pure returns (string memory);
```

### approve


```solidity
function approve(address to, uint256 proofId) external onlyApproval(proofId);
```

### getApproved


```solidity
function getApproved(uint256 proofId) external view returns (address);
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) external;
```

### isApprovedForAll


```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 proofid) public onlyApproval(proofid);
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 proofid) external;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
```

### getProofState

get the invest proof'id 获取投资证明ID详情


```solidity
function getProofState(uint256 _proof) external view override returns (L_Proof.S_ProofState memory proof_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proof`|`uint256`|  证明编号|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proof_`|`L_Proof.S_ProofState`| 证明信息|


### changeProofOwner

改变投资证明的拥有者


```solidity
function changeProofOwner(uint256 _proofid, address _to) external override returns (bool);
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


### _checkOnERC721Received


```solidity
function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private;
```

