// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IDeedShareToken.sol";
import "../libraries/DeedStructs.sol";
import "../utils/Errors.sol";
import "../interfaces/IDeedNFT.sol";
import "../utils/Functions.sol";

abstract contract DeedShareToken is ERC20, Ownable, ReentrancyGuard, IDeedShareToken {
    uint256 public immutable deedTokenId;
    address public immutable deedNFTAddress;
    uint256 public immutable totalSharesIssued;
    using Functions for address[];

    Deedstructs.ShareTransferRecord[] private transferHistory;

    modifier validAddress(address addr) {
        if(addr == address(0)) revert Errors.ZeroAddressNotAllowed();
        _;
    }

    constructor(
        uint256 _deedTokenId,
        address _deedNFTAddress,
        uint256 _totalShares,
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) ERC20(_name, _symbol) validAddress(_deedNFTAddress) {
        if(_totalShares == 0) revert Errors.InvalidTotalShares(_totalShares);
        if(_deedTokenId == 0) revert Errors.InvalidDeedTokenId(_deedTokenId);

        deedTokenId = _deedTokenId;
        deedNFTAddress = _deedNFTAddress;
        totalSharesIssued = _totalShares;

        _mint(_initialOwner, _totalShares);
        _transferOwnership(_initialOwner);
    }

    // There is a problem in overriding the _afterTokenTransfer function.
    /*
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._afterTokenTransfer(from, to, amount);

        if (from != address(0) && to != address(0)) {
            transferHistory.push(
                Deedstructs.ShareTransferRecord({
                    from: from,
                    to: to,
                    amount: amount,
                    timestamp: block.timestamp
                })
            );

            IDeedNFT deedContract = IDeedNFT(deedNFTAddress);

            uint256 sharePercentage = (amount * 10000) / totalSharesIssued;

            deedContract.recordOwnershipChange(
                deedTokenId,
                to,
                sharePercentage,
                "SHARE_TRANSFER"
            );

            emit Deedstructs.ShareTransferLogged(
                deedTokenId,
                from,
                to,
                amount,
                block.timestamp
            );
        }
    }
    */
   
   // Using _update instead of _afterTokenTransfer to avoid issues with OpenZeppelin's ERC20 implementation
   function _update(
    address from,
    address to,
    uint256 value   
    ) internal override {
        super._update(from, to, value);

        if (from != address(0) && to != address(0)) {
            transferHistory.push(
                Deedstructs.ShareTransferRecord({
                    from: from,
                    to: to,
                    amount: value,
                    timestamp: block.timestamp
                })
            );

            IDeedNFT deedContract = IDeedNFT(deedNFTAddress);
            uint256 sharePercentage = (value * 10000) / totalSharesIssued;

            deedContract.recordOwnershipChange(
                deedTokenId,
                to,
                sharePercentage,
                "SHARE_TRANSFER"
            );

            emit Deedstructs.ShareTransferLogged(
                deedTokenId,
                from,
                to,
                value,
                block.timestamp
            );
        }
    }

    function getTransferHistory() external view returns (Deedstructs.ShareTransferRecord[] memory) {
        return transferHistory;
    }

    function getShareValue() external view returns (uint256) {
        IDeedNFT deedContract = IDeedNFT(deedNFTAddress);
        uint256 tokenValue = deedContract.getTokenValue(deedTokenId);
        //return (tokenValue * 10**decimals()) / totalSharesIssued;
        return tokenValue;
    }

    function getOwnershipPercentage(address owner) external view returns (uint256) {
        uint256 balance = balanceOf(owner);
        if (balance == 0) return 0;
        return (balance * 10000) / totalSharesIssued;
    }

    function getOwnershipValue(address owner) external view returns (uint256) {
        uint256 balance = balanceOf(owner);
        if (balance == 0) return 0;
        IDeedNFT deedContract = IDeedNFT(deedNFTAddress);
        uint256 shareValue = deedContract.getTokenValue(deedTokenId);
        return balance * shareValue;
    }

    function ownsAllShares(address owner) external view returns (bool) {
        return balanceOf(owner) == totalSharesIssued;
    }

    function getCurrentHolders() external view returns (address[] memory holders, uint256[] memory balances) {
        address[] memory tempHolders = new address[](transferHistory.length * 2);
        uint256 holderCount = 0;

        for (uint256 i = 0; i < transferHistory.length; i++) {
            address to = transferHistory[i].to;
            address from = transferHistory[i].from;

            if (!tempHolders.isInArray(to, holderCount)) {
                tempHolders[holderCount] = to;
                holderCount++;
            }

            if (!tempHolders.isInArray(from, holderCount)) {
                tempHolders[holderCount] = from;
                holderCount++;
            }
        }

        holders = new address[](holderCount);
        balances = new uint256[](holderCount);

        for (uint256 i = 0; i < holderCount; i++) {
            holders[i] = tempHolders[i];
            balances[i] = balanceOf(tempHolders[i]);
        }
    }

    function mintShares(address to, uint256 amount) external onlyOwner validAddress(to) {
        if(amount == 0) revert Errors.ZeroAmount();
        _mint(to, amount);
    }

    function burnShares(address from, uint256 amount) external onlyOwner {
        if(amount == 0) revert Errors.ZeroAmount();
        if(balanceOf(from) < amount) revert Errors.InsufficientShares(amount, balanceOf(from));
        _burn(from, amount);
    }

    function getDeedInfo() external view returns (Deedstructs.DeedInfo memory) {
        IDeedNFT deedContract = IDeedNFT(deedNFTAddress);
        return deedContract.getDeedInfo(deedTokenId);
    }
}