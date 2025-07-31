// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../libraries/DeedStructs.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDeedShareToken is IERC20 {
    function deedTokenId() external view returns (uint256);
    function deedNFTAddress() external view returns (address);
    function totalSharesIssued() external view returns (uint256);
    function getTransferHistory() external view returns (Deedstructs.ShareTransferRecord[] memory);
    function getShareValue() external view returns (uint256);
    function getOwnershipPercentage(address owner) external view returns (uint256);
}