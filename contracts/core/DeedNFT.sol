//SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/Deedstruct.sol";

contract DeedNFT is ERC721URIStroage, Ownable, IDeedNFT {
    using  DeedStructs for  DeedStructs.DeedInfo;

    uint256 public nextTokenId = 1;

    mapping(uint256 => DeedStructs.DeedInfo) public deeds;
    mapping(uint256 => Deedstructs.OwnershipRecord[]) public ownershipHistory;

    mapping(uint256 => bool) public authorizedContracts;


}

