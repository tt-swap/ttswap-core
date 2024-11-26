# IERC721Permit
**Inherits:**
IERC165



*Interface for token permits for ERC-721*


## Functions
### permit

ERC165 bytes to add to interface array - set in parent contract
_INTERFACE_ID_ERC4494 = 0x5604e225

Function to approve by way of owner signature


```solidity
function permit(address spender, uint256 tokenId, uint256 deadline, bytes memory sig) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spender`|`address`|the address to approve|
|`tokenId`|`uint256`|the index of the NFT to approve the spender on|
|`deadline`|`uint256`|a timestamp expiry for the permit|
|`sig`|`bytes`|a traditional or EIP-2098 signature|


### nonces

Returns the nonce of an NFT - useful for creating permits


```solidity
function nonces(uint256 tokenId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|the index of the NFT to get the nonce of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the uint256 representation of the nonce|


### DOMAIN_SEPARATOR

Returns the domain separator used in the encoding of the signature for permits, as defined by EIP-712


```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|the bytes32 domain separator|


