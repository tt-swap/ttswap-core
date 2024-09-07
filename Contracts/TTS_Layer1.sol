// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {I_MarketManage} from "./interfaces/I_Marketmanage.sol";
import {I_Proof} from "./interfaces/I_Proof.sol";
import {I_TTS} from "./interfaces/I_TTS.sol";
import {toBalanceUINT256, T_BalanceUINT256, L_BalanceUINT256Library, add, sub} from "./libraries/L_BalanceUINT256.sol";

contract TTS is ERC20Permit, I_TTS {
    using L_BalanceUINT256Library for T_BalanceUINT256;
    struct s_share {
        address recipent;
        uint256 leftamount;
        uint8 metric;
        uint8 chips;
    }
    mapping(uint8 => s_share) shares;
    uint8 shares_index;

    T_BalanceUINT256 stakestate; // 128 lasttime 128 poolvalue
    T_BalanceUINT256 poolstate;

    struct s_proof {
        address fromcontract;
        T_BalanceUINT256 proofstate;
    }
    mapping(uint256 => s_proof) stakeproof;

    struct s_chain {
        uint256 allasset;
        uint256 poolasset;
        uint256 poolvalue;
        uint256 poolcontruct;
        uint256 stakeid;
        address recipent;
    }
    mapping(uint256 => s_chain) chains;
    uint256 chainindex;

    uint256 internal normalgoodid;
    uint256 internal valuegoodid;
    address internal dao_admin;
    address internal marketcontract;

    mapping(address => address) referals;

    // uint256 1:添加推荐者 2:市场创建者
    mapping(address => uint256) auths;

    address public immutable usdt;
    // lsttime is for stake
    uint256 public publicsell;
    uint256 public left_share = 5 * 10 ** 8 * 10 ** 6;

    constructor(
        address _usdt,
        address _dao_admin
    ) ERC20Permit("TTSawp Token") ERC20("TTSawp Token", "TTS") {
        usdt = _usdt;
        stakestate = toBalanceUINT256(uint128(block.timestamp), 0);
        dao_admin = _dao_admin;
    }

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

    function changedaoadmin(address _recipent) external {
        require(_msgSender() == dao_admin);
        dao_admin = _recipent;
        emit e_setdaoadmin(dao_admin);
    }

    function addauths(address _auths, uint256 _priv) external {
        require(_msgSender() == dao_admin);
        auths[_auths] = _priv;
        emit e_addauths(_auths, _priv);
    }

    function rmauths(address _auths) external {
        require(_msgSender() == dao_admin);
        auths[_auths] = 0;
    }

    function isauths(address recipent) external view returns (uint256) {
        return auths[recipent];
    }

    function addMint(s_share calldata _share) public {
        require(
            left_share - _share.leftamount >= 0 && _msgSender() == dao_admin
        );
        left_share -= _share.leftamount;
        shares_index += 1;
        shares[shares_index] = _share;
        emit e_addmint(
            _share.recipent,
            _share.leftamount,
            _share.metric,
            _share.chips,
            shares_index
        );
    }

    function burnMint(uint8 index) public {
        require(_msgSender() == dao_admin);
        left_share += shares[index].leftamount;
        emit e_burnmint(index);
        delete shares[index];
    }

    function daoMint(uint8 index) public {
        require(
            I_MarketManage(marketcontract).ishigher(
                normalgoodid,
                valuegoodid,
                2 ** shares[index].metric * 2 ** 128 + 1
            ) ==
                false &&
                _msgSender() == shares[index].recipent
        );
        uint256 mintamount = shares[index].leftamount / shares[index].chips;
        shares[index].leftamount -= mintamount;
        shares[index].metric += 1;
        _mint(_msgSender(), mintamount);
        emit e_daomint(mintamount, index);
    }

    function addreferal(address user, address referal) external override {
        if (auths[msg.sender] == 1 && referals[user] == address(0)) {
            referals[user] = referal;
            emit e_addreferal(user, referal);
        }
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function getreferal(
        address _customer
    ) external view override returns (address) {
        return referals[_customer];
    }

    function getreferalanddaoamdin(
        address _customer
    ) external view override returns (address, address) {
        return (dao_admin, referals[_customer]);
    }

    //public sell
    function publicSell(uint256 usdtamount) external {
        publicsell += usdtamount;
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

    //

    function withdrawpublicsell(uint256 amount, address recipent) external {
        require(_msgSender() == dao_admin);
        IERC20(usdt).transfer(recipent, amount);
    }

    //

    // function synchainstake(
    //     uint256 chain,
    //     uint256 chainvalue
    // ) external returns (uint256 poolasset) {
    //     require(auths[msg.sender] == 100005);
    //     uint256 chaincontruct;
    //     if (chain == 0) {
    //         chainindex += 1;
    //         restakeid += 1;
    //         chain = chainindex;
    //         chaincontruct = (pool.poolasset * chainvalue) / pool.poolvalue;
    //         pool.poolasset += chaincontruct;
    //         pool.poolcontruct += chaincontruct;
    //         chains[chain].poolvalue = chainvalue;
    //         chains[chain].poolcontruct = chaincontruct;
    //         chains[chain].stakeid = restakeid;
    //         chains[chain].recipent = msg.sender;
    //     } else {
    //         poolasset =
    //             (pool.poolasset * chains[chain].poolvalue) /
    //             pool.poolcontruct;
    //         pool.poolasset -= poolasset;
    //         pool.poolcontruct -= chains[chain].poolcontruct;
    //         poolasset -= chains[chain].poolcontruct;
    //         chaincontruct = (pool.poolasset * chainvalue) / pool.poolvalue;
    //         pool.poolasset += chaincontruct;
    //         pool.poolcontruct += chaincontruct;
    //         chains[chain].poolvalue = chainvalue;
    //         chains[chain].poolcontruct = chaincontruct;
    //         chains[chain].allasset += poolasset;
    //         chains[chain].poolasset += poolasset;
    //         transfer(chains[chain].recipent, poolasset);
    //     }
    //     emit e_synchainstake(chain, chainvalue, chaincontruct, poolasset);
    // }

    // function chain_withdraw(uint256 chainid, uint256 asset) external {}

    // function chain_deposit(uint256 chainid, uint256 asset) external {}

    // function subchain_withdraw(uint256 asset, address recipent) external {}

    // function subchain_deposit(uint256 asset, address recipent) external {
    //     _mint(recipent, asset);
    // }

    function stake(address _staker, uint128 proofvalue) external {
        require(auths[msg.sender] == 1);
        _stakefee();
        uint256 restakeid = uint256(keccak256(abi.encode(_staker, msg.sender)));
        uint128 netcontruct = poolstate.amount1() == 0
            ? 0
            : toBalanceUINT256(poolstate.amount1(), stakestate.amount1())
                .getamount0fromamount1(proofvalue);
        poolstate = poolstate + toBalanceUINT256(netcontruct, netcontruct);
        stakestate = stakestate + toBalanceUINT256(0, proofvalue);
        stakeproof[restakeid].fromcontract = msg.sender;
        stakeproof[restakeid].proofstate =
            stakeproof[restakeid].proofstate +
            toBalanceUINT256(proofvalue, netcontruct);
    }

    function unstake(
        address _staker,
        uint128 proofvalue
    ) external returns (uint128 profit) {
        require(auths[msg.sender] == 1);
        _stakefee();
        uint256 restakeid = uint256(keccak256(abi.encode(_staker, msg.sender)));
        uint128 contruct;
        if (proofvalue >= stakeproof[restakeid].proofstate.amount0()) {
            proofvalue = stakeproof[restakeid].proofstate.amount0();
            contruct = stakeproof[restakeid].proofstate.amount1();
            delete stakeproof[restakeid];
        } else {
            contruct = stakeproof[restakeid].proofstate.getamount1fromamount0(
                proofvalue
            );
            stakeproof[restakeid].proofstate =
                stakeproof[restakeid].proofstate -
                toBalanceUINT256(proofvalue, contruct);
        }
        profit = toBalanceUINT256(poolstate.amount0(), stakestate.amount1())
            .getamount0fromamount1(proofvalue);
        stakestate = stakestate - toBalanceUINT256(0, proofvalue);
        poolstate = poolstate - toBalanceUINT256(profit, contruct);
        profit = profit - contruct;
        if (profit > 0) _mint(_staker, profit);
    }

    function _stakefee() internal {
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
    function burn(address account, uint256 value) external {
        _burn(account, value);
    }
}
