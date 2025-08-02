// SPDX-License_Identifier: MIT
pragma solidity ^0.8.28;

library Deedstructs {
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
        string ipfsHash;
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
    event DeedRegistered(
        uint256 indexed tokenId, 
        address indexed owner, 
        uint256 appraisalValue
    );
    event DeedTokenized(
        uint256 indexed tokenId, 
        address indexed erc20Contract, 
        uint256 totalShares
    );
    event OwnershipRecorded(
        uint256 indexed tokenId, 
        address indexed owner, 
        uint256 share, 
        string eventType
    );
    event ShareTransferLogged(
        uint256 indexed deedId,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event DeedFramentalized(
        uint256 indexed deedTokenId,
        address indexed owner,
        address indexed shareTokenAddress,
        uint256 totalShares
    );
    event DeedRedeemed(
        uint256 indexed deedTokenId,
        address indexed redeemer,
        address shareTokenAddress
    );
    event DeedRegisteredInRegistry(
        uint256 indexed deedTokenId,
        uint256 registryIndex
    );
}