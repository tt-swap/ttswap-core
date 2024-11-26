# EIP712
EIP712 helpers for permit2

*Maintains cross-chain replay protection in the event of a fork*

*Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol*


## State Variables
### _CACHED_DOMAIN_SEPARATOR

```solidity
bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
```


### _CACHED_CHAIN_ID

```solidity
uint256 private immutable _CACHED_CHAIN_ID;
```


### _HASHED_NAME

```solidity
bytes32 private constant _HASHED_NAME = keccak256("SimplePermit");
```


### _TYPE_HASH

```solidity
bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
```


## Functions
### constructor


```solidity
constructor();
```

### DOMAIN_SEPARATOR

Returns the domain separator for the current chain.

*Uses cached version if chainid and address are unchanged from construction.*


```solidity
function DOMAIN_SEPARATOR() public view returns (bytes32);
```

### _buildDomainSeparator

Builds a domain separator using the current chainId and contract address.


```solidity
function _buildDomainSeparator(bytes32 typeHash, bytes32 nameHash) private view returns (bytes32);
```

### _hashTypedData

Creates an EIP-712 typed data hash


```solidity
function _hashTypedData(bytes32 dataHash) internal view returns (bytes32);
```

