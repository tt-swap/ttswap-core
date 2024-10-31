// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface I_TTSwap_LimitOrderMaker {
    event e_addLimitOrder(
        uint256 orderid,
        address sender,
        address fromerc20,
        address toerc20,
        uint256 amount
    );
    event e_setmaxfreeremain(uint96 maxfreeremain);
    event e_changemarketcreator(address newmarketcreator);
    event e_addauths(address _marketor, uint256 _auths);
    event e_removeauths(address _marketor);
    event e_takeOrder(uint256 orderid);
    event e_deletedeadorders(uint256[] orderids);
    event e_deletedeadorder(
        uint256 orderid,
        uint256 feeamount,
        address reciver
    );
    event e_removeLimitOrder(uint256);
    event e_updateLimitOrder(address, address, address, uint256);
    error lessAmountError(uint256);
    function addLimitOrder(S_orderDetails[] memory _orders) external;
    function updateLimitOrder(
        uint256 orderid,
        S_orderDetails memory _order
    ) external;

    function removeLimitOrder(uint256 orderid) external;

    function takeLimitOrderNormal(uint256[] memory orderids) external;

    function takeLimitOrdersAMM(
        uint256[] memory orderids,
        uint96 _tolerance,
        address _taker
    ) external returns (bool);

    function queryLimitOrder(
        uint256[] memory _ordersids
    ) external view returns (S_orderDetails[] memory _orderdetail);
}
struct S_orderDetails {
    uint96 timestamp;
    address sender;
    address fromerc20;
    address toerc20;
    uint256 amount; //first 128bit is amount0(),last 128bit is amount.amount1()
}
