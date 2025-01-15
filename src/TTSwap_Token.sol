// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {I_TTSwap_Market} from "./interfaces/I_TTSwap_Market.sol";
import {I_TTSwap_Token, s_share, s_proof} from "./interfaces/I_TTSwap_Token.sol";
import {L_TTSTokenConfigLibrary} from "./libraries/L_TTSTokenConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {toTTSwapUINT256, L_TTSwapUINT256Library, add, sub, mulDiv} from "./libraries/L_TTSwapUINT256.sol";

/**
 * @title TTS Token Contract
 * @dev Implements ERC20 token with additional staking and cross-chain functionality
 */
contract TTSwap_Token is ERC20Permit, I_TTSwap_Token {
    using L_TTSwapUINT256Library for uint256;
    using L_TTSTokenConfigLibrary for uint256;
    using L_CurrencyLibrary for address;
    uint256 public ttstokenconfig;

    mapping(uint32 => s_share) public shares; // all share's mapping

    uint256 public stakestate; // first 128 bit record lasttime,last 128 bit record poolvalue
    uint256 public poolstate; // first 128 bit record all asset(contain actual asset and constuct fee),last  128 bit record construct  fee

    mapping(uint256 => s_proof) public stakeproof;

    // mapping(uint32 => s_chain) public chains;

    /// @inheritdoc I_TTSwap_Token
    address public override normalgoodid;
    /// @inheritdoc I_TTSwap_Token
    address public override valuegoodid;
    /// @inheritdoc I_TTSwap_Token
    address public override dao_admin;
    /// @inheritdoc I_TTSwap_Token
    address public override marketcontract;
    uint32 public shares_index;
    //uint32 public chainindex;
    uint128 public left_share = 5 * 10 ** 8 * 10 ** 6;
    /// @inheritdoc I_TTSwap_Token
    uint128 public override publicsell;

    /// @inheritdoc I_TTSwap_Token
    mapping(address => address) public override referrals;

    // uint256 1:add referral priv 2: market priv
    /// @inheritdoc I_TTSwap_Token
    mapping(address => uint256) public override auths;

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
        stakestate = toTTSwapUINT256(uint128(block.timestamp), 0);
        dao_admin = _dao_admin;
        ttstokenconfig = _ttsconfig;
    }

    function setRatio(uint256 _ratio) external {
        require(_ratio <= 10000 && auths[msg.sender] == 2);
        ttstokenconfig = _ratio.setratio(ttstokenconfig);
        emit e_updatettsconfig(ttstokenconfig);
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
    /// @inheritdoc I_TTSwap_Token
    function setEnv(
        address _normalgoodid,
        address _valuegoodid,
        address _marketcontract
    ) external override {
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
    /// @inheritdoc I_TTSwap_Token
    function changeDAOAdmin(address _recipient) external override {
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
    /// @inheritdoc I_TTSwap_Token
    function addauths(address _auths, uint256 _priv) external override {
        require(_msgSender() == dao_admin);
        auths[_auths] = _priv;
        emit e_addauths(_auths, _priv);
    }

    /**
     * @dev Removes authorization from an address
     * @param _auths The address to remove authorization from
     * @notice Only the DAO admin can call this function
     */
    /// @inheritdoc I_TTSwap_Token
    function rmauths(address _auths) external override {
        require(_msgSender() == dao_admin);
        delete auths[_auths];
        emit e_rmauths(_auths);
    }

    /**
     * @dev Adds a new mint share to the contract
     * @param _share The share structure containing recipient, amount, metric, and chips
     * @notice Only callable on the main chain by the DAO admin
     * @notice Reduces the left_share by the amount in _share
     * @notice Increments the shares_index and adds the new share to the shares mapping
     * @notice Emits an e_addShare event with the share details
     */
    /// @inheritdoc I_TTSwap_Token
    function addShare(s_share calldata _share) external override onlymain {
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
    /// @inheritdoc I_TTSwap_Token
    function burnShare(uint8 index) external override onlymain {
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
    /// @inheritdoc I_TTSwap_Token
    function shareMint(uint8 index) external override onlymain {
        require(
            I_TTSwap_Market(marketcontract).ishigher(
                normalgoodid,
                valuegoodid,
                2 ** shares[index].metric * 2 ** 128 + 10
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
    /// @inheritdoc I_TTSwap_Token
    function addreferral(address user, address referral) external override {
        if (
            auths[msg.sender] == 1 &&
            referrals[user] == address(0) &&
            user != referral
        ) {
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
     * @dev Retrieves both the DAO admin address and the referrer address for a given customer
     * @param _customer The address of the customer
     * @return A tuple containing the DAO admin address and the customer's referrer address
     */
    /// @inheritdoc I_TTSwap_Token
    function getreferralanddaoadmin(
        address _customer
    ) external view override returns (address, address) {
        return (dao_admin, referrals[_customer]);
    }

    /**
     * @dev Perform public token sale
     * @param usdtamount Amount of USDT to spend on token purchase
     */
    /// @inheritdoc I_TTSwap_Token
    function publicSell(
        uint256 usdtamount,
        bytes memory data
    ) external onlymain {
        publicsell += uint128(usdtamount);
        require(publicsell <= 5000000 * decimals());
        usdt.transferFrom(msg.sender, address(this), usdtamount, data);
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

    /**
     * @dev Withdraws funds from public token sale
     * @param amount The amount of USDT to withdraw
     * @param recipient The address to receive the withdrawn funds
     * @notice Only callable on the main chain by the DAO admin
     * @notice Transfers the specified amount of USDT to the recipient
     */
    /// @inheritdoc I_TTSwap_Token
    function withdrawPublicSell(
        uint256 amount,
        address recipient
    ) external onlymain {
        require(_msgSender() == dao_admin);
        usdt.safeTransfer(recipient, amount);
    }

    /**
     * @dev Stake tokens
     * @param _staker Address of the staker
     * @param proofvalue Amount to stake
     * @return netconstruct Net construct value
     */
    /// @inheritdoc I_TTSwap_Token
    function stake(
        address _staker,
        uint128 proofvalue
    ) external override returns (uint128 netconstruct) {
        require(auths[msg.sender] == 1);
        _stakeFee();
        uint256 restakeid = uint256(keccak256(abi.encode(_staker, msg.sender)));
        netconstruct = poolstate.amount1() == 0
            ? 0
            : mulDiv(poolstate.amount1(), proofvalue, stakestate.amount1());
        poolstate = add(poolstate, toTTSwapUINT256(netconstruct, netconstruct));
        stakestate = add(stakestate, toTTSwapUINT256(0, proofvalue));
        stakeproof[restakeid].fromcontract = msg.sender;
        stakeproof[restakeid].proofstate = add(
            stakeproof[restakeid].proofstate,
            toTTSwapUINT256(proofvalue, netconstruct)
        );
    }

    /**
     * @dev Unstake tokens
     * @param _staker Address of the staker
     * @param proofvalue Amount to unstake
     */
    /// @inheritdoc I_TTSwap_Token
    function unstake(address _staker, uint128 proofvalue) external override {
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
            stakeproof[restakeid].proofstate = sub(
                stakeproof[restakeid].proofstate,
                toTTSwapUINT256(proofvalue, construct)
            );
        }
        profit = toTTSwapUINT256(poolstate.amount0(), stakestate.amount1())
            .getamount0fromamount1(proofvalue);
        stakestate = sub(stakestate, toTTSwapUINT256(0, proofvalue));
        poolstate = sub(poolstate, toTTSwapUINT256(profit, construct));
        profit = profit - construct;
        if (profit > 0) _mint(_staker, profit);
        emit e_unstake(
            _staker,
            stakeproof[restakeid].proofstate,
            toTTSwapUINT256(construct, profit),
            stakestate,
            poolstate
        );
    }
    /**
     * @dev Internal function to handle staking fees
     */
    function _stakeFee() internal {
        if (stakestate.amount0() + 86400 < block.timestamp) {
            stakestate = add(stakestate, toTTSwapUINT256(86400, 0));
            uint256 mintamount = totalSupply() > 50000000 * decimals()
                ? totalSupply() / 18300
                : 2739726027; //2739726027=(50000000 * decimals) / 18300
            poolstate = add(poolstate, ttstokenconfig.getratio(mintamount));

            emit e_updatepool(
                toTTSwapUINT256(stakestate.amount0(), poolstate.amount0())
            );
        }
    }
    // burn
    /**
     * @dev Burn tokens from an account
     * @param account Address of the account to burn tokens from
     * @param value Amount of tokens to burn
     */
    /// @inheritdoc I_TTSwap_Token
    function burn(address account, uint256 value) external override {
        _burn(account, value);
    }
}
