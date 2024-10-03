// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC721Permit} from "./IERC721Permit.sol";

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_Token {
    /// @notice Emitted when a referral is added
    /// @param users The address of the user
    /// @param referral The address of the referrer
    event e_addreferral(address users, address referral);

    /// @notice Emitted when environment variables are set
    /// @param normalgoodid The ID of the normal good
    /// @param valuegoodid The ID of the value good
    /// @param marketcontract The address of the market contract
    event e_setenv(
        uint256 normalgoodid,
        uint256 valuegoodid,
        address marketcontract
    );

    /// @notice Emitted when a DAO admin is set
    /// @param recipient The address of the new DAO admin
    event e_setdaoadmin(address recipient);

    /// @notice Emitted when authorizations are added
    /// @param auths The address being authorized
    /// @param priv The privilege level being granted
    event e_addauths(address auths, uint256 priv);

    /// @notice Emitted when authorizations are removed
    /// @param auths The address being deauthorized
    event e_rmauths(address auths);

    /// @notice Emitted when minting is added
    /// @param recipient The address receiving the minted tokens
    /// @param leftamount The remaining amount to be minted
    /// @param metric The metric used for minting
    /// @param chips The number of chips
    /// @param index The index of the minting operation
    event e_addShare(
        address recipient,
        uint256 leftamount,
        uint120 metric,
        uint8 chips,
        uint32 index
    );

    /// @notice Emitted when minting is burned
    /// @param index The index of the minting operation being burned
    event e_burnShare(uint32 index);

    /// @notice Emitted when DAO minting occurs
    /// @param mintamount The amount being minted
    /// @param index The index of the minting operation
    event e_shareMint(uint128 mintamount, uint32 index);

    /// @notice Emitted during a public sale
    /// @param usdtamount The amount of USDT involved
    /// @param ttsamount The amount of TTS involved
    event e_publicsell(uint256 usdtamount, uint256 ttsamount);

    /// @notice Emitted when chain stake is synchronized
    /// @param chain The chain ID
    /// @param poolasset The pool asset value
    /// @param proofstate  The value of the pool
    event e_syncChainStake(
        uint32 chain,
        uint128 poolasset,
        uint256 proofstate //first 128 bit proofvalue,last 128 bit proofconstruct
    );

    /// @notice Emitted when unstaking occurs
    /// @param recipient The address receiving the unstaked tokens
    /// @param proofvalue The proof value
    /// @param unstakestate The state after unstaking
    /// @param stakestate The state of the stake
    event e_unstake(
        address recipient,
        uint128 proofvalue,
        uint256 unstakestate,
        uint256 stakestate
    );
    /// @notice Emitted when the pool state is updated
    /// @param poolstate The new state of the pool
    /// @param stakestate The new state of the stake
    event e_updatepool(uint256 poolstate, uint256 stakestate);

    function dao_admin() external view returns (address);
    function marketcontract() external view returns (address);
    function normalgoodid() external view returns (uint256);
    function valuegoodid() external view returns (uint256);
    function publicsell() external view returns (uint128);
    function referrals(address) external view returns (address);
    function auths(address) external view returns (uint256);
    function setEnv(
        uint256 _normalgoodid,
        uint256 _valuegoodid,
        address _marketcontract
    ) external;
    function changeDAOAdmin(address _recipient) external;
    function burnShare(uint8 index) external;
    function shareMint(uint8 index) external;
    function publicSell(uint256 usdtamount) external;
    function withdrawPublicSell(uint256 amount, address recipient) external;
    function syncChainStake(
        uint32 chainid,
        uint128 chainvalue
    ) external returns (uint128 poolasset);
    function syncPoolAsset(uint128 amount) external;
    function chain_withdraw(uint32 chainid, uint128 asset) external;
    function chain_deposit(uint32 chainid, uint128 asset) external;
    function subchainWithdraw(uint128 asset, address recipient) external;
    function subchainDeposit(uint128 asset, address recipient) external;
    function burn(address account, uint256 value) external;
    /**
     * @dev Adds or updates authorization for an address
     * @param _auths The address to authorize
     * @param _priv The privilege level to assign
     * @notice Only the DAO admin can call this function
     */
    function addauths(address _auths, uint256 _priv) external;

    /// @notice Add a referral relationship
    /// @param user The address of the user being referred
    /// @param referral The address of the referrer
    function addreferral(address user, address referral) external;

    /// @notice Stake tokens
    /// @param staker The address of the staker
    /// @param proofvalue The proof value for the stake
    /// @return construct The construct value after staking
    function stake(
        address staker,
        uint128 proofvalue
    ) external returns (uint128 construct);

    /// @notice Unstake tokens
    /// @param staker The address of the staker
    /// @param proofvalue The proof value for unstaking
    function unstake(address staker, uint128 proofvalue) external;

    /// @notice Get the DAO admin and referral for a customer
    /// @param _customer The address of the customer
    /// @return dba_admin The address of the DAO admin
    /// @return referral The address of the referrer
    function getreferralanddaoadmin(
        address _customer
    ) external view returns (address dba_admin, address referral);

    function setMainTriggerMarket(
        address Maintriggeradd,
        address marketadd
    ) external;
}
struct s_share {
    address recipient; //owner
    uint128 leftamount; // unlock amount
    uint120 metric; //last unlock's metric
    uint8 chips; // define the share's chips, and every time unlock one chips
}

struct s_chain {
    uint256 asset; //128 shareasset&poolasset 128 poolasset
    uint256 proofstate; //128 value 128 constructasset
    address recipient;
}
struct s_proof {
    address fromcontract; // from which contract
    uint256 proofstate; // stake's state
}
