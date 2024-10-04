# ProofManage
**Inherits:**
[I_Proof](/Contracts/interfaces/I_Proof.sol/interface.I_Proof.md), ERC721Permit


## State Variables
### totalSupply

```solidity
uint256 public override totalSupply;
```


### proofs

```solidity
mapping(uint256 => L_Proof.S_ProofState) internal proofs;
```


### proofmapping

```solidity
mapping(bytes32 => uint256) public proofmapping;
```


## Functions
### constructor


```solidity
constructor() ERC721Permit("TTS NFT", "TTS");
```

### _baseURI


```solidity
function _baseURI() internal pure override returns (string memory);
```

### getProofState


```solidity
function getProofState(uint256 proofid) external view returns (L_Proof.S_ProofState memory _proof);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 proofid) public override;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 proofid, bytes memory data) public override;
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

