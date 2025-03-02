// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Permit {
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory sig
    ) external;
}
