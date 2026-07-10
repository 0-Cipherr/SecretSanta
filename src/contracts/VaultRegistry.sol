// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract VaultRegistry{
    struct VaultInfo{
        uint256 id;
        address owner;
       uint256 strategyId;
       uint256  bridgeId;
        uint256 tvl;
        uint256 totalShares;
        bool status;
        uint256 createdAt ;
    }
    constructor(){}

    funciton createVault()public {}
//     Vault

// id

// owner

// asset

// strategyId

// bridgeId

// tvl

// totalShares

// status

// fee

// createdAt
}