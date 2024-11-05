// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {I_TTSwap_LimitOrderMaker, S_orderDetails} from "./interfaces/I_TTSwap_LimitOrderMaker.sol";
import {I_TTSwap_LimitOrderTaker, S_takeGoodInputPrams} from "./interfaces/I_TTSwap_LimitOrderTaker.sol";
import {L_OrderStatus} from "./libraries/L_OrderStatus.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_TTSwapUINT256Library} from "./libraries/L_TTSwapUINT256.sol";

/**
 * @title TTS Token Contract
 * @dev Implements ERC20 token with additional staking and cross-chain functionality
 */
contract TTSwap_LimitOrder is I_TTSwap_LimitOrderMaker {
    using L_OrderStatus for mapping(uint256 => uint256);
    using L_CurrencyLibrary for address;
    using L_TTSwapUINT256Library for uint256;
    uint256 public maxslot;
    uint256 public orderpointer;
    mapping(uint256 => uint256) public orderstatus;
    mapping(uint256 => S_orderDetails) public orders;
    mapping(address => uint256) public auths;
    address public marketcreator;
    uint96 public maxfreeremain;

    constructor(address _marketor) {
        marketcreator = _marketor;
        maxfreeremain = 40425200;
        maxslot = 10;
    }
    //180天
    function setMaxfreeRemain(uint96 times) external {
        require(times > 40425200 && msg.sender == marketcreator);
        maxfreeremain = times;
        emit e_setmaxfreeremain(times);
    }
    function changemarketcreator(address _newmarketor) external {
        require(msg.sender == marketcreator);
        marketcreator = _newmarketor;
        emit e_changemarketcreator(_newmarketor);
    }

    function addauths(address _marketor, uint256 _auths) external {
        require(msg.sender == marketcreator);
        auths[_marketor] = _auths;
        emit e_addauths(_marketor, _auths);
    }

    function removeauths(address _marketor) external {
        require(msg.sender == marketcreator);
        delete auths[_marketor];
        emit e_removeauths(_marketor);
    }
    function addLimitOrder(S_orderDetails[] memory _orders) external override {
        for (uint256 i; i < _orders.length; i++) {
            orderpointer = orderstatus.getValidOrderId(orderpointer, maxslot);
            _orders[i].timestamp = uint96(block.timestamp);
            orders[orderpointer] = _orders[i];
            emit e_addLimitOrder(
                orderpointer,
                _orders[i].sender,
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
        if (orders[orderid].fromerc20 != _order.fromerc20)
            orders[orderid].fromerc20 = _order.fromerc20;
        if (orders[orderid].toerc20 != _order.toerc20)
            orders[orderid].toerc20 = _order.toerc20;
        if (orders[orderid].amount != _order.amount)
            orders[orderid].amount = _order.amount;
        orders[orderid].timestamp = uint96(block.timestamp);
        emit e_updateLimitOrder(
            orderid,
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
            if (orderstatus.get(i)) {
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
            if (orderstatus.get(i)) {
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
    function cleandeadorder(uint256[] memory ids, bool smallorder) public {
        require(auths[msg.sender] == 1);
        uint256 computetimes;
        uint256 amount;
        if (smallorder) {
            for (uint256 i = 0; i < ids.length; i++) {
                if (orderstatus.get(i)) {
                    orderstatus.unset(ids[i]);
                }
            }
            emit e_deletedeadorders(ids);
        } else {
            for (uint256 i = 0; i < ids.length; i++) {
                computetimes = block.timestamp - uint256(orders[i].timestamp);
                if (
                    orderstatus.get(i) && computetimes > uint256(maxfreeremain)
                ) {
                    computetimes = computetimes > uint256(maxfreeremain)
                        ? computetimes - uint256(maxfreeremain)
                        : 0;
                    computetimes = computetimes == 0
                        ? 0
                        : computetimes / 864000;
                    computetimes = computetimes > 0 ? (computetimes + 10) : 0;
                    computetimes = computetimes > 100 ? 100 : computetimes;
                    if (computetimes > 0) {
                        amount =
                            (orders[i].amount.amount0() * computetimes) /
                            1000;
                        orders[i].fromerc20.transferFrom(
                            orders[i].sender,
                            msg.sender,
                            amount
                        );
                        emit e_deletedeadorder(ids[i], amount, msg.sender);
                    }
                }
            }
        }
    }
    function queryLimitOrder(
        uint256[] memory _ordersids
    ) external view override returns (S_orderDetails[] memory) {
        S_orderDetails[] memory _orderdetail = new S_orderDetails[](
            _ordersids.length
        );
        for (uint256 i; i < _ordersids.length; i++) {
            _orderdetail[i].timestamp = orders[_ordersids[i]].timestamp;
            _orderdetail[i].sender = orders[_ordersids[i]].sender;
            _orderdetail[i].fromerc20 = orders[_ordersids[i]].fromerc20;
            _orderdetail[i].toerc20 = orders[_ordersids[i]].toerc20;
            _orderdetail[i].amount = orders[_ordersids[i]].amount;
        }
        return _orderdetail;
    }
}
