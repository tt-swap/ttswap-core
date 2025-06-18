// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_Token {
    /// @notice Emitted when a referral is added
    /// @param users The address of the user
    /// @param referral The address of the referrer
    event e_addreferral(address users, address referral);

    /// @notice Emitted when environment variables are set
    /// @param marketcontract The address of the market contract
    event e_setenv(address marketcontract);

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
    event e_addShare(address recipient, uint128 leftamount, uint120 metric, uint8 chips);

    /// @notice Emitted when minting is burned
    /// @param owner The index of the minting operation being burned
    event e_burnShare(address owner);

    /// @notice Emitted when DAO minting occurs
    /// @param mintamount The amount being minted
    /// @param owner The index of the minting operation
    event e_shareMint(uint128 mintamount, address owner);

    /// @notice Emitted during a public sale
    /// @param usdtamount The amount of USDT involved
    /// @param ttsamount The amount of TTS involved
    event e_publicsell(uint256 usdtamount, uint256 ttsamount);

    /// @notice Emitted when chain stake is synchronized
    /// @param chain The chain ID
    /// @param poolasset The pool asset value
    /// @param proofstate  The value of the pool
    //first 128 bit proofvalue,last 128 bit proofconstruct
    event e_syncChainStake(uint32 chain, uint128 poolasset, uint256 proofstate);

    /// @notice Emitted when unstaking occurs
    /// @param recipient The address receiving the unstaked tokens
    /// @param proofvalue first 128 bit proofvalue,last 128 bit poolcontruct
    /// @param unstakestate The state after unstaking
    /// @param stakestate The state of the stake
    /// @param poolstate The state of the pool
    event e_stakeinfo(
        address recipient, uint256 proofvalue, uint256 unstakestate, uint256 stakestate, uint256 poolstate
    );
    /// @notice Emitted when the pool state is updated
    /// @param poolstate The new state of the pool
    event e_updatepool(uint256 poolstate);
    /// @notice Emitted when the pool state is updated
    /// @param ttsconfig The new state of the pool
    event e_updatettsconfig(uint256 ttsconfig);

    function setRatio(uint256 _ratio) external;

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
    function referrals(address _recipent) external view returns (address _referral);
    /**
     * @dev Returns the authorization level for a given address
     * @param recipent user's address
     * @return _auth Returns the authorization level
     */
    function auths(address recipent) external view returns (uint256 _auth);
    function setEnv(address _marketcontract) external; // Sets the environment variables for normal good ID, value good ID, and market contract address
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
    function addShare(s_share calldata _share, address owner) external;
    /**
     * @dev  Burns the share at the specified index
     * @param owner owner of share
     */
    function burnShare(address owner) external;
    /**
     * @dev  Mints a share at the specified
     */
    function shareMint() external;
    /**
     * @dev how much cost to buy tts
     * @param usdtamount usdt amount
     */
    function publicSell(uint256 usdtamount, bytes calldata data) external;
    /**
     * @dev  Withdraws the specified amount from the public sale to the recipient
     * @param amount admin tranfer public sell to another address
     * @param recipent user's address
     */
    function withdrawPublicSell(uint256 amount, address recipent) external;

    /**
     * @dev Burns the specified value of tokens from the given account
     * @param value the amount will be burned
     */
    function burn( uint256 value) external;
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
    function stake(address staker, uint128 proofvalue) external returns (uint128 construct);

    /// @notice Unstake tokens
    /// @param staker The address of the staker
    /// @param proofvalue The proof value for unstaking
    function unstake(address staker, uint128 proofvalue) external;

    /// @notice Get the DAO admin and referral for a customer
    /// @param _customer The address of the customer
    /// @return dba_admin The address of the DAO admin
    /// @return referral The address of the referrer
    function getreferralanddaoadmin(address _customer) external view returns (address dba_admin, address referral);

    function permitShare(s_share memory _share, uint128 dealline, bytes calldata signature) external;

    function shareHash(s_share memory _share, address owner, uint128 leftamount, uint128 deadline, uint256 nonce)
        external
        pure
        returns (bytes32);
}

struct s_share {
    uint128 leftamount; // unlock amount
    uint120 metric; //last unlock's metric
    uint8 chips; // define the share's chips, and every time unlock one chips
}

struct s_proof {
    address fromcontract; // from which contract
    uint256 proofstate; // stake's state  amount0 value 128 construct asset
}
