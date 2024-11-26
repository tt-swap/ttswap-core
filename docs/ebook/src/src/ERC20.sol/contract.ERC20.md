# ERC20
**Inherits:**
Context, IERC20, IERC20Metadata


## State Variables
### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _allowances

```solidity
mapping(address => mapping(address => uint256)) private _allowances;
```


### _totalSupply

```solidity
uint256 private _totalSupply;
```


### _name

```solidity
string private _name;
```


### _symbol

```solidity
string private _symbol;
```


### _decimals

```solidity
uint8 private _decimals;
```


## Functions
### constructor


```solidity
constructor(string memory name_, string memory symbol_, uint8 decimals_);
```

### name


```solidity
function name() public view virtual override returns (string memory);
```

### symbol


```solidity
function symbol() public view virtual override returns (string memory);
```

### decimals


```solidity
function decimals() public view virtual override returns (uint8);
```

### totalSupply


```solidity
function totalSupply() public view virtual override returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address account) public view virtual override returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 amount) public virtual override returns (bool);
```

### allowance


```solidity
function allowance(address owner, address spender) public view virtual override returns (uint256);
```

### approve


```solidity
function approve(address spender, uint256 amount) public virtual override returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool);
```

### increaseAllowance


```solidity
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool);
```

### decreaseAllowance


```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool);
```

### _transfer


```solidity
function _transfer(address from, address to, uint256 amount) internal virtual;
```

### _mint


```solidity
function _mint(address account, uint256 amount) internal virtual;
```

### _burn


```solidity
function _burn(address account, uint256 amount) internal virtual;
```

### _approve


```solidity
function _approve(address owner, address spender, uint256 amount) internal virtual;
```

### _spendAllowance


```solidity
function _spendAllowance(address owner, address spender, uint256 amount) internal virtual;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual;
```

### _afterTokenTransfer


```solidity
function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual;
```

