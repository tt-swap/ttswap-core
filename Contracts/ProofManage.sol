// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "./interfaces/I_Proof.sol";
import "./interfaces/IERC721Permit.sol";
import {S_ProofKey} from "./libraries/L_Struct.sol";
import {L_Proof, L_ProofIdLibrary} from "./libraries/L_Proof.sol";
import {L_ArrayStorage} from "./libraries/L_ArrayStorage.sol";
import {Counters} from "./libraries/Counters.sol";

import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

abstract contract ProofManage is
    I_Proof,
    Context,
    ERC165,
    IERC721Permit,
    EIP712
{
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
    mapping(uint256 => L_Proof.S_ProofState) internal proofs;
    mapping(address => L_ArrayStorage.S_ArrayStorage) internal ownerproofs;
    mapping(bytes32 => uint256) public proofseq;
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

    constructor() EIP712(_NFTname, "1") {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Permit).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 proofId
    ) external view onlyOwner(proofId) returns (string memory) {
        return
            string.concat(
                "http://www.tt-swap.com/nft721?id=",
                proofId.toString()
            );
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `proofId`. Empty
     * by default, can be overridden in child contracts.
     */

    function balanceOf(address owner) external view returns (uint256) {
        return ownerproofs[owner].key;
    }

    function ownerOf(uint256 proofId) public view returns (address) {
        return proofs[proofId].owner;
    }

    function tokenByIndex(uint256 _index) external pure returns (uint256) {
        return _index;
    }

    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    ) external view returns (uint256) {
        return ownerproofs[_owner].key_value[_index];
    }

    /// @inheritdoc I_Proof
    function getProofId(
        S_ProofKey calldata _investproofkey
    ) external view override returns (uint256 proof_) {
        proof_ = proofseq[_investproofkey.toId()];
    }

    function name() external pure returns (string memory) {
        return _NFTname;
    }

    function symbol() external pure returns (string memory) {
        return _NFTsymbol;
    }

    function approve(
        address to,
        uint256 proofId
    ) external onlyApproval(proofId) {
        proofs[proofId]._approve(to);
        emit Approval(msg.sender, to, proofId);
    }

    function getApproved(uint256 proofId) public view returns (address) {
        return proofs[proofId].approval;
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 proofid
    ) public onlyApproval(proofid) {
        _nonces[proofid].increment();
        ownerproofs[from].removevalue(proofid);
        ownerproofs[to].addvalue(proofid);
        proofs[proofid].owner = to;
        proofs[proofid].approval = address(0);
        proofs[proofid].beneficiary = address(0);
        emit Transfer(from, to, proofid);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 proofid
    ) external {
        safeTransferFrom(from, to, proofid, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /// @inheritdoc I_Proof
    function getProofState(
        uint256 _proof
    ) external view override returns (L_Proof.S_ProofState memory proof_) {
        proof_.owner = proofs[_proof].owner;
        proof_.currentgood = proofs[_proof].currentgood;
        proof_.state = proofs[_proof].state;
        proof_.invest = proofs[_proof].invest;
        if (proofs[_proof].valuegood > 0) {
            proof_.valuegood = proofs[_proof].valuegood;
            proof_.valueinvest = proofs[_proof].valueinvest;
        }
    }

    /// @inheritdoc I_Proof
    function changeProofOwner(
        uint256 _proofid,
        address _to
    ) external override returns (bool) {
        require(
            msg.sender == proofs[_proofid].owner ||
                msg.sender == proofs[_proofid].approval,
            "P1"
        );
        proofs[_proofid].owner = _to;
        return true;
    }
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
            signer == proofs[tokenId].approval;

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
