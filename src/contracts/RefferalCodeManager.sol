// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RefferalCodeManager {
    mapping(address => bytes) refferers;
    mapping(bytes => address) refferersOwners;

    mapping(bytes => uint256) _lifetimeEarnings;
    mapping(address => bytes) appointedCode;
    constructor() {}

    modifier verifyUser(address _user) {
        bool valid = refferers[_user].length != 0;
        require(valid, "User not regidtered");
        _;
    }

    modifier verifyCode(bytes memory _code) {
        bool valid = refferersOwners[_code] != address(0);
        _;
    }
    function appointReffered(bytes memory refferalCode, address _user) public {
        appointedCode[_user] = refferalCode;
    }
    function generateRefferalCode(address _user) public {
        refferers[_user] = abi.encode(_user, block.timestamp);
        refferersOwners[refferers[_user]] = _user;
    }

    function getRefferalCode(
        address _user
    ) public view verifyUser(_user) returns (bytes memory) {
        bytes memory _code = refferers[_user];
        return _code;
    }

    function updateLifetimeEarnings(
        uint256 _amount,
        bytes memory _code
    ) public verifyCode(_code) {
        _lifetimeEarnings[_code] += _amount;
    }
}
