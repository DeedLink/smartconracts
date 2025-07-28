// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Deedstructs{

    // Structures
    struct Coordinate {
        uint256 longitude;
        uint256 latitude;  
    }

    struct OwnershipRecord {
        address owner;
        uint256 share;
        uint256 timestamp;
        string eventType;
    }

    struct DeedInfo {
        uint256 tokenId;
        Coordinate[] locations;
        uint256 area;
        string deedNumber;
        string ipfHash;
        string notary;
        uint256 dataRegistered;
        uint256 appraisalValue;
        bool isRegistered;
        bool isTokenized;
        address tokenizedContract;
    }

    struct ShareTransferRecord {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        //string transferType; // "sale", "gift", "inheritance"
    }

    struct RegistryEntry {
        uint256 deedTokenId;
        address shareTokenAddress;
        bool isActive;
        uint256 createAt;
    }

    // Events
    event DeedRegistered(uint256 indexed tokenId, address indexed owner, uint256 appraisalValue);
    //Need to be completed
}