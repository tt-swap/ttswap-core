// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./interfaces/I_Proof.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {ERC721Permit} from "./libraries/L_Struct.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {L_ArrayStorage} from "./libraries/L_ArrayStorage.sol";
import {Counters} from "./libraries/Counters.sol";

abstract contract ProofManage is I_Proof, ERC721Permit {
    using L_Proof for *;
    using Strings for uint256;
    using Counters for Counters.Counter;
    using L_ProofIdLibrary for S_ProofKey;
    using L_ArrayStorage for L_ArrayStorage.S_ArrayStorage;

    //Token name
    string private constant _NFTname = "TTS NFT";

    // Token symbol
    string private constant _NFTsymbol = "TTS";
    uint256 public override totalSupply;
    mapping(uint256 => L_Proof.S_ProofState) public proofs;
    mapping(address owner => mapping(address operator => bool))
        private _operatorApprovals;
    mapping(uint256 => Counters.Counter) private _nonces;
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );

    // solhint-disable-next-line var-name-mixedcase

    modifier onlyOwner(uint256 proofid) {
        require(proofs[proofid].owner == msg.sender, "only owner");
        _;
    }
    modifier onlyApproval(uint256 proofid) {
        require(
            proofs[proofid].owner == msg.sender ||
                proofs[proofid].approval == msg.sender,
            "only approval"
        );
        _;
    }

    constructor() EIP712(_NFTname, "1") ERC721("TTS NFT", "TTS") {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Permit).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function _baseURI() internal view override returns (string memory) {
        return "http://www.tt-swap.com/nft?proofid=";
    }

    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 proofid
    // ) public onlyApproval(proofid) {
    //     _nonces[proofid].increment();
    //     proofs[proofid].owner = to;
    //     proofs[proofid].approval = address(0);
    //     proofs[proofid].beneficiary = address(0);
    //     emit Transfer(from, to, proofid);
    // }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    // revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    //   revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
    function nonces(
        uint256 tokenId
    ) external view virtual override returns (uint256) {
        return _nonces[tokenId].current();
    }

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external override {
        _permit(spender, tokenId, deadline, signature);
    }

    function _permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) internal virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC721Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                spender,
                tokenId,
                _nonces[tokenId].current(),
                deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);

        (address signer, , ) = ECDSA.tryRecover(hash, signature);
        bool isValidEOASignature = signer != address(0) &&
            signer == proofs[tokenId].approval &&
            signer == proofs[tokenId].owner;

        require(
            isValidEOASignature ||
                _isValidContractERC1271Signature(
                    ownerOf(tokenId),
                    hash,
                    signature
                ) ||
                _isValidContractERC1271Signature(
                    getApproved(tokenId),
                    hash,
                    signature
                ),
            "ERC721Permit: invalid signature"
        );
        proofs[tokenId]._approve(spender);
    }

    function _isValidContractERC1271Signature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) private view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(
                IERC1271.isValidSignature.selector,
                hash,
                signature
            )
        );
        return (success &&
            result.length == 32 &&
            abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external override {
        _permit(msg.sender, tokenId, deadline, signature);
        safeTransferFrom(from, to, tokenId, _data);
    }
}
