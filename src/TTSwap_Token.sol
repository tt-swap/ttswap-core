// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {I_MarketManage} from "./interfaces/I_Marketmanage.sol";
import {I_Proof} from "./interfaces/I_Proof.sol";
import {I_TTS} from "./interfaces/I_TTS.sol";
import {L_TTSTokenConfigLibrary} from "./libraries/L_TTSTokenConfig.sol";
import {toBalanceUINT256, T_BalanceUINT256, L_BalanceUINT256Library, add, sub, mulDiv} from "./libraries/L_BalanceUINT256.sol";

/**
 * @title TTS Token Contract
 * @dev Implements ERC20 token with additional staking and cross-chain functionality
 */
contract TTS is ERC20Permit, I_TTS {
    using L_BalanceUINT256Library for T_BalanceUINT256;
    using L_TTSTokenConfigLibrary for uint256;
    uint256 public ttstokenconfig;

    struct s_share {
        address recipient; //owner
        uint128 leftamount; // unlock amount
        uint8 metric; //last unlock's metric
        uint8 chips; // define the share's chips, and every time unlock one chips
    }
    mapping(uint32 => s_share) shares; // all share's mapping

    T_BalanceUINT256 stakestate; // first 128 bit record lasttime,last 128 bit record poolvalue
    T_BalanceUINT256 poolstate; // first 128 bit record all asset(contain actual asset and constuct fee),last  128 bit record construct  fee

    struct s_proof {
        address fromcontract; // from which contract
        T_BalanceUINT256 proofstate; // stake's state
    }
    mapping(uint256 => s_proof) stakeproof;

    struct s_chain {
        T_BalanceUINT256 asset; //128 shareasset&poolasset 128 poolasset
        T_BalanceUINT256 proofstate; //128 value 128 constructasset
        address recipient;
    }
    mapping(uint32 => s_chain) chains;

    uint256 internal normalgoodid;
    uint256 internal valuegoodid;
    address internal dao_admin;
    address internal marketcontract;
    uint32 shares_index;
    uint32 chainindex;
    uint128 public left_share = 5 * 10 ** 8 * 10 ** 6;
    uint128 public publicsell;

    mapping(address => address) referrals;

    // uint256 1:add referral priv 2: market priv
    mapping(address => uint256) auths;

    address public immutable usdt;
    // lasttime is for stake

    /**
     * @dev Constructor to initialize the TTS token
     * @param _usdt Address of the USDT token contract
     * @param _dao_admin Address of the DAO admin
     * @param _ttsconfig Configuration for the TTS token
     */
    constructor(
        address _usdt,
        address _dao_admin,
        uint256 _ttsconfig
    ) ERC20Permit("TTSwap Token") ERC20("TTSwap Token", "TTS") {
        usdt = _usdt;
        stakestate = toBalanceUINT256(uint128(block.timestamp), 0);
        dao_admin = _dao_admin;
        ttstokenconfig = _ttsconfig;
    }

    /**
     * @dev Modifier to ensure function is only called on the main chain
     */
    modifier onlymain() {
        require(ttstokenconfig.ismain());
        _;
    }

    /**
     * @dev Modifier to ensure function is only called on sub-chains
     */
    modifier onlysub() {
        require(!ttstokenconfig.ismain());
        _;
    }

    /**
     * @dev Set environment variables for the contract
     * @param _normalgoodid ID for normal goods
     * @param _valuegoodid ID for value goods
     * @param _marketcontract Address of the market contract
     */
    function setEnv(
        uint256 _normalgoodid,
        uint256 _valuegoodid,
        address _marketcontract
    ) external {
        require(_msgSender() == dao_admin);
        normalgoodid = _normalgoodid;
        valuegoodid = _valuegoodid;
        marketcontract = _marketcontract;
        emit e_setenv(normalgoodid, valuegoodid, marketcontract);
    }

    /**
     * @dev Changes the DAO admin address
     * @param _recipient The address of the new DAO admin
     * @notice Only the current DAO admin can call this function
     */
    function changeDAOAdmin(address _recipient) external {
        require(_msgSender() == dao_admin);
        dao_admin = _recipient;
        emit e_setdaoadmin(dao_admin);
    }

    /**
     * @dev Adds or updates authorization for an address
     * @param _auths The address to authorize
     * @param _priv The privilege level to assign
     * @notice Only the DAO admin can call this function
     */
    function addauths(address _auths, uint256 _priv) external {
        require(_msgSender() == dao_admin);
        auths[_auths] = _priv;
        emit e_addauths(_auths, _priv);
    }

    /**
     * @dev Removes authorization from an address
     * @param _auths The address to remove authorization from
     * @notice Only the DAO admin can call this function
     */
    function rmauths(address _auths) external {
        require(_msgSender() == dao_admin);
        auths[_auths] = 0;
    }

    /**
     * @dev Checks the authorization level of an address
     * @param recipient The address to check
     * @return The authorization level of the address
     */
    function isauths(address recipient) external view returns (uint256) {
        return auths[recipient];
    }

    /**
     * @dev Adds a new mint share to the contract
     * @param _share The share structure containing recipient, amount, metric, and chips
     * @notice Only callable on the main chain by the DAO admin
     * @notice Reduces the left_share by the amount in _share
     * @notice Increments the shares_index and adds the new share to the shares mapping
     * @notice Emits an e_addShare event with the share details
     */
    function addShare(s_share calldata _share) public onlymain {
        require(
            left_share - _share.leftamount >= 0 && _msgSender() == dao_admin
        );
        left_share -= uint64(_share.leftamount);
        shares_index += 1;
        shares[shares_index] = _share;
        emit e_addShare(
            _share.recipient,
            _share.leftamount,
            _share.metric,
            _share.chips,
            shares_index
        );
    }

    /**
     * @dev Burns (removes) a mint share from the contract
     * @param index The index of the share to burn
     * @notice Only callable on the main chain by the DAO admin
     * @notice Adds the leftamount of the burned share back to left_share
     * @notice Emits an e_burnShare event and deletes the share from the shares mapping
     */
    function burnShare(uint8 index) public onlymain {
        require(_msgSender() == dao_admin);
        left_share += uint64(shares[index].leftamount);
        emit e_burnShare(index);
        delete shares[index];
    }

    /**
     * @dev Allows the DAO to mint tokens based on a specific share
     * @param index The index of the share to mint from
     * @notice Only callable on the main chain
     * @notice Requires the market price to be below a certain threshold
     * @notice Mints tokens to the share recipient, reduces leftamount, and increments metric
     * @notice Emits an e_daomint event with the minted amount and index
     */
    function shareMint(uint8 index) public onlymain {
        require(
            I_MarketManage(marketcontract).ishigher(
                normalgoodid,
                valuegoodid,
                2 ** shares[index].metric * 2 ** 128 + 1
            ) ==
                false &&
                _msgSender() == shares[index].recipient
        );
        uint128 mintamount = shares[index].leftamount / shares[index].chips;
        shares[index].leftamount -= mintamount;
        shares[index].metric += 1;
        _mint(_msgSender(), mintamount);
        emit e_shareMint(mintamount, index);
    }

    /**
     * @dev Adds a referral relationship between a user and a referrer
     * @param user The address of the user being referred
     * @param referral The address of the referrer
     * @notice Only callable by authorized addresses (auths[msg.sender] == 1)
     * @notice Will only set the referral if the user doesn't already have one
     */
    function addreferral(address user, address referral) external override {
        if (auths[msg.sender] == 1 && referrals[user] == address(0)) {
            referrals[user] = referral;
            emit e_addreferral(user, referral);
        }
    }

    /**
     * @dev Returns the number of decimals used to get its user representation
     * @return The number of decimals
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    /**
     * @dev Retrieves the referrer address for a given customer
     * @param _customer The address of the customer
     * @return The address of the customer's referrer
     */
    function getreferral(
        address _customer
    ) external view override returns (address) {
        return referrals[_customer];
    }

    /**
     * @dev Retrieves both the DAO admin address and the referrer address for a given customer
     * @param _customer The address of the customer
     * @return A tuple containing the DAO admin address and the customer's referrer address
     */
    function getreferralanddaoadmin(
        address _customer
    ) external view override returns (address, address) {
        return (dao_admin, referrals[_customer]);
    }

    /**
     * @dev Perform public token sale
     * @param usdtamount Amount of USDT to spend on token purchase
     */
    function publicSell(uint256 usdtamount) external onlymain {
        publicsell += uint128(usdtamount);
        require(publicsell <= 5000000 * decimals());
        if (IERC20(usdt).transferFrom(msg.sender, address(this), usdtamount)) {
            uint256 ttsamount;
            if (publicsell <= 1750000 * decimals()) {
                ttsamount = (usdtamount / 5) * 6;
                _mint(msg.sender, ttsamount);
            } else if (publicsell <= 3250000 * decimals()) {
                ttsamount = usdtamount;
                _mint(msg.sender, ttsamount);
            } else if (publicsell <= 5000000 * decimals()) {
                ttsamount = (usdtamount / 5) * 4;
                _mint(msg.sender, ttsamount);
            }
            emit e_publicsell(usdtamount, ttsamount);
        }
    }

    /**
     * @dev Withdraws funds from public token sale
     * @param amount The amount of USDT to withdraw
     * @param recipient The address to receive the withdrawn funds
     * @notice Only callable on the main chain by the DAO admin
     * @notice Transfers the specified amount of USDT to the recipient
     */
    function withdrawPublicSell(
        uint256 amount,
        address recipient
    ) external onlymain {
        require(_msgSender() == dao_admin);
        IERC20(usdt).transfer(recipient, amount);
    }

    /**
     * @dev Synchronize stake across chains
     * @param chainid ID of the chain
     * @param chainvalue Value to synchronize
     * @return poolasset Amount of pool asset
     */
    function syncChainStake(
        uint32 chainid,
        uint128 chainvalue
    ) external onlymain returns (uint128 poolasset) {
        require(
            auths[msg.sender] == 100005 &&
                (chains[chainid].recipient == msg.sender ||
                    chains[chainid].recipient == address(0))
        );
        uint128 chainconstruct;
        if (chainid == 0) {
            chainindex += 1;
            chainid = chainindex;
            chainconstruct = mulDiv(
                poolstate.amount0(),
                chainvalue,
                stakestate.amount1()
            );
            poolstate =
                poolstate +
                toBalanceUINT256(chainconstruct, chainconstruct);
            stakestate = stakestate + toBalanceUINT256(0, chainvalue);
            chains[chainid].proofstate = toBalanceUINT256(
                chainvalue,
                chainconstruct
            );
            chains[chainid].recipient = msg.sender;
        } else {
            poolasset = mulDiv(
                poolstate.amount0(),
                chains[chainid].proofstate.amount0(),
                poolstate.amount1()
            );

            poolstate =
                poolstate -
                toBalanceUINT256(
                    poolasset,
                    chains[chainid].proofstate.amount1()
                );
            stakestate =
                stakestate -
                toBalanceUINT256(0, chains[chainid].proofstate.amount0());
            poolasset = poolasset - chains[chainid].proofstate.amount0();
            chainconstruct = mulDiv(
                poolstate.amount0(),
                chainvalue,
                stakestate.amount1()
            );
            poolstate =
                poolstate +
                toBalanceUINT256(chainconstruct, chainconstruct);
            stakestate = stakestate + toBalanceUINT256(0, chainvalue);

            chains[chainid].proofstate = toBalanceUINT256(
                chainvalue,
                chainconstruct
            );
            chains[chainid].asset =
                chains[chainid].asset +
                toBalanceUINT256(poolasset, poolasset);
            _mint(chains[chainid].recipient, poolasset);
        }
        emit e_syncChainStake(chainid, chainvalue, chainconstruct, poolasset);
    }

    /**
     * @dev Synchronizes the pool asset on sub-chains
     * @param amount The amount to add to the pool state
     * @notice Only callable on sub-chains by authorized addresses (auths[msg.sender] == 5)
     */
    function syncPoolAsset(uint128 amount) external onlysub {
        require(auths[msg.sender] == 5);
        poolstate = poolstate + toBalanceUINT256(amount, 0);
    }

    /**
     * @dev Withdraws assets from a specific chain
     * @param chainid The ID of the chain to withdraw from
     * @param asset The amount of assets to withdraw
     * @notice Only callable on the main chain by authorized addresses (auths[msg.sender] == 100005)
     * @notice Requires the caller to be the recipient of the chain or the chain to have no recipient
     * @notice Updates the chain's asset balance and checks if the caller has sufficient balance
     */
    function chain_withdraw(uint32 chainid, uint128 asset) external onlymain {
        require(
            auths[msg.sender] == 100005 &&
                (chains[chainid].recipient == msg.sender ||
                    chains[chainid].recipient == address(0))
        );
        chains[chainid].asset =
            chains[chainid].asset +
            toBalanceUINT256(asset, 0);
        require(balanceOf(msg.sender) >= chains[chainid].asset.amount0());
    }

    /**
     * @dev Deposits assets to a specific chain
     * @param chainid The ID of the chain to deposit to
     * @param asset The amount of assets to deposit
     * @notice Only callable on the main chain by authorized addresses (auths[msg.sender] == 100005)
     * @notice Requires the caller to be the recipient of the chain or the chain to have no recipient
     * @notice Updates the chain's asset balance
     */
    function chain_deposit(uint32 chainid, uint128 asset) external onlymain {
        require(
            auths[msg.sender] == 100005 &&
                (chains[chainid].recipient == msg.sender ||
                    chains[chainid].recipient == address(0))
        );
        chains[chainid].asset =
            chains[chainid].asset -
            toBalanceUINT256(asset, 0);
    }

    /**
     * @dev Withdraws assets on a sub-chain
     * @param asset The amount of assets to withdraw
     * @param recipient The address to receive the withdrawn assets
     * @notice Only callable on sub-chains by authorized addresses (auths[msg.sender] == 100005)
     * @notice Requires the caller to be the recipient of the chain or the chain to have no recipient
     * @notice Updates the chain's asset balance and burns the withdrawn amount from the recipient
     */
    function subchainWithdraw(
        uint128 asset,
        address recipient
    ) external onlysub {
        require(auths[msg.sender] == 100005);
        _burn(recipient, asset);
    }

    /**
     * @dev Deposits assets on a sub-chain
     * @param asset The amount of assets to deposit
     * @param recipient The address to receive the deposited assets
     * @notice Only callable on sub-chains by authorized addresses (auths[msg.sender] == 100005)
     * @notice Requires the caller to be the recipient of the chain or the chain to have no recipient
     * @notice Updates the chain's asset balance and mints the deposited amount to the recipient
     */
    function subchainDeposit(
        uint128 asset,
        address recipient
    ) external onlysub {
        require(auths[msg.sender] == 100005);
        _mint(recipient, asset);
    }

    /**
     * @dev Stake tokens
     * @param _staker Address of the staker
     * @param proofvalue Amount to stake
     * @return netconstruct Net construct value
     */
    function stake(
        address _staker,
        uint128 proofvalue
    ) external returns (uint128 netconstruct) {
        require(auths[msg.sender] == 1);
        _stakeFee();
        uint256 restakeid = uint256(keccak256(abi.encode(_staker, msg.sender)));
        netconstruct = poolstate.amount1() == 0
            ? 0
            : mulDiv(poolstate.amount1(), proofvalue, stakestate.amount1());
        poolstate = poolstate + toBalanceUINT256(netconstruct, netconstruct);
        stakestate = stakestate + toBalanceUINT256(0, proofvalue);
        stakeproof[restakeid].fromcontract = msg.sender;
        stakeproof[restakeid].proofstate =
            stakeproof[restakeid].proofstate +
            toBalanceUINT256(proofvalue, netconstruct);
    }

    /**
     * @dev Unstake tokens
     * @param _staker Address of the staker
     * @param proofvalue Amount to unstake
     */
    function unstake(address _staker, uint128 proofvalue) external {
        require(auths[msg.sender] == 1);
        _stakeFee();
        uint128 profit;
        uint128 construct;
        uint256 restakeid = uint256(keccak256(abi.encode(_staker, msg.sender)));
        if (proofvalue >= stakeproof[restakeid].proofstate.amount0()) {
            proofvalue = stakeproof[restakeid].proofstate.amount0();
            construct = stakeproof[restakeid].proofstate.amount1();
            delete stakeproof[restakeid];
        } else {
            construct = stakeproof[restakeid].proofstate.getamount1fromamount0(
                proofvalue
            );
            stakeproof[restakeid].proofstate =
                stakeproof[restakeid].proofstate -
                toBalanceUINT256(proofvalue, construct);
        }
        profit = toBalanceUINT256(poolstate.amount0(), stakestate.amount1())
            .getamount0fromamount1(proofvalue);
        stakestate = stakestate - toBalanceUINT256(0, proofvalue);
        poolstate = poolstate - toBalanceUINT256(profit, construct);
        profit = profit - construct;
        if (profit > 0) _mint(_staker, profit);
        emit e_unstake(
            _staker,
            proofvalue,
            toBalanceUINT256(construct, profit),
            stakeproof[restakeid].proofstate
        );
    }

    /**
     * @dev Internal function to handle staking fees
     */
    function _stakeFee() internal {
        if (stakestate.amount0() + 86400 < block.timestamp) {
            stakestate = stakestate + toBalanceUINT256(86400, 0);
            uint256 mintamount = totalSupply() > 5000000 * decimals()
                ? totalSupply() / 18300
                : 274 * decimals(); //27322404=(500000 * decimals) / 18300
            poolstate = poolstate + toBalanceUINT256(uint128(mintamount), 0);
            emit e_updatepool(
                T_BalanceUINT256.unwrap(poolstate),
                T_BalanceUINT256.unwrap(stakestate)
            );
        }
    }
    // burn
    /**
     * @dev Burn tokens from an account
     * @param account Address of the account to burn tokens from
     * @param value Amount of tokens to burn
     */
    function burn(address account, uint256 value) external {
        _burn(account, value);
    }
}
