// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTSwap_NFT {
    /**
     * @dev mint nft for recipent
     * @param recipent who is  the tokenid  minted the tokenid for .
     * @param tokenid the tokenid.
     */
    function mint(address recipent, uint256 tokenid) external;
    /**
     * @dev record which contract is storing the tokenid
     * @param tokenid The current owner of the token.
     * @return cd the contract address of tokenid
     */
    function proofsource(uint256 tokenid) external view returns (address cd);
    /**
     * @dev get the token  approved to the spender
     * @param spender who
     * @param tokenId The new owner.
     * @return result
     */
    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external returns (bool result);

    /**
     * @dev burn tokenid
     * @param tokenId which tokenid will be burned.
     */
    function burn(uint256 tokenId) external;
    /**
     * @dev Safely transfers the ownership of a given token ID to another address with a permit.
     * @param from The current owner of the token.
     * @param to The new owner.
     * @param tokenId The ID of the token to be transferred.
     * @param _data Additional data with no specified format.
     * @param deadline The time at which the signature expires.
     * @param signature A valid EIP712 signature.
     */
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;
}
