# L_Proof

## Functions
### updateInvest

*Represents the state of a proof*

*Updates the investment state of a proof*


```solidity
function updateInvest(
    S_ProofState storage _self,
    address _currenctgood,
    address _valuegood,
    uint256 _state,
    uint256 _invest,
    uint256 _valueinvest
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_ProofState`|The proof state to update|
|`_currenctgood`|`address`|The current good value|
|`_valuegood`|`address`|The value good|
|`_state`|`uint256`|amount0 (first 128 bits) represents total value|
|`_invest`|`uint256`|amount0 (first 128 bits) represents invest normal good quantity, amount1 (last 128 bits) represents normal good constuct fee when investing|
|`_valueinvest`|`uint256`|amount0 (first 128 bits) represents invest value good quantity, amount1 (last 128 bits) represents value good constuct fee when investing|


### burnProof

*Burns a portion of the proof*


```solidity
function burnProof(S_ProofState storage _self, uint128 _value) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_ProofState`|The proof state to update|
|`_value`|`uint128`|The amount to burn|


### collectProofFee

*Collects fees for the proof*


```solidity
function collectProofFee(S_ProofState storage _self, uint256 profit) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_ProofState`|The proof state to update|
|`profit`|`uint256`|The profit to add|


### conbine

*Combines two proof states*


```solidity
function conbine(S_ProofState storage _self, S_ProofState storage _get) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_self`|`S_ProofState`|The proof state to update|
|`_get`|`S_ProofState`|The proof state to combine with|


### stake

*Stakes a certain amount of proof value*


```solidity
function stake(address contractaddress, address to, uint128 proofvalue) internal returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`contractaddress`|`address`|The address of the staking contract|
|`to`|`address`|The address to stake for|
|`proofvalue`|`uint128`|The amount of proof value to stake|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|The staked amount|


### unstake

*Unstakes a certain amount of proof value*


```solidity
function unstake(address contractaddress, address from, uint128 divestvalue) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`contractaddress`|`address`|The address of the staking contract|
|`from`|`address`|The address to unstake from|
|`divestvalue`|`uint128`|The amount of proof value to unstake|


