// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {I_TTSwap_LimitOrderMaker} from "./interfaces/I_TTSwap_LimitOrderMaker.sol";
import {I_TTSwap_LimitOrderTaker, S_takeGoodInputPrams} from "./interfaces/I_TTSwap_LimitOrderTaker.sol";
import {L_OrderStatus} from "./libraries/L_OrderStatus.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256} from "./libraries/L_TTSwapUINT256.sol";

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
    address public marketcreator;
    uint96 public maxfreeremain;
    mapping(uint256 => uint256) internal orderstatus;
    mapping(uint256 => S_orderDetails) public orders;
    mapping(address => uint256) public auths;

    bytes internal constant defaultdata =
        abi.encode(L_CurrencyLibrary.S_transferData(1, "0X"));
    constructor(address _marketor) {
        marketcreator = _marketor;
        maxfreeremain = 40425200;
        maxslot = 1;
        emit e_deploy(marketcreator, maxfreeremain, maxslot);
    }

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

    function addmaxslot(uint256 _maxslot) external {
        require(auths[msg.sender] == 1 && _maxslot > maxslot);
        maxslot = _maxslot;
        emit e_addmaxslot(_maxslot);
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
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

    /// @inheritdoc I_TTSwap_LimitOrderMaker
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

    /// @inheritdoc I_TTSwap_LimitOrderMaker
    function removeLimitOrder(uint256 orderid) external override {
        require(msg.sender == orders[orderid].sender);
        orderstatus.unset(orderid);
        emit e_removeLimitOrder(orderid);
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
    function takeLimitOrderNormal(
        S_TakeParams[] memory orderids
    ) external override {
        for (uint256 i; i < orderids.length; i++) {
            if (orderstatus.get(orderids[i].orderid)) {
                orders[orderids[i].orderid].fromerc20.transferFrom(
                    orders[orderids[i].orderid].sender,
                    msg.sender,
                    orders[orderids[i].orderid].amount.amount0(),
                    defaultdata
                );

                orders[orderids[i].orderid].toerc20.transferFrom(
                    msg.sender,
                    orders[orderids[i].orderid].sender,
                    orders[orderids[i].orderid].amount.amount1(),
                    orderids[i].transdata
                );
                orderstatus.unset(orderids[i].orderid);
                emit e_takeOrder(orderids[i].orderid);
            }
        }
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
    function takeLimitOrderChips(
        S_OrderChip[] memory _orderChips
    ) external override {
        for (uint256 i; i < _orderChips.length; i++) {
            if (orderstatus.get(_orderChips[i].orderid)) {
                _orderChips[i].takeamount = _orderChips[i].takeamount >=
                    orders[_orderChips[i].orderid].amount.amount0()
                    ? orders[_orderChips[i].orderid].amount.amount0()
                    : _orderChips[i].takeamount;
                orders[_orderChips[i].orderid].fromerc20.transferFrom(
                    orders[_orderChips[i].orderid].sender,
                    msg.sender,
                    _orderChips[i].takeamount,
                    defaultdata
                );
                uint128 getamount = orders[_orderChips[i].orderid]
                    .amount
                    .getamount1fromamount0(_orderChips[i].takeamount);
                getamount = getamount >=
                    orders[_orderChips[i].orderid].amount.amount1()
                    ? orders[_orderChips[i].orderid].amount.amount1()
                    : getamount;
                orders[_orderChips[i].orderid].toerc20.transferFrom(
                    msg.sender,
                    orders[_orderChips[i].orderid].sender,
                    getamount,
                    _orderChips[i].transdata
                );
                if (
                    _orderChips[i].takeamount >=
                    orders[_orderChips[i].orderid].amount.amount0()
                ) {
                    orderstatus.unset(_orderChips[i].orderid);
                    emit e_takeOrder(_orderChips[i].orderid);
                } else {
                    orders[_orderChips[i].orderid].amount =
                        orders[_orderChips[i].orderid].amount -
                        toTTSwapUINT256(_orderChips[i].takeamount, getamount);
                    emit e_takeOrderChips(
                        _orderChips[i].orderid,
                        orders[_orderChips[i].orderid].amount
                    );
                }
            }
        }
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
    function takeLimitOrderAMM(
        uint256 orderid,
        uint96 _tolerance,
        I_TTSwap_LimitOrderTaker _takecontract,
        address _takecaller
    ) external override returns (bool _isSuccess) {
        S_takeGoodInputPrams memory _inputParams;
        uint256 beforeamount = orders[orderid].toerc20.balanceof(
            orders[orderid].sender
        );
        _inputParams = S_takeGoodInputPrams(
            orders[orderid].fromerc20,
            orders[orderid].toerc20,
            orders[orderid].amount,
            orders[orderid].sender
        );
        _takecontract.takeLimitOrder(_inputParams, _tolerance, _takecaller);

        uint256 afteramount = orders[orderid].toerc20.balanceof(
            orders[orderid].sender
        );
        if (afteramount - beforeamount < orders[orderid].amount.amount1()) {
            revert lessAmountError(orderid);
        } else {
            orders[orderid].fromerc20.transferFrom(
                orders[orderid].sender,
                address(_takecontract),
                orders[orderid].amount.amount0(),
                defaultdata
            );
            orderstatus.unset(orderid);
            emit e_takeOrder(orderid);
            _isSuccess = true;
        }
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
    function takeBatchLimitOrdersAMM(
        uint256[] memory orderids,
        uint96 _tolerance,
        I_TTSwap_LimitOrderTaker _takecontract,
        address _takecaller,
        bool _isall
    ) external override returns (bool[] memory) {
        uint256[] memory beforeamount = new uint256[](orderids.length);
        S_takeGoodInputPrams[] memory _inputParams = new S_takeGoodInputPrams[](
            orderids.length
        );
        bool[] memory result_ = new bool[](orderids.length);
        uint256 afteramount;
        uint256 i;
        for (i; i < orderids.length; i++) {
            beforeamount[i] = orders[orderids[i]].toerc20.balanceof(
                orders[orderids[i]].sender
            );
            if (orderstatus.get(orderids[i])) {
                _inputParams[i] = S_takeGoodInputPrams(
                    orders[orderids[i]].fromerc20,
                    orders[orderids[i]].toerc20,
                    orders[orderids[i]].amount,
                    orders[orderids[i]].sender
                );
            }
        }
        result_ = _takecontract.batchTakelimitOrder(
            abi.encode(_inputParams),
            _tolerance,
            _takecaller,
            uint8(orderids.length)
        );
        i = 0;
        for (i; i < orderids.length; i++) {
            afteramount = _inputParams[i].toerc20.balanceof(
                _inputParams[i].sender
            );
            if (
                _inputParams[i].swapQuantity.amount1() + beforeamount[i] <
                afteramount
            ) {
                if (_isall) {
                    revert lessAmountError(orderids[i]);
                } else {
                    result_[i] = false;
                }
            } else {
                _inputParams[i].fromerc20.transferFrom(
                    _inputParams[i].sender,
                    address(_takecontract),
                    _inputParams[i].swapQuantity.amount0(),
                    defaultdata
                );
                orderstatus.unset(orderids[i]);
                emit e_takeOrder(orderids[i]);
                result_[i] = true;
            }
        }
        return result_;
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
            emit e_cleandeadorders(ids);
        } else {
            for (uint256 i = 0; i < ids.length; i++) {
                computetimes =
                    block.timestamp -
                    uint256(orders[ids[i]].timestamp);
                if (
                    orderstatus.get(ids[i]) &&
                    computetimes > uint256(maxfreeremain)
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
                            (orders[ids[i]].amount.amount0() * computetimes) /
                            1000;
                        orders[ids[i]].fromerc20.transferFrom(
                            orders[ids[i]].sender,
                            msg.sender,
                            uint128(amount),
                            defaultdata
                        );
                        orderstatus.setTo(ids[i], false);
                        emit e_cleandeadorder(ids[i], amount, msg.sender);
                    }
                }
            }
        }
    }

    /// @inheritdoc I_TTSwap_LimitOrderMaker
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

    function queryOrdersStatus(
        uint256[] memory _ordersids
    ) external view returns (bool[] memory) {
        bool[] memory query = new bool[](_ordersids.length);
        for (uint256 i; i < _ordersids.length; i++) {
            query[i] = orderstatus.get(_ordersids[i]);
        }
        return query;
    }

    function queryOrderStatus(uint256 _ordersid) external view returns (bool) {
        return orderstatus.get(_ordersid);
    }
}
