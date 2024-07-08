// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./interfaces/I_Good.sol";

import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Good} from "./libraries/L_Good.sol";

import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {S_GoodKey} from "./libraries/L_Struct.sol";
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

    mapping(uint256 => L_Good.S_GoodState) internal goods;
    uint256 internal locked;
    mapping(address => uint256) public banlist;
    mapping(address => address) public referals;

    constructor(address _marketcreator, uint256 _marketconfig) {
        marketcreator = _marketcreator;
        marketconfig = _marketconfig;
    }

    modifier noReentrant() {
        require(locked == 0, "G01");
        locked = 1;
        _;
        locked = 0;
    }

    function getGoodState(
        uint256 goodkey
    ) external view returns (L_Good.S_GoodTmpState memory gooddetail) {
        gooddetail.goodConfig = goods[goodkey].goodConfig;
        gooddetail.owner = goods[goodkey].owner;
        gooddetail.erc20address = goods[goodkey].erc20address;
        gooddetail.currentState = goods[goodkey].currentState;
        gooddetail.investState = goods[goodkey].investState;
        gooddetail.feeQunitityState = goods[goodkey].feeQunitityState;
    }

    /// @inheritdoc I_Good
    function addbanlist(address _user) external override returns (bool) {
        require(msg.sender == marketcreator, "G02");
        banlist[_user] = 1;
        emit e_addbanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function removebanlist(address _user) external override returns (bool) {
        require(msg.sender == marketcreator, "G02");
        banlist[_user] = 0;
        emit e_removebanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function setMarketConfig(
        uint256 _marketconfig
    ) external override returns (bool) {
        require(msg.sender == marketcreator, "G02");
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner, "G04");
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updateGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_Good
    function updatetoValueGood(
        uint256 _goodid
    ) external override returns (bool) {
        require(msg.sender == marketcreator, "G02");
        goods[_goodid].updateToValueGood();
        emit e_updatetoValueGood(_goodid);
        return true;
    }

    /// @inheritdoc I_Good
    function updatetoNormalGood(
        uint256 _goodid
    ) external override returns (bool) {
        require(msg.sender == marketcreator, "G02");
        goods[_goodid].updateToNormalGood();
        emit e_updatetoNormalGood(_goodid);
        return true;
    }

    /// @inheritdoc I_Good
    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable returns (bool) {
        goods[_goodid].erc20address.safeTransfer(_recipent, _payquanity);
        return true;
    }

    /// @inheritdoc I_Good
    function changeGoodOwner(
        uint256 _goodid,
        address _to
    ) external override returns (bool) {
        require(msg.sender == marketcreator, "G05");
        goods[_goodid].owner = _to;
        return true;
    }

    function collectProtocolFee(
        uint256 _goodid
    ) external override returns (uint256 feeamount) {
        feeamount = goods[_goodid].fees[msg.sender];
        goods[_goodid].fees[msg.sender] = 0;
        goods[_goodid].erc20address.safeTransfer(msg.sender, feeamount);
        emit e_collectProtocolFee(_goodid, feeamount);
    }

    function goodWelfare(
        uint256 goodid,
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
