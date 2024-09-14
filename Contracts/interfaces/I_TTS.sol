// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";

/// @title 投资证明接口good's interface
/// @notice 包含商品的一系列接口  contain good's all interfaces
interface I_TTS {
    event e_addreferal(address users, address referal);
    event e_setenv(
        uint256 normalgoodid,
        uint256 valuegoodid,
        address marketcontract
    );

    event e_setdaoadmin(address recipent);

    event e_addauths(address auths, uint256 priv);

    event e_rmauths(address auths);
    event e_addmint(
        address recipent,
        uint256 leftamount,
        uint8 metric,
        uint8 chips,
        uint8 index
    );

    event e_burnmint(uint8 index);

    event e_daomint(uint256 mintamount, uint8 index);

    event e_publicsell(uint256 usdtamount, uint256 ttsamount);
    event e_synchainstake(
        uint256 chain,
        uint256 poolvalue,
        uint256 proolcontruct,
        uint256 poolasset
    );
    event e_stake(
        uint256 stakeid,
        address marketcontract,
        uint256 proofid,
        uint256 stakevalue,
        uint256 stakecontruct
    );

    event e_unstake(
        address recipent,
        uint128 proofvalue,
        T_BalanceUINT256 unstakestate,
        T_BalanceUINT256 stakestate
    );
    event e_updatepool(uint256 poolstate, uint256 stakestate);
    function getreferal(address _customer) external view returns (address);
    function addreferal(address user, address referal) external;
    function stake(
        address staker,
        uint128 proofvalue
    ) external returns (uint128 contruct);
    function unstake(address staker, uint128 proofvalue) external;
    function isauths(address recipent) external view returns (uint256);
    function getreferalanddaoamdin(
        address _customer
    ) external view returns (address dba_admin, address referal);
}
