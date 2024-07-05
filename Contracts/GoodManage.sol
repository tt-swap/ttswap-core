// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./interfaces/I_Good.sol";

import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Good} from "./libraries/L_Good.sol";

import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {S_GoodKey} from "./libraries/L_Struct.sol";
import {L_ArrayStorage} from "./libraries/L_ArrayStorage.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "./libraries/L_BalanceUINT256.sol";

abstract contract GoodManage is I_Good {
    using L_CurrencyLibrary for address;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_Good for L_Good.S_GoodState;

    /// @inheritdoc I_Good
    uint256 public override marketconfig;
    /// @inheritdoc I_Good
    uint256 public override goodNum;
    /// @inheritdoc I_Good
    address public override marketcreator;

    mapping(bytes32 => L_Good.S_GoodState) internal goods;
    //mapping(bytes32 => uint256) public goodseq;
    uint256 internal locked;
    mapping(address => uint256) private banlist;

    constructor(address _marketcreator, uint256 _marketconfig) {
        marketcreator = _marketcreator;
        marketconfig = _marketconfig;
    }

    modifier onlyMarketCreator() {
        require(msg.sender == marketcreator, "G02");
        _;
    }

    modifier noReentrant() {
        require(locked == 0, "G01");
        locked = 1;
        _;
        locked = 0;
    }

    modifier noblacklist() {
        require(banlist[msg.sender] == 0);
        _;
    }

    function getGoodState(
        bytes32 goodkey
    ) external view returns (L_Good.S_GoodState memory gooddetail) {
        return goods[goodkey];
    }

    /// @inheritdoc I_Good
    function addbanlist(
        address _user
    ) external override onlyMarketCreator returns (bool) {
        banlist[_user] = 1;
        emit e_addbanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function removebanlist(
        address _user
    ) external override onlyMarketCreator returns (bool) {
        banlist[_user] = 0;
        emit e_removebanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyMarketCreator returns (bool) {
        require(_marketconfig.checkAllocate(), "G03");
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    function updateGoodConfig(
        bytes32 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner, "G04");
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updateGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_Good
    function updatetoValueGood(
        bytes32 _goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[_goodid].updateToValueGood();
        emit e_updatetoValueGood(_goodid);
        return true;
    }

    /// @inheritdoc I_Good
    function updatetoNormalGood(
        bytes32 _goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[_goodid].updateToNormalGood();
        emit e_updatetoNormalGood(_goodid);
        return true;
    }

    /// @inheritdoc I_Good
    function payGood(
        bytes32 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable returns (bool) {
        goods[_goodid].erc20address.safeTransfer(_recipent, _payquanity);
        return true;
    }

    /// @inheritdoc I_Good
    function changeGoodOwner(
        bytes32 _goodid,
        address _to
    ) external override returns (bool) {
        require(
            msg.sender == goods[_goodid].owner || msg.sender == marketcreator,
            "G05"
        );
        goods[_goodid].owner = _to;
        return true;
    }

    /// @inheritdoc I_Good
    function check_banlist(
        address _user
    ) external view override returns (bool _isban) {
        return banlist[_user] == 1 ? true : false;
    }

    function collectProtocolFee(
        bytes32 _goodid
    ) external override onlyMarketCreator returns (uint256 feeamount) {
        // goods[_goodid].remainfee = 0;
        goods[_goodid].erc20address.safeTransfer(msg.sender, feeamount);
    }

    function goodWelfare(
        bytes32 goodid,
        uint128 welfare
    ) external payable override noReentrant {
        require(
            goods[goodid].feeQunitityState.amount0() + welfare <= 2 ** 109,
            "G06"
        );
        goods[goodid].erc20address.transferFrom(msg.sender, welfare);
        goods[goodid].feeQunitityState =
            goods[goodid].feeQunitityState +
            toBalanceUINT256(uint128(welfare), 0);
    }
}
