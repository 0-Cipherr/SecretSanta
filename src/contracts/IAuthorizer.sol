// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IAuthorizer {
    function addAuthorizer(address user) external;

    function removeAuthroizer(address user) external;

    function bulkAdd(address[] memory authorizedList) external;
    function verifyCallerSig(address caller) external view returns (bool);
}
