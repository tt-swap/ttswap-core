# MyToken
**Inherits:**
[ERC20](/src/ERC20.sol/contract.ERC20.md)


## State Variables
### owner

```solidity
address public owner;
```


## Functions
### constructor


```solidity
constructor(string memory name, string memory symbol, uint8 _decimals) ERC20(name, symbol, _decimals);
```

### mint


```solidity
function mint(address recipent, uint256 amount) external;
```

