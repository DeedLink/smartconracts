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
    error InvalidAddress(address addr); // Used
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
    error DeedAlreadyTokenized();//used in DeedNFT
    error DeedNotRegistered();
    error DeedTokenNotFound();
    error DeedDoesNotTokenized(uint256 tokeId); //used in DeedNFT
    error DeedDoesNotExist(); //used in DeedNFT
    error EmptyLocation(); //used in DeedNFT
    error Unauthorized(address caller);
    error InvalidPercentage(uint256 share);//used in DeedNFT
    error ZeroAddressNotAllowed(); // Used
    error InvalidTotalShares(uint256 _totalShares); // Used
    error InvalidDeedTokenId(uint _deedTokenId); // Used
    error ZeroAmount(); // Used
    error InsufficientShares(uint256 requested, uint256 available); // Used
    error NotAuthorizedRegistrar(address registrar); // Used
    error InvalidRegistryIndex(uint256 index); // Used
    error DeedAlreadyRegistered(uint256 deedNumber); // Used
    error RegistrarAlreadyAuthorized(address registrar); // Used
    error InvalidAppraisalValue(uint256 value); // Used
    error InvalidArea(uint256 area); // Used
}
