// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../interfaces/IERC20.sol";
contract Authorizer is Ownable {
    mapping(address => bool) authorizers;

    modifier verifyCaller(address caller) {
        bool found = authorizers[caller];
        require(msg.sender == caller, "Unauthorized");
        require(found == true, "Caller no authorized");
        _;
    }
    constructor(address[] memory _authorizers) Ownable(msg.sender) {
        if (_authorizers.length > 0) {
            bulkAdd(_authorizers);
        }
    }

    function bulkAdd(address[] memory authorizedList) public {
        for (uint256 i = 0; i < authorizedList.length - 1; i++) {
            authorizers[authorizedList[i]] = true;
        }
    }

    function addAuthorizer(address _user) public {
        authorizers[_user] = true;
    }

    function removeAuthroizer(address _user) public verifyCaller(_user) {
        authorizers[_user] = false;
    }
}
