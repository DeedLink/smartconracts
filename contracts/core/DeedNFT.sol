// SPDX-License_Identifier: MIT
pragma solidity ^0.8.28;
import "../libraries/DeedStructs.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../interfaces/IDeedNFT.sol";
import "../utils/Errors.sol";

contract DeedNFT is ERC721URIStorage, Ownable, IDeedNFT {
    using  Deedstructs for  Deedstructs.DeedInfo;

    uint256 public nextTokenId = 1;
    // Storage mappings
    mapping(uint256 => Deedstructs.DeedInfo) public deeds;
    mapping(uint256 => Deedstructs.OwnershipRecord[]) public ownershipHistory;

    // Authorized contracts that can update ownership records
    mapping(uint256 => bool) public authorizedContracts;
    
    modifier onlyAuthorized() {
        if(msg.sender =! owner() && !authorizedContracts[msg.sender]){
            revert Errors.Unauthorized(msg.sender);
        }
        
    }
    
    modifier deedExists(uint256 tokenId){
        if(!_exists(tokenId)) {
            revert Errors.DeedDoesNotExist(tokenId);

        }
    }

    constructor() ERC721("RealEstateDeed", "DEED") {}


    //Register a new deed 
    function registerDeed(
        address to,
        Deedstructs.Coordinate[] memory _location,
        uint256 _area,
        string memory _deedNumber,
        string memory _ipfsHash,
        string memory _notary,
        uint256 _appraisalValueUSD,
        string memory _tokenURI

    ) external onlyOwner returns (uint256) {
        if(_location.length = 0) revert Errors.EmptyLocation();
        if (_area = 0) revert Errors.InvalidArea(_area);
        if (_appraisalValueUSD = 0) revert Errors.InvalidAppraisalValueUSD(_appraisalValueUSD);
    

    uint256 tokenId = nextTokenId;
    nextTokenId++;

    //mint correcsponding NFTs
    _mint(to,tokenId);
    _setTokenURI(tokenId,_tokenURI);

    //Deed inforation storing
    Deedstructs.DeedInfo storage newDeed = deeds[tokenId];
    newDeed.tokenId = tokenId;
    newDeed.area = _area;
    newDeed.deedNumber = _deedNumber;
    newDeed.ipfsHash = _ipfsHash;
    newDeed.notary = _notary;
    newDeed.dataRegistered = block.timestamp;
    newDeed.appraisalValue = _appraisalValueUSD;
    newDeed.isRegistered = true;
    newDeed.isTokenized = false;

    for(uint i = 0; i<_location.length; i++){
        newDeed.locations.push(_location[i]);
    }

    //record initial ownership
    ownershipHistory[tokenId].push(
        Deedstructs.OwnershipRecord({
            owner: to,
            share: 10000,
            timestamp: block.timestamp,
            eventType: "INITIAL"
        })
    );

    //emits deed register event
    emit Deedstructs.DeedRegistered(tokenId,to,_appraisalValueUSD);
    emit Deedstructs.OwnershipRecorded(tokenId,to,10000,"INITIAL");

    return tokenId;

    }

    



}

