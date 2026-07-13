// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BridgeAdapter is Ownable {
    address[] _authorized;
    uint256 _currentId = 0;
    struct BridgeInfo {
        string name;
        IBridge adapter;
        bool status;
        uint256[] _supportedChains;
        address[] _supportedTokens;
    }
    mapping(uint256 => BridgeInfo) bridges;
    modifier verifyCaller(address caller) {
        bool found = searchAuthrized(caller);
        require(found == true, "Caller no authorized");
        _;
    }

    modifier verifyAdapter(uint256 id) {
        require(bridges[id].status != false, "Adapter does not exist");
        _;
    }

    modifier verifyBridgeAsset(uint256 id, address asset) {
        bool assetFound = findToken(id, asset);
        require(assetFound == true, "Asset not found cannot bridge");
        _;
    }
    constructor() Ownable(msg.sender) {}

    function searchAuthorized(address toFind) public returns (bool) {
        for (uint256 i = 0; i <= _authorized.length - 1; i++) {
            if (_authorized[i] == toFind) {
                return true;
            }
        }
        return false;
    }

    function findToken(
        uint256 id,
        address _toFind
    ) public verifyBridgeAsset(id, _toFind) returns (bool) {
        address[] memory tokens = bridges[id]._supportedTokens;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == _toFind) {
                return true;
            }
        }

        return false;
    }
    //add any protocol use it to bridge
    function addAdapter(
        IBridge _adapter,
        string memory name,
        uint256[] memory _supportedChains,
        address[] memory _supportedTokens
    ) public returns (uint256) {
        bridges[_currentId] = BridgeInfo(
            name,
            _adapter,
            true,
            _supportedChains,
            _supportedTokens
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
        address _caller,
        address _asset,
        uint256 _amount,
        address _destinationAddr,
        uint256 _srcChainId,
        uint256 _destChainID,
        bytes memory adapterParams
    )
        public
        verifyAdapter(id)
        HasChain(bridges[id]._supportedChains, destChainId)
        returns (bytes memory)
    {
        bytes memory _quote = bridges[id].adapter.bridgeQuote(
            _caller,
            _asset,
            _amount,
            _destinationAddr,
            _srcChainId,
            _destChainID,
            adapterParams
        );

        return _quote;
    }

    function getAdapterAddress(uint256 id) public view returns (address) {
        return address(bridges[id].adapter);
    }

    function getName(uint256 id) public view returns (string memory) {
        return bridges[id].name;
    }

    function getSupportedChains(
        uint256 id
    ) public view verifyAdapter(id) returns (uint256[] memory) {
        return bridges[id]._supportedChains;
    }

    function bridge(
        uint256 destChainId,
        uint256 id,
        bytes memory adapterData
    )
        public
        payable
        verifyAdapter(id)
        HasChain(bridges[id]._supportedChains, destChainId)
    {
        bridges[id].adapter.bridge{value: msg.value}(adapterData);
    }

    function claimIncentive(
        bytes memory funSig,
        bytes memory _adapterParams
    ) public returns (bool) {}
}

// /plug and play bridges
