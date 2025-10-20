// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../interfaces/IDeedShareToken.sol";
import "../utils/Functions.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IDeedNFT.sol";
import "../interfaces/IDeedFractionalizer.sol";
import "../libraries/DeedStructs.sol";
import "../utils/Errors.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract DeedFractionalizer is  Ownable, ReentrancyGuard, IERC721Receiver, IDeedFractionalizer {
    IDeedNFT public immutable deedNFT;

    mapping(uint256 => address) public deedShareToken;
    mapping(uint256 => uint256) public shareTokenDeed;

    uint256[] public fractionalizedDeeds;
    mapping(uint256 => bool) public isFractionalized;

    modifier deedExists(uint256 deedTokenId) {
        try deedNFT.getDeedInfo(deedTokenId) returns (Deedstructs.DeedInfo memory deed) {
            //require(deed.owner != address(0), "Deed does not exist");
        } catch {
            revert Errors.DeedDoesNotExist();(deedTokenId);
        }
        _;
    }

    modifier notAlreadyFractionalized(uint256 deedTokenId) {
        if(deedShareToken[deedTokenId] != address(0)) {
            revert Errors.DeedAlreadyFractionalized(deedTokenId);
        }
        _;
    }

    modifier onlyDeedOwner(uint256 deedTokenId) {
        address owner = IERC721(address(deedNFT)).ownerOf(deedTokenId);
        if (msg.sender != owner) {
            revert Errors.NotDeedOwner(msg.sender, deedTokenId);
        }
        _;
    }

    constructor(address _deedNFT) {
        if(_deedNFT == address(0)) revert Errors.InvalidAddress(_deedNFT);
        deedNFT = IDeedNFT(_deedNFT);
    }

}