// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IDeedNFT.sol";
import "../interfaces/IDeedFractionalizer.sol";
import "../libraries/DeedStructs.sol";
import "../utils/Errors.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract DeedRegistry is Ownable, ReentrancyGuard {
    IDeedNFT public immutable deedNFT;
    IDeedFractionalizer public immutable fractionalizer;

    Deedstructs.RegistryEntry[] public registryEntries;
    mapping(uint256 => uint256) public deedToRegistryIndex;
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
        string memory _ipfsHash,
        string memory _notary,
        uint256 _appraisalValue,
        string memory _tokenURI,
        uint256 _area
    ) external onlyAuthorizedRegistrar validDeedNumber(_deedNumber) nonReentrant returns (uint256) {
        if(to == address(0)) revert Errors.ZeroAddressNotAllowed();
        if(_area == 0) revert Errors.InvalidArea(_area);
        if(_appraisalValue == 0) revert Errors.InvalidAppraisalValue(_appraisalValue);

        uint256 deedTokenId = deedNFT.registerDeed(
            to,
            _location,
            _area,
            _deedNumber,
            _ipfsHash,
            _notary,
            _appraisalValue,
            _tokenURI
        );

        registryEntries.push(
            Deedstructs.RegistryEntry({
                deedTokenId: deedTokenId,
                shareTokenAddress: address(0),
                isActive: true,
                createdAt: block.timestamp
            })
        );

        uint256 registryIndex = registryEntries.length - 1;
        deedToRegistryIndex[deedTokenId] = registryIndex;

        usedDeedNumbers[_deedNumber] = true;
        emit DeedNumberUsed(_deedNumber);

        totalDeeds++;
        totalRegistryValue += _appraisalValue;

        emit Deedstructs.DeedRegisteredInRegistry(deedTokenId, registryIndex);

        return deedTokenId;
    }

    function updateFractionalizationStatus(uint256 deedTokenId) external {
        if(msg.sender != address(fractionalizer)) {
            revert Errors.Unauthorized(msg.sender);
        }

        uint256 registryIndex = deedToRegistryIndex[deedTokenId];
        if(registryIndex >= registryEntries.length) {
            revert Errors.InvalidRegistryIndex(registryIndex);
        }

        address shareTokenAddress = fractionalizer.getShareTokenAddress(deedTokenId);
        registryEntries[registryIndex].shareTokenAddress = shareTokenAddress;

        if(shareTokenAddress != address(0)) {
            //registryEntries[registryIndex].isActive = true;
            totalFractionalizedDeeds++;
        } else {
            //registryEntries[registryIndex].isActive = false;
            totalFractionalizedDeeds--;
        }
    }

    function reactivateDeed(uint256 deedTokenId) external onlyOwner {
        uint256 registryIndex = deedToRegistryIndex[deedTokenId];
        if(registryIndex >= registryEntries.length) {
            revert Errors.InvalidRegistryIndex(registryIndex);
        }

        registryEntries[registryIndex].isActive = true;
    }

    function updateRegistryValue(uint256 deedTokenId, uint256 oldValue, uint256 newValue) external {
        if(msg.sender != address(deedNFT)) {
            revert Errors.Unauthorized(msg.sender);
        }

        totalRegistryValue = totalRegistryValue - oldValue + newValue;
    }

    function getAllDeeds() external view returns (Deedstructs.RegistryEntry[] memory) {
        return registryEntries;
    }


    //Double check if this function is needed
    function getActiveDeeds() external view returns (Deedstructs.RegistryEntry[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < registryEntries.length; i++) {
            if (registryEntries[i].isActive) {
                activeCount++;
            }
        }

        Deedstructs.RegistryEntry[] memory activeDeeds = new Deedstructs.RegistryEntry[](activeCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < registryEntries.length; i++) {
            if (registryEntries[i].isActive) {
                activeDeeds[currentIndex] = registryEntries[i];
                currentIndex++;
            }
        }
        return activeDeeds;
    } 

    //Double check if this function is needed
    function getFractionalizedDeeds() external view returns (Deedstructs.RegistryEntry[] memory) {
        uint256 fractionalizedCount = 0;
        for (uint256 i = 0; i < registryEntries.length; i++) {
            if (registryEntries[i].shareTokenAddress != address(0)) {
                fractionalizedCount++;
            }
        }

        Deedstructs.RegistryEntry[] memory fractionalizedDeeds = new Deedstructs.RegistryEntry[](fractionalizedCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < registryEntries.length; i++) {
            if (registryEntries[i].shareTokenAddress != address(0)) {
                fractionalizedDeeds[currentIndex] = registryEntries[i];
                currentIndex++;
            }
        }
        return fractionalizedDeeds;
    }

    function getDeedDetails(uint256 deedTokenId) external view returns (
        Deedstructs.DeedInfo memory deedInfo, 
        Deedstructs.Coordinate[] memory locations,
        Deedstructs.OwnershipRecord[] memory ownershipHistory,
        Deedstructs.RegistryEntry memory registryInfo
    ) {
        deedInfo = deedNFT.getDeedInfo(deedTokenId);
        locations = deedInfo.locations;
        ownershipHistory = deedNFT.getOwnershipHistory(deedTokenId);
        uint256 registryIndex = deedToRegistryIndex[deedTokenId];
        if (registryIndex >= registryEntries.length) {
            registryInfo = registryEntries[registryIndex];
        }
    }

    function getDeedNumber(string memory deedNumber) external view returns (uint256 deedTokenId, bool found) {
        if(!usedDeedNumbers[deedNumber]) {
            return (0, false);
        }

        for (uint256 i = 0; i < registryEntries.length; i++) {
            Deedstructs.DeedInfo memory deedInfo = deedNFT.getDeedInfo(registryEntries[i].deedTokenId);
            if(keccak256(bytes(deedInfo.deedNumber)) == keccak256(bytes(deedNumber))) {
                return (registryEntries[i].deedTokenId, true);
            }
        }

        return (0, false);
    }

    function getDeedsByOwner(address owner) external view returns (uint256[] memory ownedDeeds) {
        uint256 ownedCount = 0;
        uint256[] memory tempOwnedDeeds = new uint256[](registryEntries.length);

        for (uint256 i = 0; i < registryEntries.length; i++) {
            uint256 deedTokenId = registryEntries[i].deedTokenId;
            try IERC721(address(deedNFT)).ownerOf(deedTokenId) returns (address deedOwner) {
                if (deedOwner == owner && registryEntries[i].isActive) {
                    tempOwnedDeeds[ownedCount] = deedTokenId;
                    ownedCount++;
                }
            } catch {
                // Deed might not exist or be burned, skip
                continue;
            }

            ownedDeeds = new uint256[](ownedCount);
            for (uint256 j = 0; j < ownedCount; j++) {
                ownedDeeds[j] = tempOwnedDeeds[j];
            }
        }
    }

    function getRegistryStatus() external view returns (
        uint256 _totalDeeds,
        uint256 _totalFractionalizedDeeds,
        uint256 _totalRegistryValue,
        uint256 _activeDeeds
    ) {
        _totalDeeds = totalDeeds;
        _totalFractionalizedDeeds = totalFractionalizedDeeds;
        _totalRegistryValue = totalRegistryValue;

        uint256 activeCount = 0;
        for (uint256 i = 0; i < registryEntries.length; i++) {
            if (registryEntries[i].isActive) {
                activeCount++;
            }
        }
        _activeDeeds = activeCount;
    }

    function getDeeds(uint256 offset, uint256 limit) external view returns (
        Deedstructs.RegistryEntry[] memory deeds,
        uint256 total
    ) {
        total = registryEntries.length;
        if (offset >= total) {
            return (new Deedstructs.RegistryEntry[](0), total);
        }

        uint256 end = offset + limit;
        if (end > total) {
            end = total;
        }

        deeds = new Deedstructs.RegistryEntry[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            deeds[i - offset] = registryEntries[i];
        }
    }

    function isAutherizedRegistrar(address registrar) external view returns (bool) {
        return authorizedRegistrars[registrar];
    }

    function isDeedNumberUsed(string memory deedNumber) external view returns (bool) {
        return usedDeedNumbers[deedNumber];
    }

    function getRegistryEntry(uint256 index) external view registryIndexExists(index) returns (Deedstructs.RegistryEntry memory) {
        return registryEntries[index];
    }

    function getRegistrySize() external view returns (uint256) {
        return registryEntries.length;
    }
}