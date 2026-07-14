// contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
contract VaultManager is Ownable {
    constructor(address _creator) Ownable(_creator) {}
    function deposit() public {}

    function withdraw() public {}

    function rebalance() public {}
    function pauseVault() public {}

    function closeVault() public {}
    function getTotalAssets() public {}

    function getShares() public {}

    function getCurrentStrategy() public {}
}
// createVault()

// deposit()

// withdraw()

// rebalance()

// pauseVault()

// closeVault()

// IVault
// IStrategy
// IAdapter
// IBridge
// IRegistry
