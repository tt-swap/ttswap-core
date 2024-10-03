// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_NFT {
    function mint(address recipent, uint256 tokenid) external;
    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external returns (bool);
    function burn(uint256 tokenId) external;
}
