// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EducationCredentialVerification is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    struct Credential {
        uint256 tokenId;
        string institution;
        string degree;
        string major;
        string studentName;
        uint256 dateIssued;
        bool isRevoked;
    }

    mapping(uint256 => Credential) public credentials;
    Counters.Counter private _tokenIds;

    event CredentialIssued(
        uint256 indexed tokenId,
        string studentName,
        string degree,
        string major,
        string institution,
        uint256 dateIssued
    );
    event CredentialRevoked(uint256 indexed tokenId);

    constructor() ERC721("EducationCredential", "EDUC") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function issueCredential(
        string memory institution,
        string memory degree,
        string memory major,
        string memory studentName,
        uint256 dateIssued,
        address recipient
    ) public onlyRole(ISSUER_ROLE) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(recipient, tokenId);

        Credential memory newCredential = Credential(
            tokenId,
            institution,
            degree,
            major,
            studentName,
            dateIssued,
            false
        );

        credentials[tokenId] = newCredential;

        emit CredentialIssued(
            tokenId,
            studentName,
            degree,
            major,
            institution,
            dateIssued
        );
    }

    function revokeCredential(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        require(_exists(tokenId), "Credential not found");

        credentials[tokenId].isRevoked = true;

        emit CredentialRevoked(tokenId);
    }

    function isCredentialValid(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && !credentials[tokenId].isRevoked;
    }

    function getCredential(
        uint256 tokenId
    ) public view returns (Credential memory) {
        require(_exists(tokenId), "Credential not found");

        return credentials[tokenId];
    }

    function grantIssuerRole(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ISSUER_ROLE, account);
    }

    function revokeIssuerRole(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ISSUER_ROLE, account);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
