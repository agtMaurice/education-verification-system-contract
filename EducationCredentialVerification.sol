// SPDX-License-Identifier: MIT  --> specifies the license for the contract
pragma solidity ^0.8.0;

// Import OpenZeppelin contracts for ERC721 tokens and access control
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EducationCredentialVerification is ERC721, AccessControl {
    // Use the Counters library to generate unique token IDs
    using Counters for Counters.Counter;

    // Define a constant role for issuers of credentials
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    // Define a struct to hold the details of a credential
    struct Credential {
        uint256 tokenId;
        string institution;
        string degree;
        string major;
        string studentName;
        uint256 dateIssued;
        bool isRevoked;
    }

    // Map token IDs to credential details
    mapping(uint256 => Credential) public credentials;

    // Create a counter to keep track of token IDs
    Counters.Counter private _tokenIds;

    // Event emitted when a credential is issued
    event CredentialIssued(uint256 indexed tokenId, string studentName, string degree, string major, string institution, uint256 dateIssued);

    // Event emitted when a credential is revoked
    event CredentialRevoked(uint256 indexed tokenId);

    // Constructor function to set up the contract
    constructor() ERC721("EducationCredential", "EDUC") {
        // Grant the default admin role to the contract creator
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // Function to issue a new credential
    function issueCredential(
        string memory institution,
        string memory degree,
        string memory major,
        string memory studentName,
        uint256 dateIssued,
        address recipient
    ) public onlyRole(ISSUER_ROLE) {
        // Generate a new token ID
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        // Mint a new token and assign it to the recipient
        _safeMint(recipient, tokenId);

        // Create a new Credential struct with the given details
        Credential memory newCredential = Credential(
            tokenId,
            institution,
            degree,
            major,
            studentName,
            dateIssued,
            false
        );

        // Map the token ID to the new credential
        credentials[tokenId] = newCredential;

        // Emit an event indicating that the credential was issued
        emit CredentialIssued(tokenId, studentName, degree, major, institution, dateIssued);
    }

    // Function to revoke a credential
    function revokeCredential(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        // Make sure the credential exists
        require(_exists(tokenId), "Credential not found");

        // Set the "isRevoked" flag to true
        credentials[tokenId].isRevoked = true;

        // Emit an event indicating that the credential was revoked
        emit CredentialRevoked(tokenId);
    }

    // Function to check if a credential is still valid
    function isCredentialValid(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && !credentials[tokenId].isRevoked;
    }

    // Function to get the details of a credential
    function getCredential(uint256 tokenId) public view returns (Credential memory) {
        // Make sure the credential exists
        require(_exists(tokenId), "Credential not found");

        // Return the credential details
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
