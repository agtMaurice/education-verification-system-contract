# Build an Educational Credential Verification System On the Celo Blockchain
---
title: Build an Educational Credential Verification System On the Celo Blockchain
description: In this tutorial, you will learn how to build a system to verify educational credentials on the blockchain
authors:
  - name: ✍️ Agatha Maurice
    url: https://github.com/agtMaurice
---

#  Table of Content

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Tool used in this course](#tools)
- [Getting wallet Ready](#getting-wallet-ready)
- [Smart Contract](#smart-contract)
- [Deployment](#deployment)
- [Conclusion](#conclusion)
- [Next Step](#next-step)

## Introduction

Welcome to this DIY course where you will learn how to develop an educational credential verification system using the Celo Blockchain. This tutorial will guide you through the process of using blockchain technology to securely store, validate, and verify educational credentials like certificates, diplomas, and degrees. You will gain the necessary skills to create and deploy your educational credential verification system, and comprehend the advantages of using blockchain technology for this purpose. By the end of this course, you'll be able to build a reliable educational credential verification system for your own purposes.

[Full source code](https://github.com/agtMaurice/education-verification-system-contract.git)

## Prerequisites

To follow this tutorial, you will need a basic knowledge of Solidity programming language and a Development Environment Like Remix

## Tools
  - [nodejs](https://nodejs.org/en/download)
  - Google Chrome
  - 
  - [The celo Extension Wallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en)

## Getting wallet Ready

We have to get our wallet ready for deplloyment of the contract;

- Click on the celo wallet extension on your browser(preferably chrome) and you can either create a new wallet or import with a seed phrase (Note: The seed phrase is important, you should keep it to yourself as it can give other full control to your wallet).
- Hopefully you are done with either creating the wallet or importing one(if you had a wallet previously that you still know the seed phrase), cgot to the [Faucet](https://faucet.celo.org/alfajores) website to get test celo dollar(cUSD)


## Smart Contract

Let's begin writing our smart contract in Remix IDE

The completed code Should look like this.

```solidity
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
        bytes32 institution;
        bytes32 degree;
        bytes32 major;
        bytes32 studentName;
        uint32 dateIssued;
    }

    mapping(uint256 => Credential) public credentials;
    Counters.Counter private _tokenIds;

    event CredentialIssued(uint256 indexed tokenId, bytes32 studentName, bytes32 degree, bytes32 major, bytes32 institution, uint32 dateIssued);
    event CredentialRevoked(uint256 indexed tokenId);

    constructor() ERC721("EducationCredential", "EDUC") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function issueCredential(
        bytes32 institution,
        bytes32 degree,
        bytes32 major,
        bytes32 studentName,
        uint32 dateIssued,
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
            dateIssued
        );

        credentials[tokenId] = newCredential;

        emit CredentialIssued(tokenId, studentName, degree, major, institution, dateIssued);
    }

    function revokeCredential(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        require(_exists(tokenId), "Credential not found");

        delete credentials[tokenId];

        emit CredentialRevoked(tokenId);
    }

    function isCredentialValid(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && credentials[tokenId].dateIssued != 0;
    }

    function getCredential(uint256 tokenId) public view returns (Credential memory) {
        require(_exists(tokenId), "Credential not found");

        return credentials[tokenId];
    }

    function grantIssuerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ISSUER_ROLE, account);
    }

    function revokeIssuerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ISSUER_ROLE, account);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}


```

### Breakdown

First, we declared our license and the solidity version. then we import all the neccessary openzeppelin contracts

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
```

The `EducationCredentialVerification` contract extends the `ERC-721` token standard. `ERC-721` is a standard for creating unique, non-fungible tokens on the Celo blockchain. In this contract, we will use `ERC-721` to create unique educational credentials for students.

The `AccessControl` library is also imported and utilized in the `EducationCredentialVerification` contract. `AccessControl` allows us to define roles for various participants in the system. In this contract, we define the `ISSUER_ROLE` which is granted to educational institutions that are authorized to issue credentials.

```solidity
contract EducationCredentialVerification is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    struct Credential {
        uint256 tokenId;
        bytes32 institution;
        bytes32 degree;
        bytes32 major;
        bytes32 studentName;
        uint32 dateIssued;
    }

    mapping(uint256 => Credential) public credentials;
    Counters.Counter private _tokenIds;
}
```

`ISSUER_ROLE`: This is a bytes32 constant variable that defines the name of the role granted to educational institutions that are authorized to issue credentials.

We created a struct `Credential`, which is used to store the details of each educational credential. The Credential struct has the following attributes:

- `tokenId`: A unique identifier for the educational credential.
  institution: The name of the educational institution that issued the credential.
- `degree`: The degree earned by the student.
  major: The student's area of study.
- `studentName`: The name of the student who earned the credential.
  dateIssued: The date the credential was issued.

A mapping `credentials` is used to store the credentials issued by educational institutions. The keys in the mapping are the `tokenIds` of the educational credentials, and the values are instances of the Credential struct.

We then use the Counters library to manage the unique `tokenId` assigned to each educational credential.

```solidity
event CredentialIssued(uint256 indexed tokenId, string studentName, string degree, string major, string institution, uint256 dateIssued);
event CredentialRevoked(uint256 indexed tokenId);
```

The contract emits two events:

- `CredentialIssued`: This event is emitted when an educational credential is issued.
- `CredentialRevoked`: This event is emitted when an educational credential is revoked.

```solidity
constructor() ERC721("EducationCredential", "EDUC") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
```

The constructor sets up the default admin role and initializes the `ERC-721` token by setting its name to `EducationCredential` and its symbol to `EDUC`.

```solidity
function issueCredential(
        bytes32 institution,
        bytes32 degree,
        bytes32 major,
        bytes32 studentName,
        uint32 dateIssued,
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
            dateIssued
        );

        credentials[tokenId] = newCredential;

        emit CredentialIssued(tokenId, studentName, degree, major, institution, dateIssued);
    }
```

The `issueCredential` function is used by educational institutions to issue educational credentials. The function takes in several arguments, including the name of the institution, the degree earned by the student, the major of the student, the name of the student, the date the credential was issued, and the recipient address.

The function then creates a new unique `tokenId` using the Counters library, mints a new `ERC-721` token using the `_safeMint` function, and assigns the token to the recipient address. Finally, the function creates a new instance of the Credential struct, stores it in the credentials mapping, and emits the `CredentialIssued` event.

```solidity
  function revokeCredential(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        require(_exists(tokenId), "Credential not found");

        delete credentials[tokenId];

        emit CredentialRevoked(tokenId);
    }
```

This code defines a function called `revokeCredential` that takes in a single argument called `tokenId` of type `uint256`. 

The function is marked as `public` which means it can be called from outside the contract. It also has the modifier `onlyRole(ISSUER_ROLE)` which restricts access to users who have been granted the `ISSUER_ROLE` role in the contract. 

The first line of the function checks if the credential with the given `tokenId` exists using the `_exists` function provided by the OpenZeppelin ERC721 implementation. If the credential doesn't exist, it throws an error with the message "Credential not found" using the `require` statement.

The second line of the function deletes the credential from the `credentials` mapping using the `delete` keyword. This sets all values of the `Credential` struct to their default value, effectively removing the credential from storage. 

Finally, the function emits an event called `CredentialRevoked` with the `tokenId` as an argument to notify any listeners that the credential has been revoked.

```solidity
function isCredentialValid(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && credentials[tokenId].dateIssued != 0;
    }
```

This code defines a function called `isCredentialValid`. The function takes one input parameter, which is an unsigned integer called `tokenId`. 

The function is defined as a `public` function, which means anyone can call it. It is also defined as a `view` function, which means that it will not change the state of the blockchain when it is called. 

The function returns a boolean value, either `true` or `false`, depending on whether the given `tokenId` represents a valid credential or not. 

The function checks two conditions using the `&&` operator:
- The first condition is `_exists(tokenId)`, which calls an OpenZeppelin function to check if the token exists on the blockchain. If the token does not exist, the function returns `false`.
- The second condition is `credentials[tokenId].dateIssued != 0`, which checks if the dateIssued attribute of the credential stored at the given `tokenId` is not equal to zero. If the dateIssued is not equal to zero, then the function returns `true`, indicating that the credential is valid. If the dateIssued is equal to zero, then the function returns `false`, indicating that the credential is not valid.
```solidity
function getCredential(uint256 tokenId) public view returns (Credential memory) {
        require(_exists(tokenId), "Credential not found");

        return credentials[tokenId];
    }
```

The `getCredential` function is used to retrieve the details of a given educational credential. The function takes in a `tokenId` and checks if the corresponding credential exists. If it does, the function returns the corresponding `Credential` struct.

```solidity
function grantIssuerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    grantRole(ISSUER_ROLE, account);
    }

function revokeIssuerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(ISSUER_ROLE, account);
    }
```

The `grantIssuerRole` and `revokeIssuerRole` functions are used to grant or revoke the `ISSUER_ROLE` to an educational institution. These functions can only be called by the contract's `DEFAULT_ADMIN_ROLE`, which is set to the address that deployed the contract.

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
```

The `supportsInterface` function is used to check if the `EducationCredentialVerification` contract supports the `ERC-721` and `AccessControl` interfaces.

## Deployment

To deploy our smart contract successfully, we need the celo extention wallet which can be downloaded from [here](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en)

Next, we need to fund our newly created wallet which can done using the celo alfojares faucet [Here](https://celo.org/developers/faucet)

Now, click on the plugin logo at the bottom left corner and search for celo plugin.

Install the plugin and click on the celo logo which will show in the side tab after the plugin is installed.

Next connect your celo wallet, select the contract you want to deploy and finally click on deploy to deploy your contract.

## Conclusion

The `EducationCredentialVerification` contract provides a way for educational institutions to issue and verify educational credentials on the blockchain. By using the `ERC-721` token standard and the `AccessControl` library, the contract allows for the creation of unique and verifiable educational credentials. The contract also allows for the granting and revoking of roles to educational institutions.

## Next Step

I hope you learned a lot from this tutorial. Here are some relevant links that would aid your learning further.

- [Celo Docs](https://docs.celo.org/)
- [Solidity Docs](https://docs.soliditylang.org/en/v0.8.17/)
