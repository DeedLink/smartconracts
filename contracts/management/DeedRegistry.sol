// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IDeedNFT.sol";
import "../interfaces/IDeedFractionalizer.sol";
import "../libraries/DeedStructs.sol";
import "../utils/Errors.sol";

abstract contract DeedRegistry is Ownable, ReentrancyGuard {
    IDeedNFT public immutable deedNFT;
    IDeedFractionalizer public immutable fractionalizer;

    Deedstructs.RegistryEntry[] public registryEntries;
    mapping(uint256 => uint256) public deedRegistryIndex;
    mapping(address => bool) public authorizedRegistrars;
    mapping(string => bool) public usedDeedNumbers;

    uint256 public totalDeeds;
    uint256 public totalFractionalizedDeeds;
    uint256 public totalRegistryValue;

    event AuthorizedRegistrarAdded(address indexed registrar);
    event AuthorizedRegistrarRemoved(address indexed registrar);
    event DeedNumberUsed(string indexed deedNumber);

    modifier onlyAuthorizedRegistrar() {
        if(!authorizedRegistrars[msg.sender]) {
            revert Errors.NotAuthorizedRegistrar(msg.sender);
        }
        _;
    }

    modifier validDeedNumber(string memory deedNumber) {
        if(usedDeedNumbers[deedNumber]) {
            revert Errors.DeedAlreadyRegistered(0);
        }
        _;
    }

    modifier registryIndexExists(uint256 index) {
        if(index >= registryEntries.length) {
            revert Errors.InvalidRegistryIndex(index);
        }
        _;
    }

    constructor(address _deedNFT, address _fractionalizer) {
        if(_deedNFT == address(0)) revert Errors.InvalidAddress(_deedNFT);
        if(_fractionalizer == address(0)) revert Errors.InvalidAddress(_fractionalizer);

        deedNFT = IDeedNFT(_deedNFT);
        fractionalizer = IDeedFractionalizer(_fractionalizer);
        authorizedRegistrars[msg.sender] = true; // Owner is an authorized registrar by default
    }

    function addAuthorizedRegistrar(address registrar) external onlyOwner {
        if(registrar == address(0)) revert Errors.InvalidAddress(registrar);
        if(authorizedRegistrars[registrar]) {
            revert Errors.RegistrarAlreadyAuthorized(registrar);
        }

        authorizedRegistrars[registrar] = true;
        emit AuthorizedRegistrarAdded(registrar);
    }

    function removeAuthorizedRegistrar(address registrar) external onlyOwner {
        if(!authorizedRegistrars[registrar]) {
            revert Errors.NotAuthorizedRegistrar(registrar);
        }

        authorizedRegistrars[registrar] = false; //delete authorizedRegistrars[registrar];
        emit AuthorizedRegistrarRemoved(registrar);
    }

    function RegisterNewDeed(
        address to,
        Deedstructs.Coordinate[] memory _location,
        string memory _deedNumber,
        string memory _ipfHash,
        string memory _notary,
        uint256 _appraisalValue,
        string memory _tokenURI,
        uint256 _area
    ) external onlyAuthorizedRegistrar validDeedNumber(_deedNumber) nonReentrant returns (uint256) {
        if(to == address(0)) revert Errors.ZeroAddressNotAllowed();
        if(_area == 0) revert Errors.InvalidArea(_area);
        if(_appraisalValue == 0) revert Errors.InvalidAppraisalValue(_appraisalValue);


        // Need to complete deedNFT.sol before proceeding
        /*
        uint256 tokenId = deedNFT.registerDeed(
            to,
            _location,
            _deedNumber,
            _ipfHash,
            _notary,
            _appraisalValue,
            _tokenURI,
            _area
        );
        */
    }
}