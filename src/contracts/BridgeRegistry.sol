// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
contract BridgeAdapter {
    uint256 _currentId = 0;
    struct BridgeInfo {
        string name;
        IBridge adapter;
        bool status;
    }
    mapping(uint256 => BridgeInfo) bridges;
    modifier verifyAdapter(uint256 id) {
        require(bridges[id].status != false, "Adapter does not exist");
        _;
    }
    constructor() {}
    //add any protocol use it to bridge
    function addAdapter(
        IBridge _adapter,
        string memory name
    ) public returns (uint256) {
        bridges[_currentId] = BridgeInfo(name, _adapter, true);
        return _currentId; //return the id the adapter ws stored in
    }

    function removeAdapter(uint256 id) public verifyAdapter(id) {
        bridges[id].name = "";
        bridges[id].adapter = IBridge(address(0));
        bridges[id].status = false;
    }

    function getBridgeQuote(uint256 id) public verifyAdapter(id) {}
}

// /plug and play bridges
