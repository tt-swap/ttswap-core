# ProofManage
**Inherits:**
[I_Proof](/Contracts/interfaces/I_Proof.sol/interface.I_Proof.md), Context, ERC165, EIP712


## State Variables
### _NFTname

```solidity
string private constant _NFTname = "TTS NFT";
```


### _NFTsymbol

```solidity
string private constant _NFTsymbol = "TTS";
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


### _nonces

```solidity
mapping(uint256 => Counters.Counter) private _nonces;
```


### _PERMIT_TYPEHASH

```solidity
bytes32 private immutable _PERMIT_TYPEHASH =
    keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");
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
constructor() EIP712(_NFTname, "1");
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
function ownerOf(uint256 proofId) public view returns (address);
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
function getApproved(uint256 proofId) public view returns (address);
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


### _checkOnERC721Received


```solidity
function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private;
```

### nonces


```solidity
function nonces(uint256 tokenId) external view virtual override returns (uint256);
```

### DOMAIN_SEPARATOR


```solidity
function DOMAIN_SEPARATOR() external view override returns (bytes32);
```

### permit


```solidity
function permit(address spender, uint256 tokenId, uint256 deadline, bytes memory signature) external override;
```

### _permit


```solidity
function _permit(address spender, uint256 tokenId, uint256 deadline, bytes memory signature) internal virtual;
```

### _isValidContractERC1271Signature


```solidity
function _isValidContractERC1271Signature(address signer, bytes32 hash, bytes memory signature)
    private
    view
    returns (bool);
```

### safeTransferFromWithPermit


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

