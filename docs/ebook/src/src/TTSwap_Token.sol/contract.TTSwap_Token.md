# TTSwap_Token
**Inherits:**
ERC20Permit, [I_TTSwap_Token](/src/interfaces/I_TTSwap_Token.sol/interface.I_TTSwap_Token.md)

*Implements ERC20 token with additional staking and cross-chain functionality*


## State Variables
### ttstokenconfig

```solidity
uint256 public ttstokenconfig;
```


### shares

```solidity
mapping(uint32 => s_share) public shares;
```


### stakestate

```solidity
uint256 public stakestate;
```


### poolstate

```solidity
uint256 public poolstate;
```


### stakeproof

```solidity
mapping(uint256 => s_proof) public stakeproof;
```


### chains

```solidity
mapping(uint32 => s_chain) public chains;
```


### normalgoodid
*Returns the ID of the normal good*


```solidity
address public override normalgoodid;
```


### valuegoodid
*Returns the ID of the value good*


```solidity
address public override valuegoodid;
```


### dao_admin
*Returns the address of the DAO admin*


```solidity
address public override dao_admin;
```


### marketcontract
*Returns the address of the market contract*


```solidity
address public override marketcontract;
```


### shares_index

```solidity
uint32 public shares_index;
```


### chainindex

```solidity
uint32 public chainindex;
```


### left_share

```solidity
uint128 public left_share = 5 * 10 ** 8 * 10 ** 6;
```


### publicsell
*Returns the amount of TTS available for public sale*


```solidity
uint128 public override publicsell;
```


### referrals
*Returns the referrer address for a given user*


```solidity
mapping(address => address) public override referrals;
```


### auths
*Returns the authorization level for a given address*


```solidity
mapping(address => uint256) public override auths;
```


### usdt

```solidity
address public immutable usdt;
```


## Functions
### constructor

*Constructor to initialize the TTS token*


```solidity
constructor(address _usdt, address _dao_admin, uint256 _ttsconfig)
    ERC20Permit("TTSwap Token")
    ERC20("TTSwap Token", "TTS");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_usdt`|`address`|Address of the USDT token contract|
|`_dao_admin`|`address`|Address of the DAO admin|
|`_ttsconfig`|`uint256`|Configuration for the TTS token|


### onlymain

*Modifier to ensure function is only called on the main chain*


```solidity
modifier onlymain();
```

### onlysub

*Modifier to ensure function is only called on sub-chains*


```solidity
modifier onlysub();
```

### setEnv

*Set environment variables for the contract*


```solidity
function setEnv(address _normalgoodid, address _valuegoodid, address _marketcontract) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_normalgoodid`|`address`|ID for normal goods|
|`_valuegoodid`|`address`|ID for value goods|
|`_marketcontract`|`address`|Address of the market contract|


### changeDAOAdmin

Only the current DAO admin can call this function

*Changes the DAO admin address*


```solidity
function changeDAOAdmin(address _recipient) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the new DAO admin|


### addauths

Only the DAO admin can call this function

*Adds or updates authorization for an address*


```solidity
function addauths(address _auths, uint256 _priv) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_auths`|`address`|The address to authorize|
|`_priv`|`uint256`|The privilege level to assign|


### rmauths

Only the DAO admin can call this function

*Removes authorization from an address*


```solidity
function rmauths(address _auths) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_auths`|`address`|The address to remove authorization from|


### addShare

Only callable on the main chain by the DAO admin

Reduces the left_share by the amount in _share

Increments the shares_index and adds the new share to the shares mapping

Emits an e_addShare event with the share details

*Adds a new mint share to the contract*


```solidity
function addShare(s_share calldata _share) external override onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_share`|`s_share`|The share structure containing recipient, amount, metric, and chips|


### burnShare

Only callable on the main chain by the DAO admin

Adds the leftamount of the burned share back to left_share

Emits an e_burnShare event and deletes the share from the shares mapping

*Burns (removes) a mint share from the contract*


```solidity
function burnShare(uint8 index) external override onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint8`|The index of the share to burn|


### shareMint

Only callable on the main chain

Requires the market price to be below a certain threshold

Mints tokens to the share recipient, reduces leftamount, and increments metric

Emits an e_daomint event with the minted amount and index

*Allows the DAO to mint tokens based on a specific share*


```solidity
function shareMint(uint8 index) external override onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint8`|The index of the share to mint from|


### addreferral

Only callable by authorized addresses (auths[msg.sender] == 1)

Will only set the referral if the user doesn't already have one

*Adds a referral relationship between a user and a referrer*


```solidity
function addreferral(address user, address referral) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user being referred|
|`referral`|`address`|The address of the referrer|


### decimals

*Returns the number of decimals used to get its user representation*


```solidity
function decimals() public pure override returns (uint8);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|The number of decimals|


### getreferralanddaoadmin

Get the DAO admin and referral for a customer

*Retrieves both the DAO admin address and the referrer address for a given customer*


```solidity
function getreferralanddaoadmin(address _customer) external view override returns (address, address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_customer`|`address`|The address of the customer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|A tuple containing the DAO admin address and the customer's referrer address|
|`<none>`|`address`|dba_admin The address of the DAO admin|


### public_Sell

*Perform public token sale*


```solidity
function public_Sell(uint256 usdtamount) external onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`usdtamount`|`uint256`|Amount of USDT to spend on token purchase|


### withdrawPublicSell

Only callable on the main chain by the DAO admin

Transfers the specified amount of USDT to the recipient

*Withdraws funds from public token sale*


```solidity
function withdrawPublicSell(uint256 amount, address recipient) external onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of USDT to withdraw|
|`recipient`|`address`|The address to receive the withdrawn funds|


### syncChainStake

*Synchronize stake across chains*


```solidity
function syncChainStake(uint32 chainid, uint128 chainvalue) external override onlymain returns (uint128 poolasset);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`|ID of the chain|
|`chainvalue`|`uint128`|Value to synchronize|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`poolasset`|`uint128`|Amount of pool asset|


### syncPoolAsset

Only callable on sub-chains by authorized addresses (auths[msg.sender] == 5)

*Synchronizes the pool asset on sub-chains*


```solidity
function syncPoolAsset(uint128 amount) external override onlysub;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint128`|The amount to add to the pool state|


### chain_withdraw

Only callable on the main chain by authorized addresses (auths[msg.sender] == 6)

Requires the caller to be the recipient of the chain or the chain to have no recipient

Updates the chain's asset balance and checks if the caller has sufficient balance

*Withdraws assets from a specific chain*


```solidity
function chain_withdraw(uint32 chainid, uint128 asset) external override onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`|The ID of the chain to withdraw from|
|`asset`|`uint128`|The amount of assets to withdraw|


### chain_deposit

Only callable on the main chain by authorized addresses (auths[msg.sender] == 6)

Requires the caller to be the recipient of the chain or the chain to have no recipient

Updates the chain's asset balance

*Deposits assets to a specific chain*


```solidity
function chain_deposit(uint32 chainid, uint128 asset) external override onlymain;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`|The ID of the chain to deposit to|
|`asset`|`uint128`|The amount of assets to deposit|


### subchainWithdraw

Only callable on sub-chains by authorized addresses (auths[msg.sender] == 6)

Requires the caller to be the recipient of the chain or the chain to have no recipient

Updates the chain's asset balance and burns the withdrawn amount from the recipient

*Withdraws assets on a sub-chain*


```solidity
function subchainWithdraw(uint128 asset, address recipient) external override onlysub;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`uint128`|The amount of assets to withdraw|
|`recipient`|`address`|The address to receive the withdrawn assets|


### subchainDeposit

Only callable on sub-chains by authorized addresses (auths[msg.sender] == 6)

Requires the caller to be the recipient of the chain or the chain to have no recipient

Updates the chain's asset balance and mints the deposited amount to the recipient

*Deposits assets on a sub-chain*


```solidity
function subchainDeposit(uint128 asset, address recipient) external onlysub;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`uint128`|The amount of assets to deposit|
|`recipient`|`address`|The address to receive the deposited assets|


### stake

Stake tokens

*Stake tokens*


```solidity
function stake(address _staker, uint128 proofvalue) external override returns (uint128 netconstruct);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_staker`|`address`|Address of the staker|
|`proofvalue`|`uint128`|Amount to stake|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`netconstruct`|`uint128`|Net construct value|


### unstake

Unstake tokens

*Unstake tokens*


```solidity
function unstake(address _staker, uint128 proofvalue) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_staker`|`address`|Address of the staker|
|`proofvalue`|`uint128`|Amount to unstake|


### _stakeFee

*Internal function to handle staking fees*


```solidity
function _stakeFee() internal;
```

### burn

*Burn tokens from an account*


```solidity
function burn(address account, uint256 value) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address of the account to burn tokens from|
|`value`|`uint256`|Amount of tokens to burn|


