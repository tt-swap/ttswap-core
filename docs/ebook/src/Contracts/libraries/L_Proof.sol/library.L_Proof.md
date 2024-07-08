# L_Proof

## Functions
### updateInvest


```solidity
function updateInvest(
    S_ProofState storage _self,
    bytes32 _currenctgood,
    bytes32 _valuegood,
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

### collectProofFee


```solidity
function collectProofFee(S_ProofState storage _self, T_BalanceUINT256 profit) internal;
```

### conbine


```solidity
function conbine(S_ProofState storage _self, S_ProofState storage _get) internal;
```

## Structs
### S_ProofState

```solidity
struct S_ProofState {
    bytes32 currentgood;
    bytes32 valuegood;
    T_BalanceUINT256 state;
    T_BalanceUINT256 invest;
    T_BalanceUINT256 valueinvest;
    address beneficiary;
}
```

