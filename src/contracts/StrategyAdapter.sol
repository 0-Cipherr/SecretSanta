// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../interfaces/IERC20.sol";
contract StrategyAdapter is Ownable {
    constructor() Ownable(msg.sender) {}
}
