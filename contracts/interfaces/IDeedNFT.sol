// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/DeedStruct.sol";

interface IDeedNFT {
    function registerDeed(
        address to,
        Deedstructs.Coordinate[] memory _locations,
        uint256 _area,
        string memory _deedNumber,
        string memory _ipfHash,
        string memory _notary,
        uint256 _appraisalValue,
        string memory _tokenURI
    ) external returns (uint256);
    
    function markAsTokenized(
        uint256 tokenId,
        address erc20Contract
    ) external;

    function updateAppraisalValue(
        uint256 tokenId,
        uint256 newAppraisalValue
    ) external;

    function recordOwnershipChange(
        uint256 tokenId,
        address newWOwner,
        uint256 share,
        string memory eventType
    ) external;

    function getDeedLocation(
        uint256 tokenId
    ) external view returns (Deedstructs.Coordinate[] memory);

    function getOwnershipHistory(
        uint256 tokenId
    ) external view returns (Deedstructs.OwnershipRecord[] memory);

    function getDeedInfo(
        uint256 tokenId
    ) external view returns (Deedstructs.DeedInfo memory);

    function getTokenValue(
        uint256 tokenId
    ) external view returns (uint256);

    function nextTokenId() external view returns (uint256);
}