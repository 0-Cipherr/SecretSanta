// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IAuthorizer} from "../contracts/IAuthorizer.sol";
contract BridgeAdapter is Ownable {
    IAuthorizer authorizer;
    address[] _authorized;
    uint256 _currentId = 0;
    struct BridgeInfo {
        string name;
        IBridge adapter;
        bool status;
        uint256[] _supportedChains;
        IERC20[] _supportedTokens;
    }
    mapping(uint256 => BridgeInfo) bridges;
    modifier verifyCaller(address caller) {
        bool found = authorizer.authorizers[caller];
        require(msg.sender == caller, "Unauthorized");
        require(found == true, "Caller no authorized");
        _;
    }

    modifier HasChain(uint256[] memory _chains, uint256 toFind) {
        bool hasChain = findChain(_chains, toFind);
        require(hasChain, "Chain not available");
        _;
    }

    modifier verifyAdapter(uint256 id) {
        require(bridges[id].status != false, "Adapter does not exist");
        _;
    }

    modifier verifyAsset(uint256 id, address asset) {
        bool assetFound = findToken(id, asset);
        require(assetFound == true, "Asset not found cannot bridge");
        _;
    }
    constructor() Ownable(msg.sender) {}

    function searchAuthorized(address toFind) public view returns (bool) {
        for (uint256 i = 0; i <= _authorized.length - 1; i++) {
            if (_authorized[i] == toFind) {
                return true;
            }
        }
        return false;
    }

    function addAuthorized(address _user) public onlyOwner {
        _authorized.push(_user);
    }

    function removeAuthorized(address _user) public onlyOwner {}

    function findToken(
        uint256 id,
        address _toFind
    ) public verifyAsset(id, _toFind) returns (bool) {
        IERC20[] memory tokens = bridges[id]._supportedTokens;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (address(tokens[i]) == _toFind) {
                return true;
            }
        }

        return false;
    }
    //add any protocol use it to bridge
    function addAdapter(
        address caller,
        IBridge _adapter,
        string memory name,
        uint256[] memory _supportedChains,
        IERC20[] memory _supportedTokens
    ) public verifyCaller(caller) returns (uint256) {
        bridges[_currentId] = BridgeInfo(
            name,
            _adapter,
            true,
            _supportedChains,
            _supportedTokens
        );
        return _currentId; //return the id the adapter ws stored in
    }

    function removeAdapter(
        uint256 id,
        address caller
    ) public verifyAdapter(id) verifyCaller(caller) {
        bridges[id].name = "";
        bridges[id].adapter = IBridge(address(0));
        bridges[id].status = false;
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
        uint256 id,
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
        HasChain(bridges[id]._supportedChains, _destChainID)
        verifyCalller(msg.sender)
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

    function approveAsset(
        uint256 id,
        address _caller,
        uint256 tokenIndex,
        address _spender,
        uint256 _amount,
        address asset
    ) public verifyAdapter(id) verifyAsset(id, asset) verifyCaller(msg.sender) {
        bridges[id]._supportedTokens[tokenIndex].approve(_spender, _amount);
    }

    function getAdapterAddress(
        uint256 id
    ) public view verifyCaller(msg.sender) returns (address) {
        return address(bridges[id].adapter);
    }

    function getName(
        uint256 id
    ) public view verifyCaller(msg.sender) returns (string memory) {
        return bridges[id].name;
    }

    function getSupportedChains(
        uint256 id
    )
        public
        view
        verifyAdapter(id)
        verifyCaller(msg.sender)
        returns (uint256[] memory)
    {
        return bridges[id]._supportedChains;
    }

    function bridge(
        address _caller,
        uint256 destChainId,
        uint256 id,
        bytes memory adapterData
    )
        public
        payable
        verifyAdapter(id)
        HasChain(bridges[id]._supportedChains, destChainId)
        verifyCaller(msg.sender)
    {
        bridges[id].adapter.bridge{value: msg.value}(adapterData);
    }
    //dangerous function

    //llm cannot call this function at all
    //used to claim incentives or airdrops from using bridges
    function customBridgeCall(
        uint256 id,
        address _caller,
        address _toCall,
        bytes memory funSig,
        bytes memory _adapterParams
    ) private verifyCaller(msg.sender) verifyAdapter(id) returns (bool) {
        //adapter should call from its contract to claim any icnentive
        bridges[id].adapter.customCall(_toCall, funSig, _adapterParams);
        return true;
    }
}

// /plug and play bridges
