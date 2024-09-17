// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./I_Proof.sol";
import "./I_Good.sol";

import {S_GoodKey, S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "../libraries/L_BalanceUINT256.sol";

/// @title Market Management Interface
/// @notice Defines the interface for managing market operations
interface I_MarketManage is I_Good, I_Proof {
    /// @notice Emitted when a meta good is created and initialized
    /// @dev The decimal precision of _initial.amount0() defaults to 6
    /// @param _proofNo The ID of the investment proof
    /// @param _extendinfo A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _erc20address The contract address of the meta good
    /// @param _goodConfig The configuration of the meta good (refer to the whitepaper for details)
    /// @param _initial Market initialization parameters: amount0 is the value, amount1 is the quantity
    event e_initMetaGood(
        uint256 _proofNo,
        T_BalanceUINT256 _extendinfo,
        address _erc20address,
        uint256 _goodConfig,
        T_BalanceUINT256 _initial
    );

    /// @notice Emitted when a good is created and initialized
    /// @param _proofNo The ID of the investment proof
    /// @param _extendinfo A 256-bit value where the first 128 bits represent the good's ID and the last 128 bits represent the stake construct
    /// @param _valuegoodNo The ID of the good
    /// @param _erc20address The contract address of the meta good
    /// @param _goodConfig The configuration of the meta good (refer to the whitepaper for details)
    /// @param _normalinitial Normal good initialization parameters: amount0 is the quantity, amount1 is the value
    /// @param _value Value good initialization parameters: amount0 is the investment fee, amount1 is the investment quantity
    event e_initGood(
        uint256 _proofNo,
        T_BalanceUINT256 _extendinfo,
        uint256 _valuegoodNo,
        address _erc20address,
        uint256 _goodConfig,
        T_BalanceUINT256 _normalinitial,
        T_BalanceUINT256 _value
    );

    /// @notice Emitted when a user buys a good
    /// @param sellgood The ID of the good being sold
    /// @param forgood The ID of the good being bought
    /// @param fromer The address of the buyer
    /// @param swapvalue The trade value
    /// @param sellgoodstate The status of the sold good (amount0: fee, amount1: quantity)
    /// @param forgoodstate The status of the bought good (amount0: fee, amount1: quantity)
    event e_buyGood(
        uint256 indexed sellgood,
        uint256 indexed forgood,
        address fromer,
        uint128 swapvalue,
        T_BalanceUINT256 sellgoodstate,
        T_BalanceUINT256 forgoodstate
    );

    /// @notice Emitted when a user buys a good and pays the seller
    /// @param buygood The ID of the good being bought
    /// @param usegood The ID of the good being used for payment
    /// @param fromer The address of the buyer
    /// @param receipt The address of the recipient (seller)
    /// @param swapvalue The trade value
    /// @param buygoodstate The status of the bought good (amount0: fee, amount1: quantity)
    /// @param usegoodstate The status of the used good (amount0: fee, amount1: quantity)
    event e_buyGoodForPay(
        uint256 indexed buygood,
        uint256 indexed usegood,
        address fromer,
        address receipt,
        uint128 swapvalue,
        T_BalanceUINT256 buygoodstate,
        T_BalanceUINT256 usegoodstate
    );

    /// @notice Emitted when a user invests in a normal good
    /// @param _proofNo The ID of the investment proof
    /// @param _extendinfo Packed data: first 128 bits for good's ID, last 128 bits for stake construct
    /// @param _valueGoodNo The ID of the value good
    /// @param _value Investment value (amount0: invest value, amount1: 0)
    /// @param _invest Normal good investment details (amount0: actual fee, amount1: actual invest quantity)
    /// @param _valueinvest Value good investment details (amount0: actual fee, amount1: actual invest quantity)
    event e_investGood(
        uint256 indexed _proofNo,
        T_BalanceUINT256 _extendinfo,
        uint256 _valueGoodNo,
        T_BalanceUINT256 _value,
        T_BalanceUINT256 _invest,
        T_BalanceUINT256 _valueinvest
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
        uint256 _normalGoodNo,
        uint256 _valueGoodNo,
        T_BalanceUINT256 _value,
        T_BalanceUINT256 _normalgood,
        T_BalanceUINT256 _valuegood,
        T_BalanceUINT256 _profit
    );

    /// @notice Emitted when a user collects profit from an investment proof
    /// @param _proofNo The ID of the investment proof
    /// @param _normalGoodNo The ID of the normal good
    /// @param _valueGoodNo The ID of the value good
    /// @param _profit The collected profit (amount0: normal good profit, amount1: value good profit)
    event e_collectProof(
        uint256 indexed _proofNo,
        uint256 _normalGoodNo,
        uint256 _valueGoodNo,
        T_BalanceUINT256 _profit
    );

    /// @notice Emitted when a good is empowered
    /// @param _goodid The ID of the good
    /// @param _valuegood The ID of the value good
    /// @param _quantity The quantity of the value good to empower
    event e_enpower(uint256 _goodid, uint256 _valuegood, uint256 _quantity);

    // Function declarations

    /// @notice Initialize the first good in the market
    /// @param _erc20address The contract address of the good
    /// @param _initial Initial parameters for the good (amount0: value, amount1: quantity)
    /// @param _goodconfig Configuration of the good
    /// @return Success status
    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodconfig
    ) external payable returns (bool);

    /// @notice Initialize a normal good in the market
    /// @param _valuegood The ID of the value good used to measure the normal good's value
    /// @param _initial Initial parameters (amount0: normal good quantity, amount1: value good quantity)
    /// @param _erc20address The contract address of the good
    /// @param _goodConfig Configuration of the good
    /// @return Success status
    function initGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig
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
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuantity,
        T_BalanceUINT256 _limitprice,
        bool _istotal,
        address _referal
    )
        external
        payable
        returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);

    /// @notice Buy a good, sell another, and send to a recipient
    /// @param _goodid1 ID of the good to buy
    /// @param _goodid2 ID of the good to sell
    /// @param _swapQuantity Quantity of _goodid2 to buy
    /// @param _limitprice Price limit for the trade
    /// @param _recipent Address of the recipient
    /// @return goodid1Quantity_ Actual quantity of good1 received
    /// @return goodid1FeeQuantity_ Fee quantity for good1
    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuantity,
        T_BalanceUINT256 _limitprice,
        address _recipent
    )
        external
        payable
        returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);

    /// @notice Invest in a normal good
    /// @param _togood ID of the normal good to invest in
    /// @param _valuegood ID of the value good
    /// @param _quantity Quantity of normal good to invest
    /// @return Success status
    function investGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quantity
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
    ) external returns (T_BalanceUINT256 profit_);

    /// @notice Check if the price of a good is higher than a comparison price
    /// @param goodid ID of the good to check
    /// @param valuegood ID of the value good
    /// @param compareprice Price to compare against
    /// @return Whether the good's price is higher
    function ishigher(
        uint256 goodid,
        uint256 valuegood,
        uint256 compareprice
    ) external view returns (bool);
}
