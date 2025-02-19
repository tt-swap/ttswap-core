// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {toTTSwapUINT256, addsub, subadd} from "../libraries/L_TTSwapUINT256.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

/// @title Market Management Interface
/// @notice Defines the interface for managing market operations
interface I_TTSwap_Market {
    error noEnoughOutputError();

    /// @notice Emitted when market configuration is set
    /// @param _newmarketor The marketcreator
    event e_changemarketcreator(address _newmarketor);
    /// @notice Emitted when market configuration is set
    /// @param _marketconfig The market configuration
    event e_setMarketConfig(uint256 _marketconfig);

    /// @notice Emitted when a good's configuration is updated
    /// @param _goodid The ID of the good
    /// @param _goodConfig The new configuration
    event e_updateGoodConfig(address _goodid, uint256 _goodConfig);

    /// @notice Emitted when a good's configuration is modified by market admin
    /// @param _goodid The ID of the good
    /// @param _goodconfig The new configuration
    event e_modifyGoodConfig(address _goodid, uint256 _goodconfig);

    /// @notice Emitted when a good's owner is changed
    /// @param goodid The ID of the good
    /// @param to The new owner's address
    event e_changegoodowner(address goodid, address to);

    /// @notice Emitted when market commission is collected
    /// @param _gooid Array of good IDs
    /// @param _commisionamount Array of commission amounts
    event e_collectcommission(address[] _gooid, uint256[] _commisionamount);

    /// @notice Emitted when an address is added to the ban list
    /// @param _user The banned user's address
    event e_modifiedUserConfig(address _user, uint256 config);

    /// @notice Emitted when welfare is delivered to investors
    /// @param goodid The ID of the good
    /// @param welfare The amount of welfare
    event e_goodWelfare(address goodid, uint128 welfare);

    /// @notice Emitted when protocol fee is collected
    /// @param goodid The ID of the good
    /// @param feeamount The amount of fee collected
    event e_collectProtocolFee(address goodid, uint256 feeamount);

    /// @notice Emitted when proofid deleted when proofid is transfer.
    /// @param delproofid fromproofid which will be deleted
    /// @param existsproofid conbine to existsproofid
    event e_transferdel(uint256 delproofid, uint256 existsproofid);

    /// @notice Emitted when a meta good is created and initialized
    /// @dev The decimal precision of _initial.amount0() defaults to 6
    /// @param _proofNo The ID of the investment proof
    /// @param _goodid A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _construct A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _goodConfig The configuration of the meta good (refer to the whitepaper for details)
    /// @param _initial Market initialization parameters: amount0 is the value, amount1 is the quantity
    event e_initMetaGood(
        uint256 _proofNo,
        address _goodid,
        uint256 _construct,
        uint256 _goodConfig,
        uint256 _initial
    );

    /// @notice Emitted when a good is created and initialized
    /// @param _proofNo The ID of the investment proof
    /// @param _goodid A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _construct A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _valuegoodNo The ID of the good
    /// @param _goodConfig The configuration of the meta good (refer to the whitepaper for details)
    /// @param _normalinitial Normal good initialization parameters: amount0 is the quantity, amount1 is the value
    /// @param _value Value good initialization parameters: amount0 is the investment fee, amount1 is the investment quantity
    event e_initGood(
        uint256 _proofNo,
        address _goodid,
        address _valuegoodNo,
        uint256 _goodConfig,
        uint256 _construct,
        uint256 _normalinitial,
        uint256 _value
    );

    /// @notice Emitted when a user buys a good
    /// @param sellgood The ID of the good being sold
    /// @param forgood The ID of the good being bought
    /// @param fromer The address of the buyer
    /// @param swapvalue The trade value
    /// @param sellgoodstate The status of the sold good (amount0: fee, amount1: quantity)
    /// @param forgoodstate The status of the bought good (amount0: fee, amount1: quantity)
    event e_buyGood(
        address indexed sellgood,
        address indexed forgood,
        address fromer,
        uint128 swapvalue,
        uint256 sellgoodstate,
        uint256 forgoodstate
    );

    /// @notice Emitted when a user invests in a normal good
    /// @param _proofNo The ID of the investment proof
    /// @param _normalgoodid Packed data: first 128 bits for good's ID, last 128 bits for stake construct
    /// @param _valueGoodNo The ID of the value good
    /// @param _value Investment value (amount0: invest value, amount1: restake construct)
    /// @param _invest Normal good investment details (amount0: actual fee, amount1: actual invest quantity)
    /// @param _valueinvest Value good investment details (amount0: actual fee, amount1: actual invest quantity)
    event e_investGood(
        uint256 indexed _proofNo,
        address _normalgoodid,
        address _valueGoodNo,
        uint256 _value,
        uint256 _invest,
        uint256 _valueinvest
    );

    /// @notice Emitted when a user disinvests from a normal good
    /// @param _proofNo The ID of the investment proof
    /// @param _normalGoodNo The ID of the normal good
    /// @param _valueGoodNo The ID of the value good
    /// @param _normalgood The disinvestment details of the normal good (amount0: actual fee, amount1: actual disinvest quantity)
    /// @param _valuegood The disinvestment details of the value good (amount0: actual fee, amount1: actual disinvest quantity)
    /// @param _profit The profit (amount0: normal good profit, amount1: value good profit)
    event e_disinvestProof(
        uint256 indexed _proofNo,
        address _normalGoodNo,
        address _valueGoodNo,
        uint256 _value,
        uint256 _normalgood,
        uint256 _valuegood,
        uint256 _profit
    );

    /// @notice Emitted when a user collects profit from an investment proof
    /// @param _proofNo The ID of the investment proof
    /// @param _normalGoodNo The ID of the normal good
    /// @param _valueGoodNo The ID of the value good
    /// @param _profit The collected profit (amount0: normal good profit, amount1: value good profit)
    event e_collectProof(
        uint256 indexed _proofNo,
        address _normalGoodNo,
        address _valueGoodNo,
        uint256 _profit
    );

    /// @notice Emitted when a good is empowered
    /// @param _goodid The ID of the good
    /// @param _valuegood The ID of the value good
    /// @param _quantity The quantity of the value good to empower
    event e_enpower(uint256 _goodid, uint256 _valuegood, uint256 _quantity);

    // Function declarations

    function userConfig(address) external view returns (uint256);
    function setMarketor(address _newmarketor) external;
    function removeMarketor(address _user) external;

    /// @notice Initialize the first good in the market
    /// @param _erc20address The contract address of the good
    /// @param _initial Initial parameters for the good (amount0: value, amount1: quantity)
    /// @param _goodconfig Configuration of the good
    /// @param data Configuration of the good
    /// @return Success status
    function initMetaGood(
        address _erc20address,
        uint256 _initial,
        uint256 _goodconfig,
        bytes calldata data
    ) external payable returns (bool);

    /// @notice Initialize a normal good in the market
    /// @param _valuegood The ID of the value good used to measure the normal good's value
    /// @param _initial Initial parameters (amount0: normal good quantity, amount1: value good quantity)
    /// @param _erc20address The contract address of the good
    /// @param _goodConfig Configuration of the good
    /// @param data1 Configuration of the good
    /// @param data2 Configuration of the good
    /// @return Success status
    function initGood(
        address _valuegood,
        uint256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        bytes calldata data1,
        bytes calldata data2
    ) external payable returns (bool);

    /// @notice Sell one good to buy another
    /// @param _goodid1 ID of the good to sell
    /// @param _goodid2 ID of the good to buy
    /// @param _swapQuantity Quantity of _goodid1 to sell
    /// @param _limitprice Price limit for the trade
    /// @param _istotal Whether to trade all or partial amount
    /// @param _referal Referral address
    /// @return goodid2Quantity_ Actual quantity of good2 received
    /// @return goodid2FeeQuantity_ Fee quantity for good2
    function buyGood(
        address _goodid1,
        address _goodid2,
        uint128 _swapQuantity,
        uint256 _limitprice,
        bool _istotal,
        address _referal,
        bytes calldata data1
    )
        external
        payable
        returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);

    /// @notice Invest in a normal good
    /// @param _togood ID of the normal good to invest in
    /// @param _valuegood ID of the value good
    /// @param _quantity Quantity of normal good to invest
    /// @return Success status
    function investGood(
        address _togood,
        address _valuegood,
        uint128 _quantity,
        bytes calldata data1,
        bytes calldata data2
    ) external payable returns (bool);

    /// @notice Disinvest from a normal good
    /// @param _proofid ID of the investment proof
    /// @param _goodQuantity Quantity to disinvest
    /// @param _gater Address of the gater
    /// @return Success status
    function disinvestProof(
        uint256 _proofid,
        uint128 _goodQuantity,
        address _gater
    ) external returns (bool);

    /// @notice Collect profit from an investment proof
    /// @param _proofid ID of the investment proof
    /// @param _gater Address of the gater
    /// @return profit_ Collected profit (amount0: normal good profit, amount1: value good profit)
    function collectProof(
        uint256 _proofid,
        address _gater
    ) external returns (uint256 profit_);

    /// @notice Check if the price of a good is higher than a comparison price
    /// @param goodid ID of the good to check
    /// @param valuegood ID of the value good
    /// @param compareprice Price to compare against
    /// @return Whether the good's price is higher
    function ishigher(
        address goodid,
        address valuegood,
        uint256 compareprice
    ) external view returns (bool);

    function getProofState(
        uint256 proofid
    ) external view returns (S_ProofState memory);

    function getGoodState(
        address goodkey
    ) external view returns (S_GoodTmpState memory);

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
        address _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice Allows market admin to modify a good's attributes
    /// @param _goodid The ID of the good
    /// @param _goodConfig The new configuration
    /// @return Success status
    function modifyGoodConfig(
        address _goodid,
        uint256 _goodConfig
    ) external returns (bool);

    /// @notice Transfers a good to another address
    /// @param _goodid The ID of the good
    /// @param _payquanity The quantity to transfer
    /// @param _recipent The recipient's address
    /// @param transdata The recipient's address
    /// @return Success status
    function payGood(
        address _goodid,
        uint128 _payquanity,
        address _recipent,
        bytes calldata transdata
    ) external payable returns (bool);

    /// @notice Changes the owner of a good
    /// @param _goodid The ID of the good
    /// @param _to The new owner's address
    function changeGoodOwner(address _goodid, address _to) external;

    /// @notice Collects commission for specified goods
    /// @param _goodid Array of good IDs
    function collectCommission(address[] memory _goodid) external;

    /// @notice Queries commission for specified goods and recipient
    /// @param _goodid Array of good IDs
    /// @param _recipent The recipient's address
    /// @return Array of commission amounts
    function queryCommission(
        address[] memory _goodid,
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
    function goodWelfare(
        address goodid,
        uint128 welfare,
        bytes calldata data1
    ) external payable;
}
/**
 * @dev Represents the state of a proof
 * @member currentgood The current good  associated with the proof
 * @member valuegood The value good associated with the proof
 * @member state amount0 (first 128 bits) represents total value
 * @member invest amount0 (first 128 bits) represents invest normal good quantity, amount1 (last 128 bits) represents normal good constuct fee when investing
 * @member valueinvest amount0 (first 128 bits) represents invest value good quantity, amount1 (last 128 bits) represents value good constuct fee when investing
 */
struct S_ProofState {
    address currentgood;
    address valuegood;
    uint256 state;
    uint256 invest;
    uint256 valueinvest;
}
/**
 * @dev Struct representing the state of a good
 */
struct S_GoodState {
    uint256 goodConfig; // Configuration of the good
    address owner; // Creator of the good
    uint256 currentState; // Current state: amount0 (first 128 bits) represents total value, amount1 (last 128 bits) represents quantity
    uint256 investState; // Investment state: amount0 represents total invested value, amount1 represents total invested quantity
    uint256 feeQuantityState; // Fee state: amount0 represents total fees (including construction fees), amount1 represents total construction fees
    mapping(address => uint256) commission;
}
/**
 * @dev Struct representing a temporary state of a good
 */
struct S_GoodTmpState {
    uint256 goodConfig; // Configuration of the good
    address owner; // Creator of the good
    uint256 currentState; // Current state: amount0 (first 128 bits) represents total value, amount1 (last 128 bits) represents quantity
    uint256 investState; // Investment state: amount0 represents total invested value, amount1 represents total invested quantity
    uint256 feeQuantityState; // Fee state: amount0 represents total fees (including construction fees), amount1 represents total construction fees
}
struct S_GoodKey {
    address owner;
    address erc20address;
}

struct S_ProofKey {
    address owner;
    address currentgood;
    address valuegood;
}
struct S_LoanProof {
    uint256 amount; //first 128 bit amount ,last 128 bit store feerate
}
