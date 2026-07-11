// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
contract BridgeAdapter {
    uint256 _currentId = 0;
    struct BridgeInfo {
        string name;
        IBridge adapter;
        bool status;
        uint256[] _supportedChains;
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
        string memory name,
        uint256[] memory _supportedChains
    ) public returns (uint256) {
        bridges[_currentId] = BridgeInfo(
            name,
            _adapter,
            true,
            _supportedChains
        );
        return _currentId; //return the id the adapter ws stored in
    }

    function removeAdapter(uint256 id) public verifyAdapter(id) {
        bridges[id].name = "";
        bridges[id].adapter = IBridge(address(0));
        bridges[id].status = false;
    }
    modifier HasChain(uint256[] memory _chains, uint256 toFind) {
        bool hasChain = findChain(_chains, toFind);
        require(hasChain, "Chain not available");
        _;
    }

    function findChain(
        uint256[] memory chains,
        uint256 toFind
    ) public pure returns (bool) {
        for (uint256 i = 0; i < chains.length; i++) {
            if (chains[i] == toFind) {
                return true;
            }
        }
        return false;
    }
    function quote(
        uint256 destChainId,
        uint256 _amount,
        uint256 id,
        bytes memory adapterData
    )
        public
        verifyAdapter(id)
        HasChain(bridges[id]._supportedChains, destChainId)
        returns (bytes memory)
    {
        bytes memory _quote = bridges[id].adapter.bridgeQuote(adapterData);

        return _quote;
    }

    function getAdapterAddress(uint256 id)public view returns(address){
        reutrn address( bridges[id].adapter);
    }

    function getName(uint256 id) public view returns (string memory) {
        return bridges[id].name;
    }

    function getSupportedChains(
        uint256 id
    ) public view verifyAdapter(id) returns (uint256[] memory) {
        return bridges[id]._supportedChains;
    }

    function bridge(uint256 id, bytes memory adapterData) public payable {
        bridges[id].adapter.bridge{value: msg.value}(adapterData);
    }
}

// /plug and play bridges
