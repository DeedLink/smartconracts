// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
import "../libraries/DeedStructs.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../interfaces/IDeedNFT.sol";

contract DeedNFT is ERC721URIStorage, Ownable, IDeedNFT {
    using  Deedstructs for  Deedstructs.DeedInfo;

    uint256 public nextTokenId = 1;

    mapping(uint256 => Deedstructs.DeedInfo) public deeds;
    mapping(uint256 => Deedstructs.OwnershipRecord[]) public ownershipHistory;

    mapping(uint256 => bool) public authorizedContracts;
}

