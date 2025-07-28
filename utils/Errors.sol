// SPDX-License-Identifier: MIT
pragma solidity version^0.8.0;

library Errors {
    // This library defines custom error messages for the contract. These will be updated
    error NotOwner();
    error NotAdmin();
    error NotOperator();
    error NotMinter();
    error NotPauser();
    error NotBurner();
    error NotTransferer();
    error NotWhitelisted();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidTokenId();
    error InvalidTokenURI();
    error InvalidSignature();
    error InvalidMerkleProof();
    error InvalidMerkleRoot();
    error InvalidMerkleLeaf();
}