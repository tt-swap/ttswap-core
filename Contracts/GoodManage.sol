// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./RefererManage.sol";
import "./interfaces/I_Good.sol";

import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Good} from "./libraries/L_Good.sol";

import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {S_GoodKey} from "./libraries/L_Struct.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "./libraries/L_BalanceUINT256.sol";
import {SafeCast} from "./libraries/SafeCast.sol";

abstract contract GoodManage is I_Good, RefererManage {
    using L_CurrencyLibrary for address;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using SafeCast for *;
    using L_Good for L_Good.S_GoodState;

    uint256 public override marketconfig;
    uint256 public goodnum;
    mapping(uint256 => L_Good.S_GoodState) public goods;
    mapping(address => uint256[]) public _ownergoods;
    mapping(bytes32 => uint256) public goodseq;
    uint256 internal locked;
    address public immutable marketcreator;

    constructor(address _marketcreator, uint256 _marketconfig) {
        marketcreator = _marketcreator;
        marketconfig = _marketconfig;
        emit e_initMarket(_marketcreator, _marketconfig);
    }

    modifier onlyMarketCreator() {
        require(msg.sender == marketcreator, "1");
        _;
    }

    modifier noReentrant() {
        require(locked == 0, "No re-entrancy!");
        locked = 1;
        _;
        locked = 0;
    }

    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyMarketCreator returns (bool) {
        require(_marketconfig.checkAllocate(), "sum should 100");
        marketconfig = _marketconfig;
        return true;
    }

    function getGoodIdByAddress(
        address _owner
    ) external view returns (uint256[] memory) {
        return _ownergoods[_owner];
    }

    function getGoodState(
        uint256 _goodid
    ) external view override returns (L_Good.S_GoodTmpState memory good_) {
        good_.currentState = goods[_goodid].currentState;
        good_.investState = goods[_goodid].investState;
        good_.feeQunitityState = goods[_goodid].feeQunitityState;
        good_.goodConfig = goods[_goodid].goodConfig;
        good_.owner = goods[_goodid].owner;
        good_.erc20address = goods[_goodid].erc20address;
    }

    function getGoodsFee(
        uint256 _goodid,
        address user
    ) external view returns (uint256) {
        return goods[_goodid].fees[user];
    }

    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner, "");
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updategoodconfig(
            _goodid,
            goods[_goodid].goodConfig,
            _goodConfig
        );
        return true;
    }

    function updatetoValueGood(
        uint256 goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[goodid].updateToValueGood();
        emit e_updateGood(goodid, 1);
        return true;
    }

    function updatetoNormalGood(
        uint256 goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[goodid].updateToNormalGood();
        emit e_updateGood(goodid, 0);
        return true;
    }

    function payGood(
        uint256 goodid,
        uint256 payquanity,
        address recipent
    ) external returns (bool) {
        goods[goodid].erc20address.transferFrom(recipent, payquanity);
        return true;
    }

    function changeOwner(
        uint256 goodid,
        address to
    ) external override returns (bool) {
        require(
            msg.sender == goods[goodid].owner || msg.sender == marketcreator,
            "you havn't priv"
        );
        emit e_changeOwner(goodid, goods[goodid].owner, to);
        goods[goodid].owner = to;
        _ownergoods[to].push(goodid);
        return true;
    }

    function collectProtocolFee(
        uint256 goodid
    ) external payable override returns (uint256) {
        uint256 fee = goods[goodid].fees[msg.sender].toUInt128();
        require(fee > 0, "no fee");
        goods[goodid].fees[msg.sender] = 0;
        uint256 protocol = marketconfig.getPlatFee256(fee);
        emit e_collectProtocolFee(goodid, msg.sender, protocol);
        goods[goodid].fees[marketcreator] += protocol;
        goods[goodid].erc20address.transfer(msg.sender, fee - protocol);
        return fee;
    }
}
