// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {I_TTSwap_LimitOrderTaker} from "./I_TTSwap_LimitOrderTaker.sol";
interface I_TTSwap_LimitOrderMaker {
    /// @notice Emitted when User add limit order
    /// @param _orderid the limit order id
    /// @param _sender the limit's owner
    /// @param _fromerc20 from erc20
    /// @param _toerc20  to achive the erc20 token
    /// @param _amount fitst 128bit is the from amount,last 128 bit is the to amount
    event e_addLimitOrder(
        uint256 _orderid,
        address _sender,
        address _fromerc20,
        address _toerc20,
        uint256 _amount
    );
    /// @notice Emitted when marketor set maxfreeremaintimestamp
    /// @param _maxfreeremain the max free remain timestamp
    event e_setmaxfreeremain(uint96 _maxfreeremain);
    /// @notice Emitted when marketor change marketcreator
    /// @param _newmarketcreator the new marketcreator
    event e_changemarketcreator(address _newmarketcreator);
    /// @notice Emitted when marketor grant
    /// @param _marketor who will be seted to marketor
    /// @param _auths the priv which be grant
    event e_addauths(address _marketor, uint256 _auths);
    /// @notice Emitted when marketor be remove
    /// @param _marketor who will be remove from marketor
    event e_removeauths(address _marketor);
    /// @notice Emitted when limitorder is dealed
    /// @param _orderid the id of the limit order
    event e_takeOrder(uint256 _orderid);

    /// @notice Emitted when limitorder is dealed
    /// @param _orderid the id of the limit order
    /// @param amount the id of the limit order
    event e_takeOrderChips(uint256 _orderid, uint256 amount);
    /// @notice Emitted when limitorder is removed by marketor when order unvalid over time
    /// @param _orderids the ids of the limit order
    event e_cleandeadorders(uint256[] _orderids);
    /// @notice Emitted when limitorder is removed by marketor when order unvalid over time
    /// @param _orderid the ids of the limit order
    /// @param _feeamount fee amount
    /// @param _reciver the recieve of fee
    event e_cleandeadorder(
        uint256 _orderid,
        uint256 _feeamount,
        address _reciver
    );
    /// @notice Emitted when limitorder's  removed by it's owner
    /// @param _orderid the ids of the limit order
    event e_removeLimitOrder(uint256 _orderid);
    /// @notice Emitted when limitorder's  removed by it's owner
    /// @param _orderid the ids of the limit order
    /// @param _fromerc20 from erc20
    /// @param _toerc20  to achive the erc20 token
    /// @param _amount fitst 128bit is the from amount,last 128 bit is the to amount
    event e_updateLimitOrder(
        uint256 _orderid,
        address _fromerc20,
        address _toerc20,
        uint256 _amount
    );
    event e_deploy(address marketcreator, uint256 maxfreeremain, uint256);
    event e_addmaxslot(uint256);
    /// @notice Emitted actual mount under the pridicate amount
    /// @param _orderid orderid
    error lessAmountError(uint256 _orderid);
    /// @notice User add limitorder
    /// @param _orders order's detail
    function addLimitOrder(S_orderDetails[] memory _orders) external;

    /// @notice owner update his limit order
    /// @param _orderid order'sid
    /// @param _order order's detail
    function updateLimitOrder(
        uint256 _orderid,
        S_orderDetails memory _order
    ) external;

    /// @notice owner remove his limit order
    /// @param _orderid order'sid
    function removeLimitOrder(uint256 _orderid) external;
    function takeLimitOrderChips(S_OrderChip[] memory _orderChips) external;
    /// @notice normally take the limit order
    /// @param _orderids orders' id
    function takeLimitOrderNormal(S_TakeParams[] memory _orderids) external;

    /// @notice amm take the limit order
    /// @param _orderid order's id
    /// @param _tolerance the caller's tolerance config
    /// @param _takecontract  the amm's address
    /// @param _takecaller  the caller address
    function takeLimitOrderAMM(
        uint256 _orderid,
        uint96 _tolerance,
        I_TTSwap_LimitOrderTaker _takecontract,
        address _takecaller
    ) external returns (bool _isSuccess);

    /// @notice amm take the limit order
    /// @param _orderids orders' id
    /// @param _tolerance the caller's tolerance config
    /// @param _takecontract  the amm's address
    /// @param _takecaller  the caller address
    /// @param _isall   true:must all be deal
    function takeBatchLimitOrdersAMM(
        uint256[] memory _orderids,
        uint96 _tolerance,
        I_TTSwap_LimitOrderTaker _takecontract,
        address _takecaller,
        bool _isall
    ) external returns (bool[] memory);

    /// @notice get limit order's infor
    /// @param _ordersids orders' id
    function queryLimitOrder(
        uint256[] memory _ordersids
    ) external view returns (S_orderDetails[] memory _orderdetail);
    struct S_TakeParams {
        uint256 orderid;
        bytes transdata;
    }
    struct S_orderDetails {
        uint96 timestamp;
        address sender;
        address fromerc20;
        address toerc20;
        uint256 amount; //first 128bit is amount0(),last 128bit is amount.amount1()
    }

    struct S_OrderChip {
        uint256 orderid;
        uint128 takeamount;
        bytes transdata;
    }
}
