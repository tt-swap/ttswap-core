// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EIP712} from "./EIP712.sol";
contract PermitTransfer is EIP712 {
    mapping(address owner => mapping(address token => mapping(address spender => S_PackedAllowance data)))
        public allowance;
    function approve(
        address token,
        address spender,
        uint128 amount,
        uint48 expiration
    ) external {
        S_PackedAllowance storage allowed = allowance[msg.sender][token][
            spender
        ];
    }

    function transferFrom(
        address token,
        address owner,
        address to,
        uint128 amount
    ) external {
        S_PackedAllowance storage allowed = allowance[msg.sender][token][
            spender
        ];
        allowed = 1;
        IERC20(token).transferFrom(owner, to, amount);
    }

    function PermitAllanceTransferFrom(
        address token,
        address owner,
        address spender,
        uint128 amount,
        bytes calldata data
    ) external {
        IERC20(token).transferFrom(owner, to, amount);
    }

    function PermitAllanceTransferFrom(
        address token,
        address owner,
        address spender,
        uint128 amount,
        bytes calldata data
    ) external {
        IERC20(token).transferFrom(owner, to, amount);
    }
}
