// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_GoodKey} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";

/// @title Good's interface
/// @notice Contains all interfaces related to goods
interface I_Good {
    /// @notice Emitted when a good's ownership is transferred
    /// @param _goodid The ID of the good
    /// @param _owner The previous owner
    /// @param _to The new owner
    event e_changeOwner(uint256 indexed _goodid, address _owner, address _to);

    /// @notice Emitted when market configuration is set
    /// @param _marketconfig The market configuration
    event e_setMarketConfig(uint256 _marketconfig);

    /// @notice Emitted when a good's configuration is updated
    /// @param _goodid The ID of the good
    /// @param _goodConfig The new configuration
    event e_updateGoodConfig(uint256 _goodid, uint256 _goodConfig);

    /// @notice Emitted when a good's configuration is modified by market admin
    /// @param _goodid The ID of the good
    /// @param _goodconfig The new configuration
    event e_modifyGoodConfig(uint256 _goodid, uint256 _goodconfig);

    /// @notice Emitted when a good's owner is changed
    /// @param goodid The ID of the good
    /// @param to The new owner's address
    event e_changegoodowner(uint256 goodid, address to);

    /// @notice Emitted when market commission is collected
    /// @param _gooid Array of good IDs
    /// @param _commisionamount Array of commission amounts
    event e_collectcommission(uint256[] _gooid, uint256[] _commisionamount);

    /// @notice Emitted when an address is added to the ban list
    /// @param _user The banned user's address
    event e_addbanlist(address _user);

    /// @notice Emitted when an address is removed from the ban list
    /// @param _user The unbanned user's address
    event e_removebanlist(address _user);

    /// @notice Emitted when welfare is delivered to investors
    /// @param goodid The ID of the good
    /// @param welfare The amount of welfare
    event e_goodWelfare(uint256 goodid, uint128 welfare);

    /// @notice Emitted when protocol fee is collected
    /// @param goodid The ID of the good
    /// @param feeamount The amount of fee collected
    event e_collectProtocolFee(uint256 goodid, uint256 feeamount);

    /// @notice Emitted when a referral is added
    /// @param referals The address of the referral
    event e_addreferal(address referals);

    /// @notice Returns the market configuration
    /// @dev Can be changed by the market manager
    /// @return marketconfig_ The market configuration
    function marketconfig() external view returns (uint256 marketconfig_);

    /// @notice Sets the market configuration
    /// @param _marketconfig The new market configuration
    /// @return Success status
    function setMarketConfig(uint256 _marketconfig) external returns (bool);

    /// @notice Updates a good's configuration
    /// @param _goodid The ID of the good
    /// @param _goodConfig The new configuration
    /// @return Success status
    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice Allows market admin to modify a good's attributes
    /// @param _goodid The ID of the good
    /// @param _goodConfig The new configuration
    /// @return Success status
    function modifyGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice Transfers a good to another address
    /// @param _goodid The ID of the good
    /// @param _payquanity The quantity to transfer
    /// @param _recipent The recipient's address
    /// @return Success status
    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external payable returns (bool);

    /// @notice Changes the owner of a good
    /// @param _goodid The ID of the good
    /// @param _to The new owner's address
    function changeGoodOwner(uint256 _goodid, address _to) external;

    /// @notice Collects commission for specified goods
    /// @param _goodid Array of good IDs
    function collectCommission(uint256[] memory _goodid) external;

    /// @notice Queries commission for specified goods and recipient
    /// @param _goodid Array of good IDs
    /// @param _recipent The recipient's address
    /// @return Array of commission amounts
    function queryCommission(
        uint256[] memory _goodid,
        address _recipent
    ) external returns (uint256[] memory);

    /// @notice Adds an address to the ban list
    /// @param _user The address to ban
    /// @return is_success_ Success status
    function addbanlist(address _user) external returns (bool is_success_);

    /// @notice Removes an address from the ban list
    /// @param _user The address to unban
    /// @return is_success_ Success status
    function removebanlist(address _user) external returns (bool is_success_);

    /// @notice Delivers welfare to investors
    /// @param goodid The ID of the good
    /// @param welfare The amount of welfare
    function goodWelfare(uint256 goodid, uint128 welfare) external payable;
}
