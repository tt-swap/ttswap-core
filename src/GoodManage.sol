// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {I_Good} from "./interfaces/I_Good.sol";
import {ProofManage} from "./ProofManage.sol";

import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Good} from "./libraries/L_Good.sol";
import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {S_GoodKey} from "./libraries/L_Struct.sol";
import {L_Lock} from "./libraries/L_Lock.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd, lowerprice} from "./libraries/L_BalanceUINT256.sol";

/**
 * @title GoodManage
 * @dev Abstract contract for managing goods-related operations
 * @notice Implements functionality for goods configuration, commission collection, and blacklist management
 */
abstract contract GoodManage is I_Good, ProofManage {
    using L_CurrencyLibrary for address;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_Good for L_Good.S_GoodState;

    /// @inheritdoc I_Good
    uint256 public override marketconfig;

    mapping(uint256 => L_Good.S_GoodState) internal goods;
    mapping(address => uint256) public banlist;

    /**
     * @dev Constructor
     * @param _marketconfig Market configuration
     * @param _officialcontract Official contract address
     */
    constructor(
        uint256 _marketconfig,
        address _officialcontract
    ) ProofManage(_officialcontract) {
        marketconfig = _marketconfig;
    }

    /**
     * @dev Modifier to prevent reentrancy
     */
    modifier noReentrant() {
        require(L_Lock.get() == address(0));
        L_Lock.set(msg.sender);
        _;
        L_Lock.set(address(0));
    }

    /**
     * @dev Get the state of a good
     * @param goodkey The ID of the good
     * @return Temporary state structure of the good
     */
    function getGoodState(
        uint256 goodkey
    ) external view returns (L_Good.S_GoodTmpState memory) {
        return
            L_Good.S_GoodTmpState(
                goods[goodkey].goodConfig,
                goods[goodkey].owner,
                goods[goodkey].erc20address,
                goods[goodkey].currentState,
                goods[goodkey].investState,
                goods[goodkey].feeQuantityState
            );
    }

    /// @inheritdoc I_Good
    function addbanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 1;
        emit e_addbanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function removebanlist(
        address _user
    ) external override onlyMarketor returns (bool) {
        banlist[_user] = 0;
        emit e_removebanlist(_user);
        return true;
    }

    /// @inheritdoc I_Good
    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyMarketor returns (bool) {
        marketconfig = _marketconfig;
        emit e_setMarketConfig(_marketconfig);
        return true;
    }

    /**
     * @dev Update the configuration of a good
     * @param _goodid The ID of the good
     * @param _goodConfig The new configuration for the good
     * @return Boolean indicating if the operation was successful
     */
    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner);
        goods[_goodid].updateGoodConfig(_goodConfig);
        emit e_updateGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_Good
    function modifyGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override onlyMarketor returns (bool) {
        goods[_goodid].modifyGoodConfig(_goodConfig);
        emit e_modifyGoodConfig(_goodid, _goodConfig);
        return true;
    }

    /// @inheritdoc I_Good
    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable returns (bool) {
        if (goods[_goodid].erc20address == address(0)) {
            goods[_goodid].erc20address.safeTransfer(_recipent, _payquanity);
        } else {
            goods[_goodid].erc20address.transferFrom(
                msg.sender,
                _recipent,
                _payquanity
            );
        }
        return true;
    }

    /// @inheritdoc I_Good
    function changeGoodOwner(
        uint256 _goodid,
        address _to
    ) external override onlyMarketor {
        goods[_goodid].owner = _to;
        emit e_changegoodowner(_goodid, _to);
    }

    /**
     * @dev Collect commission for multiple goods
     * @param _goodid Array of good IDs
     */
    function collectCommission(uint256[] memory _goodid) external override {
        require(_goodid.length < 100);
        uint256[] memory commissionamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
            commissionamount[i] = goods[_goodid[i]].commission[msg.sender];
            if (commissionamount[i] < 2) {
                commissionamount[i] = 0;
                continue;
            } else {
                commissionamount[i] = commissionamount[i] - 1;
                goods[_goodid[i]].commission[msg.sender] = 1;
                goods[_goodid[i]].erc20address.safeTransfer(
                    msg.sender,
                    commissionamount[i]
                );
            }
        }
        emit e_collectcommission(_goodid, commissionamount);
    }

    /**
     * @dev Query commission for multiple goods
     * @param _goodid Array of good IDs
     * @param _recipent Address of the recipient
     * @return Array of commission amounts
     */
    function queryCommission(
        uint256[] memory _goodid,
        address _recipent
    ) external view override returns (uint256[] memory) {
        require(_goodid.length < 100);
        uint256[] memory feeamount = new uint256[](_goodid.length);
        for (uint i = 0; i < _goodid.length; i++) {
            feeamount[i] = goods[_goodid[i]].commission[_recipent];
        }
        return feeamount;
    }

    /**
     * @dev Add welfare to a good
     * @param goodid The ID of the good
     * @param welfare The amount of welfare to add
     */
    function goodWelfare(
        uint256 goodid,
        uint128 welfare
    ) external payable override noReentrant {
        require(goods[goodid].feeQuantityState.amount0() + welfare <= 2 ** 109);
        goods[goodid].erc20address.transferFrom(msg.sender, welfare);
        goods[goodid].feeQuantityState =
            goods[goodid].feeQuantityState +
            toBalanceUINT256(uint128(welfare), 0);
        emit e_goodWelfare(goodid, welfare);
    }
}
