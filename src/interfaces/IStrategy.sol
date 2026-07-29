// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
interface IStrategy {
    function deposit(bytes memory adapterParams) external payable;

    function withdraw(bytes memory adapterParams) external;

    function rebalance(bytes memory adapterParams) external;
    function harvest(bytes memory adapterParams) external;

    function claimRewards(bytes memory adapterParams) external;

    function totalAssets(bytes memory adapterParams) external;

    function getApy(bytes memory adapterParams) external;

    function pendingRewards(bytes memory adapterParams) external;

    function emergencyWithdraw(bytes memory adapterParams) external;

    function calculateApy() external returns (uint256);

    function updateApy() external;
    function updatePoolUsed(bytes memory adapterParams) external;
    function enterPosition(bytes memory adapterParams) external;
}
