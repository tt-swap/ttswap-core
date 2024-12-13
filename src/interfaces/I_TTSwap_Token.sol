// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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
        address normalgoodid,
        address valuegoodid,
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
    /// @param proofvalue first 128 bit proofvalue,last 128 bit poolcontruct
    /// @param unstakestate The state after unstaking
    /// @param stakestate The state of the stake
    /// @param poolstate The state of the pool
    event e_unstake(
        address recipient,
        uint256 proofvalue,
        uint256 unstakestate,
        uint256 stakestate,
        uint256 poolstate
    );
    /// @notice Emitted when the pool state is updated
    /// @param poolstate The new state of the pool
    event e_updatepool(uint256 poolstate);
    /**
     * @dev  Returns the address of the DAO admin
     * @return _dao_admin Returns the address of the DAO admin
     */
    function dao_admin() external view returns (address _dao_admin);
    /**
     * @dev  Returns the address of the market contract
     * @return _marketcontract Returns the address of marketcontract
     */
    function marketcontract() external view returns (address _marketcontract);
    /**
     * @dev   Returns the ID of the normal good
     * @return _normalgoodid Returns the id of normalgood
     */
    function normalgoodid() external view returns (address _normalgoodid);
    /**
     * @dev   Returns the ID of the value good
     * @return _valuegoodid Returns the id of the valuegoodid
     */
    function valuegoodid() external view returns (address _valuegoodid);
    /**
     * @dev  Returns the amount of TTS available for public sale
     * @return _publicsell Returns the amount of TTS available for public sale
     */
    function publicsell() external view returns (uint128 _publicsell);
    /**
     * @dev  Returns the referrer address for a given user
     * @param _recipent user's address
     * @return _referral Returns the referrer address for a given user
     */
    function referrals(
        address _recipent
    ) external view returns (address _referral);
    /**
     * @dev Returns the authorization level for a given address
     * @param recipent user's address
     * @return _auth Returns the authorization level
     */
    function auths(address recipent) external view returns (uint256 _auth);
    function setEnv(
        address _normalgoodid,
        address _valuegoodid,
        address _marketcontract
    ) external; // Sets the environment variables for normal good ID, value good ID, and market contract address
    /**
     * @dev Changes the DAO admin to the specified recipient address
     * @param _recipient user's address
     */
    function changeDAOAdmin(address _recipient) external;
    /**
     * @dev Adds a new mint share to the contract
     * @param _share The share structure containing recipient, amount, metric, and chips
     * @notice Only callable on the main chain by the DAO admin
     * @notice Reduces the left_share by the amount in _share
     * @notice Increments the shares_index and adds the new share to the shares mapping
     * @notice Emits an e_addShare event with the share details
     */
    function addShare(s_share calldata _share) external;
    /**
     * @dev  Burns the share at the specified index
     * @param index index of share
     */
    function burnShare(uint8 index) external;
    /**
     * @dev  Mints a share at the specified index
     * @param index index of share
     */
    function shareMint(uint8 index) external;
    /**
     * @dev how much cost to buy tts
     * @param usdtamount usdt amount
     */
    function public_Sell(uint256 usdtamount, bytes memory data) external;
    /**
     * @dev  Withdraws the specified amount from the public sale to the recipient
     * @param amount admin tranfer public sell to another address
     * @param recipent user's address
     */
    function withdrawPublicSell(uint256 amount, address recipent) external;
    /**
     * @dev  Synchronizes the chain stake and returns the pool asset value
     * @param chainid  the chain's id
     * @param chainvalue the chain's stake value
     */
    function syncChainStake(
        uint32 chainid,
        uint128 chainvalue
    ) external returns (uint128 poolasset); //
    /**
     * @dev Synchronizes the pool asset with the specified amount to the subchain in stakepool
     * @param amount the  amount will be Synchronizes
     */
    function syncPoolAsset(uint128 amount) external; // Synchronizes the pool asset with the specified amount
    /**
     * @dev Withdraws the specified asset from the subchain to the recipient
     * @param chainid the subchain id
     * @param asset the asset amount will be withdraw
     */
    function chain_withdraw(uint32 chainid, uint128 asset) external; // Withdraws the specified asset from the given chain
    /**
     * @dev Deposit the specified asset from the subchain to the recipient
     * @param chainid the subchain id
     * @param asset the asset amount will be deposit
     */
    function chain_deposit(uint32 chainid, uint128 asset) external; // Deposits the specified asset to the given chain
    /**
     * @dev Withdraws the specified asset from the subchain to the recipient
     * @param asset the asset amount will be withdraw
     * @param recipient the asset owner
     */
    function subchainWithdraw(uint128 asset, address recipient) external;
    /**
     * @dev Deposits the specified asset to the subchain for the recipient
     * @param asset the asset amount will be deposit
     * @param recipient the receiver
     */
    function subchainDeposit(uint128 asset, address recipient) external; //
    /**
     * @dev Burns the specified value of tokens from the given account
     * @param account the given account
     * @param value the amount will be burned
     */
    function burn(address account, uint256 value) external;

    /**
     * @dev Adds or updates authorization for an address
     * @param _auths The address to authorize
     * @param _priv The privilege level to assign
     * @notice Only the DAO admin can call this function
     */
    function addauths(address _auths, uint256 _priv) external;
    /**
     * @dev Removes authorization from an address
     * @param _auths The address to remove authorization from
     * @notice Only the DAO admin can call this function
     */
    function rmauths(address _auths) external;
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
    uint256 proofstate; // stake's state  amount0 value 128 construct asset
}
