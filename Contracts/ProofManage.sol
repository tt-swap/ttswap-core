// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import "./interfaces/I_Proof.sol";
import {T_ProofId, L_ProofIdLibrary} from "./types/T_ProofId.sol";
import {S_ProofKey, S_ProofState} from "./types/S_ProofKey.sol";
import {L_Proof} from "./libraries/L_Proof.sol";
import {Strings} from "./libraries/Strings.sol";
import {Address} from "./libraries/Address.sol";

abstract contract ProofManage is I_Proof {
    using L_ProofIdLibrary for S_ProofKey;
    using L_Proof for *;
    using L_ProofIdLibrary for S_ProofKey;
    using Strings for uint256;
    using Address for address;
    // Token name

    string private _name;

    // Token symbol
    string private _symbol;
    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    uint256 prooftotal;
    mapping(bytes4 => bool) public _supportedInterfaces;
    mapping(T_ProofId id => S_ProofState) public proofs;
    mapping(address => T_ProofId[]) public _ownerproofs;
    mapping(uint256 => address) public _proofapproval;
    mapping(address => mapping(address => bool)) public _operatorApprovals;
    mapping(uint256 => T_ProofId) public proofnum;

    constructor() {
        _name = "TTS-Proof NFT";
        _symbol = "TTSP";
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function getProofId(
        S_ProofKey calldata investproofkey
    ) external pure returns (T_ProofId _proof) {
        _proof = investproofkey.toId();
    }

    function getProofState(
        T_ProofId _proof
    ) external view override returns (S_ProofState memory proof_) {
        proof_.owner = proofs[_proof].owner;
        proof_.currentgood = proofs[_proof].currentgood;
        proof_.valuegood = proofs[_proof].valuegood;
        proof_.state = proofs[_proof].state;
        proof_.invest = proofs[_proof].invest;
        proof_.valueinvest = proofs[_proof].valueinvest;
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function changeProofOwner(
        T_ProofId _proofid,
        address to
    ) external override returns (bool) {
        require(msg.sender == proofs[_proofid].owner, "");
        proofs[_proofid].owner = to;
        return true;
    }

    function changeProofOwnerWithPermit() external {}

    function approve(address to, uint256 tokenId) external override {
        require(
            proofs[T_ProofId.wrap(bytes32(tokenId))].owner == msg.sender,
            ""
        );
        _proofapproval[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId);
    }

    function _ownerOf(uint256 tokenId) internal view returns (address owner) {
        return proofs[T_ProofId.wrap(bytes32(tokenId))].owner;
    }

    function ownerOf(
        uint256 tokenId
    ) external view override returns (address owner) {
        return proofs[T_ProofId.wrap(bytes32(tokenId))].owner;
    }

    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {
        return _ownerproofs[owner].length;
    }

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory proofid) {
        proofid = Strings.toString(T_ProofId.unwrap(proofnum[tokenId]));
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal  {
        require(
            _ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        proofs[T_ProofId.wrap(bytes32(tokenId))].owner = to;

        emit Transfer(from, to, tokenId);
    }

    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    function _mint(address to, uint256 tokenId) internal  {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _ownerproofs[to].push(T_ProofId.wrap(bytes32(tokenId)));
        emit Transfer(address(0), to, tokenId);
    }

    function _approve(address to, uint256 tokenId) private {
        _proofapproval[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return
            proofs[T_ProofId.wrap(bytes32(tokenId))].owner == address(0)
                ? false
                : true;
    }

    function _burn(uint256 tokenId) internal {
        address owner = proofs[T_ProofId.wrap(bytes32(tokenId))].owner;
        require(owner == msg.sender, "");
        // Clear approvals
        _approve(address(0), tokenId);

        //待处理
        // _ownerproofs[owner].remove(tokenId);

        delete proofs[T_ProofId.wrap(bytes32(tokenId))];

        emit Transfer(owner, address(0), tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public  override {
 
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = proofs[T_ProofId.wrap(bytes32(tokenId))].owner;
        return (spender == owner ||
            _proofapproval[tokenId] == spender ||
            isApprovedForAll(owner, spender));
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function getApproved(
        uint256 tokenId
    ) public view override returns (address) {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _proofapproval[tokenId];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(
            abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                msg.sender,
                from,
                tokenId,
                _data
            ),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
}
