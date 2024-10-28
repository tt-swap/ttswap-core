// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {I_TTSwap_LimitOrderMaker, S_orderDetails} from "./interfaces/I_TTSwap_LimitOrderMaker.sol";
import {I_TTSwap_LimitOrderTaker, S_takeGoodInputPrams} from "./interfaces/I_TTSwap_LimitOrderTaker.sol";
import {L_OrderStatus} from "./libraries/L_OrderStatus.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_TTSwapUINT256Library} from "./libraries/L_TTSwapUINT256.sol";
import {I_TTSwap_Market} from "./interfaces/I_TTSwap_Market.sol";

/**
 * @title TTS Token Contract
 * @dev Implements ERC20 token with additional staking and cross-chain functionality
 */
contract TTSwap_LimitOrder is I_TTSwap_LimitOrderMaker {
    using L_OrderStatus for mapping(uint256 => uint256);
    using L_CurrencyLibrary for address;
    using L_TTSwapUINT256Library for uint256;
    I_TTSwap_Market internal immutable TTSWAP;
    uint256 public maxslot;
    uint256 public orderpointer;
    mapping(uint256 => uint256) public orderstatus;
    mapping(uint256 => S_orderDetails) public orders;

    function addLimitOrder(S_orderDetails[] memory _orders) external override {
        for (uint256 i; i < _orders.length; i++) {
            orderpointer = orderstatus.getValidOrderId(orderpointer, maxslot);
            orders[orderpointer] = _orders[i];
            emit e_addLimitOrder(
                orderpointer,
                msg.sender,
                _orders[i].fromerc20,
                _orders[i].toerc20,
                _orders[i].amount
            );
        }
    }

    function updateLimitOrder(
        uint256 orderid,
        S_orderDetails memory _order
    ) external override {
        require(
            orders[orderid].sender == msg.sender && orderstatus.get(orderid)
        );
        if (orders[orderid].sender != _order.sender)
            orders[orderid].sender = _order.sender;
        if (orders[orderid].fromerc20 != _order.fromerc20)
            orders[orderid].fromerc20 = _order.fromerc20;
        if (orders[orderid].toerc20 != _order.toerc20)
            orders[orderid].toerc20 = _order.toerc20;
        if (orders[orderid].amount != _order.amount)
            orders[orderid].amount = _order.amount;
        emit e_updateLimitOrder(
            _order.sender,
            _order.fromerc20,
            _order.toerc20,
            _order.amount
        );
    }

    function removeLimitOrder(uint256 orderid) external override {
        require(msg.sender == orders[orderid].sender);
        orderstatus.unset(orderid);
        emit e_removeLimitOrder(orderid);
    }

    function takeLimitOrderNormal(uint256[] memory orderids) external override {
        for (uint256 i; i <= orderids.length; i++) {
            orders[orderids[i]].fromerc20.transferFrom(
                orders[orderids[i]].sender,
                msg.sender,
                orders[orderids[i]].amount.amount0()
            );
            orders[orderids[i]].toerc20.transferFrom(
                msg.sender,
                orders[orderids[i]].sender,
                orders[orderids[i]].amount.amount1()
            );
            orderstatus.unset(orderids[i]);
            emit e_takeOrder(orderids[i]);
        }
    }

    function takeLimitOrdersAMM(
        uint256[] memory orderids,
        uint96 _tolerance,
        address _taker
    ) external override returns (bool) {
        uint256[] memory beforeamount;
        uint256[] memory afteramount;
        bytes[] memory _inputParams;
        for (uint256 i; i <= orderids.length; i++) {
            beforeamount[i] = orders[orderids[i]].toerc20.balanceof(
                orders[orderids[i]].sender
            );
            orders[orderids[i]].fromerc20.transferFrom(
                orders[orderids[i]].sender,
                msg.sender,
                orders[orderids[i]].amount.amount0()
            );
            _inputParams[i] = abi.encode(
                S_takeGoodInputPrams(
                    orders[orderids[i]].fromerc20,
                    orders[orderids[i]].toerc20,
                    orders[orderids[i]].amount,
                    orders[orderids[i]].sender
                )
            );
        }
        I_TTSwap_LimitOrderTaker(_taker).batchTakelimitOrder(
            _inputParams,
            _tolerance,
            msg.sender
        );
        for (uint256 i; i <= orderids.length; i++) {
            afteramount[i] = orders[orderids[i]].toerc20.balanceof(
                orders[orderids[i]].sender
            );
            if (
                afteramount[i] - beforeamount[i] <
                orders[orderids[i]].amount.amount1()
            ) {
                revert lessAmountError(orderids[i]);
            }
            orderstatus.unset(orderids[i]);
            emit e_takeOrder(orderids[i]);
        }
        return true;
    }

    function queryLimitOrder(
        uint256[] memory _ordersids
    ) external view override returns (S_orderDetails[] memory _orderdetail) {
        for (uint256 i; i <= _ordersids.length; i++) {
            _orderdetail[i] = orders[_ordersids[i]];
        }
    }
}
