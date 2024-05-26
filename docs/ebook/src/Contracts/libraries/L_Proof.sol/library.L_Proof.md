# L_Proof

## Functions
### updateInvest


```solidity
function updateInvest(
    S_ProofState storage _self,
    uint256 _currenctgood,
    uint256 _valuegood,
    T_BalanceUINT256 _state,
    T_BalanceUINT256 _invest,
    T_BalanceUINT256 _valueinvest
) internal;
```

### burnProof


```solidity
function burnProof(S_ProofState storage _self, uint128 _value) internal;
```

### mulDiv


```solidity
function mulDiv(uint256 config, uint256 amount, uint256 domitor) internal pure returns (uint128 a);
```

### _approve


```solidity
function _approve(S_ProofState storage _self, address to) internal;
```

### collectProofFee


```solidity
function collectProofFee(S_ProofState storage _self, T_BalanceUINT256 profit) internal;
```

## Structs
### S_ProofState

```solidity
struct S_ProofState {
    address owner;
    uint256 currentgood;
    uint256 valuegood;
    T_BalanceUINT256 state;
    T_BalanceUINT256 invest;
    T_BalanceUINT256 valueinvest;
    address approval;
    address beneficiary;
}
```

