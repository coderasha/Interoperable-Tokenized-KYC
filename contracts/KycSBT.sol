// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title KYC Soulbound Token (SBT) - tokenised KYC attestation
/// @notice Non-transferable token representing a KYC attestation. Only authorized issuers can mint/revoke.
contract KycSBT is ERC721, AccessControl {
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    uint256 private _nextId;

    // tokenId => revoked
    mapping(uint256 => bool) public revoked;

    // tokenId => metadata hash (for off-chain data, e.g., IPFS hash or document hash)
    mapping(uint256 => string) public metadataHash;

    event Issued(address indexed to, uint256 indexed tokenId, string metadataHash);
    event Revoked(uint256 indexed tokenId);

    constructor(address admin) ERC721("KYC Soulbound", "KYC-SBT") {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(ISSUER_ROLE, admin);
        _nextId = 1;
    }

    /// @notice Issue a soulbound token to `to` with associated `metadataHash`.
    function issue(address to, string calldata _metadataHash) external onlyRole(ISSUER_ROLE) returns (uint256) {
        uint256 tokenId = _nextId++;
        _safeMint(to, tokenId);
        metadataHash[tokenId] = _metadataHash;
        emit Issued(to, tokenId, _metadataHash);
        return tokenId;
    }

    /// @notice Revoke a KYC token (mark invalid)
    function revoke(uint256 tokenId) external onlyRole(ISSUER_ROLE) {
        require(_exists(tokenId), "Token does not exist");
        revoked[tokenId] = true;
        emit Revoked(tokenId);
    }

    /// @notice Override transfer functions to disable transfers (soulbound)
    function _transfer(address, address, uint256) internal pure override {
        revert("SBT: transfer disabled");
    }

    function approve(address, uint256) public pure override {
        revert("SBT: approval disabled");
    }

    function setApprovalForAll(address, bool) public pure override {
        revert("SBT: approval disabled");
    }

    /// @notice helper to check validity
    function isValid(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && !revoked[tokenId];
    }
}
