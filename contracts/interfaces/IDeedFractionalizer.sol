// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDeedFractionalizer {
    function fractionalizeDeed(
        uint256 deedTokenId,
        uint256 totalShares,
        string memory tokenName,
        string memory tokenSymbol
    ) external returns (address);

    function redeemDeed(
        uint256 deedTokenId
    ) external;

    function getShareTokenAddress(
        uint256 deedTokenId
    ) external view returns (address);

    function getDeedTokenId(
        address shareTokenAddress
    ) external view returns (uint256);

    function deedNFT() external view returns (address);
}