// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
interface I_SimplePermit {
    function transferFrom(
        address token,
        address owner,
        address spender,
        uint128 amount
    ) external;
    function PermitAllanceTransferFrom(
        address token,
        address owner,
        address spender,
        uint128 amount,
        bytes memory data
    ) external;
    function PermitTransferFrom(
        address token,
        address owner,
        address spender,
        uint128 amount,
        bytes memory detail
    ) external;
    struct SimplePermit {
        uint8 transfertype;
        bytes detail;
    }

    struct S_PackedAllowance {
        uint128 amount;
        uint48 expiration;
        uint48 deadline;
        uint48 nonce;
    }
    struct s_permit {
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}
