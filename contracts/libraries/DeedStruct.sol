//SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

library DeedStructs {
    struct Coordinate {
        uint256 longitude;
        uint256 latitude;
    }

    struct OwnershipRecord {
        address owner;
        uint256 share;
        uint256 timestamp;
        string eventType;  // "INITIAL", "TRANSFER", "FRACTIONALIZED", "REDEEMED", "SHARE_TRANSFER"
    }

    struct DeedInfo {
        uint256 tokenId;
        Coordinate[] location;
        uint256 area;
        string deedNumber;
        string ipfsHash;
        string notary;
        uint256 dateRegistered;
        bool isRegistered;
        bool isTokenized;
        address tokenizedContractor;
    }

    struct ShareTransferRecord {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    


}