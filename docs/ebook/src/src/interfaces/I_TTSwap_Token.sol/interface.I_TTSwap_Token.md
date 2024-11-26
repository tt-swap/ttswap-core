# I_TTSwap_Token
Contains a series of interfaces for goods


## Functions
### dao_admin

*Returns the address of the DAO admin*


```solidity
function dao_admin() external view returns (address _dao_admin);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_dao_admin`|`address`|Returns the address of the DAO admin|


### marketcontract

*Returns the address of the market contract*


```solidity
function marketcontract() external view returns (address _marketcontract);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_marketcontract`|`address`|Returns the address of marketcontract|


### normalgoodid

*Returns the ID of the normal good*


```solidity
function normalgoodid() external view returns (address _normalgoodid);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_normalgoodid`|`address`|Returns the id of normalgood|


### valuegoodid

*Returns the ID of the value good*


```solidity
function valuegoodid() external view returns (address _valuegoodid);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_valuegoodid`|`address`|Returns the id of the valuegoodid|


### publicsell

*Returns the amount of TTS available for public sale*


```solidity
function publicsell() external view returns (uint128 _publicsell);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_publicsell`|`uint128`|Returns the amount of TTS available for public sale|


### referrals

*Returns the referrer address for a given user*


```solidity
function referrals(address _recipent) external view returns (address _referral);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipent`|`address`|user's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_referral`|`address`|Returns the referrer address for a given user|


### auths

*Returns the authorization level for a given address*


```solidity
function auths(address recipent) external view returns (uint256 _auth);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipent`|`address`|user's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_auth`|`uint256`|Returns the authorization level|


### setEnv


```solidity
function setEnv(address _normalgoodid, address _valuegoodid, address _marketcontract) external;
```

### changeDAOAdmin

*Changes the DAO admin to the specified recipient address*


```solidity
function changeDAOAdmin(address _recipient) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|user's address|


### addShare

Only callable on the main chain by the DAO admin

Reduces the left_share by the amount in _share

Increments the shares_index and adds the new share to the shares mapping

Emits an e_addShare event with the share details

*Adds a new mint share to the contract*


```solidity
function addShare(s_share calldata _share) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_share`|`s_share`|The share structure containing recipient, amount, metric, and chips|


### burnShare

*Burns the share at the specified index*


```solidity
function burnShare(uint8 index) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint8`|index of share|


### shareMint

*Mints a share at the specified index*


```solidity
function shareMint(uint8 index) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint8`|index of share|


### public_Sell

*how much cost to buy tts*


```solidity
function public_Sell(uint256 usdtamount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`usdtamount`|`uint256`|usdt amount|


### withdrawPublicSell

*Withdraws the specified amount from the public sale to the recipient*


```solidity
function withdrawPublicSell(uint256 amount, address recipent) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|admin tranfer public sell to another address|
|`recipent`|`address`|user's address|


### syncChainStake

*Synchronizes the chain stake and returns the pool asset value*


```solidity
function syncChainStake(uint32 chainid, uint128 chainvalue) external returns (uint128 poolasset);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`| the chain's id|
|`chainvalue`|`uint128`|the chain's stake value|


### syncPoolAsset

*Synchronizes the pool asset with the specified amount to the subchain in stakepool*


```solidity
function syncPoolAsset(uint128 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint128`|the  amount will be Synchronizes|


### chain_withdraw

*Withdraws the specified asset from the subchain to the recipient*


```solidity
function chain_withdraw(uint32 chainid, uint128 asset) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`|the subchain id|
|`asset`|`uint128`|the asset amount will be withdraw|


### chain_deposit

*Deposit the specified asset from the subchain to the recipient*


```solidity
function chain_deposit(uint32 chainid, uint128 asset) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainid`|`uint32`|the subchain id|
|`asset`|`uint128`|the asset amount will be deposit|


### subchainWithdraw

*Withdraws the specified asset from the subchain to the recipient*


```solidity
function subchainWithdraw(uint128 asset, address recipient) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`uint128`|the asset amount will be withdraw|
|`recipient`|`address`|the asset owner|


### subchainDeposit

*Deposits the specified asset to the subchain for the recipient*


```solidity
function subchainDeposit(uint128 asset, address recipient) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`uint128`|the asset amount will be deposit|
|`recipient`|`address`|the receiver|


### burn

*Burns the specified value of tokens from the given account*


```solidity
function burn(address account, uint256 value) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|the given account|
|`value`|`uint256`|the amount will be burned|


### addauths

Only the DAO admin can call this function

*Adds or updates authorization for an address*


```solidity
function addauths(address _auths, uint256 _priv) external;
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
function rmauths(address _auths) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_auths`|`address`|The address to remove authorization from|


### addreferral

Add a referral relationship


```solidity
function addreferral(address user, address referral) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user being referred|
|`referral`|`address`|The address of the referrer|


### stake

Stake tokens


```solidity
function stake(address staker, uint128 proofvalue) external returns (uint128 construct);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|
|`proofvalue`|`uint128`|The proof value for the stake|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`construct`|`uint128`|The construct value after staking|


### unstake

Unstake tokens


```solidity
function unstake(address staker, uint128 proofvalue) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|
|`proofvalue`|`uint128`|The proof value for unstaking|


### getreferralanddaoadmin

Get the DAO admin and referral for a customer


```solidity
function getreferralanddaoadmin(address _customer) external view returns (address dba_admin, address referral);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_customer`|`address`|The address of the customer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dba_admin`|`address`|The address of the DAO admin|
|`referral`|`address`|The address of the referrer|


## Events
### e_addreferral
Emitted when a referral is added


```solidity
event e_addreferral(address users, address referral);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`users`|`address`|The address of the user|
|`referral`|`address`|The address of the referrer|

### e_setenv
Emitted when environment variables are set


```solidity
event e_setenv(address normalgoodid, address valuegoodid, address marketcontract);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`normalgoodid`|`address`|The ID of the normal good|
|`valuegoodid`|`address`|The ID of the value good|
|`marketcontract`|`address`|The address of the market contract|

### e_setdaoadmin
Emitted when a DAO admin is set


```solidity
event e_setdaoadmin(address recipient);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the new DAO admin|

### e_addauths
Emitted when authorizations are added


```solidity
event e_addauths(address auths, uint256 priv);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`auths`|`address`|The address being authorized|
|`priv`|`uint256`|The privilege level being granted|

### e_rmauths
Emitted when authorizations are removed


```solidity
event e_rmauths(address auths);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`auths`|`address`|The address being deauthorized|

### e_addShare
Emitted when minting is added


```solidity
event e_addShare(address recipient, uint256 leftamount, uint120 metric, uint8 chips, uint32 index);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address receiving the minted tokens|
|`leftamount`|`uint256`|The remaining amount to be minted|
|`metric`|`uint120`|The metric used for minting|
|`chips`|`uint8`|The number of chips|
|`index`|`uint32`|The index of the minting operation|

### e_burnShare
Emitted when minting is burned


```solidity
event e_burnShare(uint32 index);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint32`|The index of the minting operation being burned|

### e_shareMint
Emitted when DAO minting occurs


```solidity
event e_shareMint(uint128 mintamount, uint32 index);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`mintamount`|`uint128`|The amount being minted|
|`index`|`uint32`|The index of the minting operation|

### e_publicsell
Emitted during a public sale


```solidity
event e_publicsell(uint256 usdtamount, uint256 ttsamount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`usdtamount`|`uint256`|The amount of USDT involved|
|`ttsamount`|`uint256`|The amount of TTS involved|

### e_syncChainStake
Emitted when chain stake is synchronized


```solidity
event e_syncChainStake(uint32 chain, uint128 poolasset, uint256 proofstate);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chain`|`uint32`|The chain ID|
|`poolasset`|`uint128`|The pool asset value|
|`proofstate`|`uint256`| The value of the pool|

### e_unstake
Emitted when unstaking occurs


```solidity
event e_unstake(address recipient, uint256 proofvalue, uint256 unstakestate, uint256 stakestate, uint256 poolstate);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address receiving the unstaked tokens|
|`proofvalue`|`uint256`|first 128 bit proofvalue,last 128 bit poolcontruct|
|`unstakestate`|`uint256`|The state after unstaking|
|`stakestate`|`uint256`|The state of the stake|
|`poolstate`|`uint256`|The state of the pool|

### e_updatepool
Emitted when the pool state is updated


```solidity
event e_updatepool(uint256 poolstate);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolstate`|`uint256`|The new state of the pool|

