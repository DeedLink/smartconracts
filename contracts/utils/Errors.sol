// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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
    error InvalidAddress(address addr);
    error InvalidAppraisalValue(uint256 appraisalValue); //used in DeedNFT
    //used in DeedNFT
    error InvalidArea(uint256 area); //used in DeedNFT
    error InvalidAmount();
    error InvalidTokenId();
    error InvalidTokenURI();
    error InvalidSignature();
    error InvalidMerkleProof();
    error InvalidMerkleRoot();
    error InvalidMerkleLeaf();
    error InvalidDeedInfo();
    error InvalidDeedLocation();
    error InvalidOwnershipRecord();
    error InvalidShareTransferRecord();
    error InvalidDeedShareToken();
    error DeedAlreadyRegistered();
    error DeedAlreadyTokenized();//used in DeedNFT
    error DeedNotRegistered();
    error DeedTokenNotFound();
    error DeedDoesNotTokenized(uint256 tokeId); //used in DeedNFT
    error DeedDoesNotExist(); //used in DeedNFT
    error EmptyLocation(); //used in DeedNFT
    error Unauthorized(address caller);
    error ZeroAddressNotAllowed();//used in DeedNFT
    error InvalidPercentage(uint256 share);//used in DeedNFT


} 

