// contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

import {CREATE3Factory} from "./CREATE3Factory.sol";
import {ICREATE3Factory} from "../interfaces/ICREATE3Factory.sol";

import {VaultManager} from "./VaultManager.sol";

import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
//should be omnichain
//operates from the hub to deploy contracts on antoher chains we deploy from the main chain
//using oapp
contract VaultFactory is Ownable, OApp, OAppOptionsType3 {
    ICREATE3Factory factory;
    FactoryInfo[] factories;
    mapping(uint256 => MessengerInfo) messengers;
    MessengerInfo[] messagePeers; //this is located in simplemessenger.sol , tits purpose simple relayer to use CREATE3 factory to deploy same deterministic address across all chains
    address[] authorized;
    uint32 endpoint;
    mapping(uint256 => uint32) endpoints;
    bytes32 salt;
    bytes creationCode;
    struct FactoryInfo {
        uint256 chainId;
        ICREATE3Factory factory;
    }

    struct MessengerInfo {
        uint256 chainId;
        address messenger;
    }
    struct VaultDeployInfo {
        bytes creationCode;
        bytes32 _originalSalt;
        address lzAddress;
        uint32[] _deployedEndpoints;
    }

    modifier verifyPeer(uint32 _eid) {
        require(facotryPeer[_eid] != bytes32(0), "No Peer exists");
    }

    mapping(uint32 => bytes32) facotryPeer; //this is the peers we ommunicate with
    mapping(uint256 => VaultDeployInfo) vaultDeployment;
    //endpoint of the current chain we are deplyoign on
    constructor(
        address _endpoint,
        FactoryInfo[] _factories,
        MessengerInfo[] messengers
    ) Ownable(msg.sender) OApp(_endpoint, _owner) {
        factory = I();
        factories = _factories;
        authorized.push(address(this));
        endpoint = _endpoint;
        messagePers = messengers;
    }

    function addEndpoint(uint256 chainId, uint32 enpointId) public {
        endpoints[chainId] = endpointId;
    }

    function addFactory(uint256 chainId, CREATE3Factory _factory) public {
        factories.push(FactoryInfo(chainId, _factory));
    }

    function addLZPeer(uint32 _eid, bytes32 _peer) public {
        facotryPeer[_eid] = _peer;
    }

    function removePeer(uint32 _eid, bytes32 _peer) public verifyPeer(_eid) {
        facotryPeer[_eid] = bytes32(0); //if empty returns 0
    }

    function addAuthorized(address _user) public onlyOwner {
        authorized.push(_user);
    }

    function removeAuthorized(address _user) public {
        for (uint256 i = 0; i < authorized.length; i++) {
            if (authorized[i] == _user) {
                authorized[i] = authorized[authorized.length - 1];
                authorized.pop();
            }
        }
    }

    function createVaultQuote(
        uint32[] memory _vaultChains
    ) public returns (uint256) {
        if (_vaultChains.length > 0) {
            return getMultiChainDeployQuote(_vaultChains);
        }
        return 0;
    }

    //vault chains is optional
    function createVault(
        address _creator,
        uint256 _vaultId,
        uint32[] memory _vaultChains
    ) public {
        if (_vaultChains.length > 0) {
            multichainDeploy(_creator, _vaultId, _vaultChains);
        } else {
            deploy(_creator, _vaultChains); //deploy on current chain
        }
    }

    function getMultiChainDeployQuote(
        uint32[] memory _vaultChains,
        bytes32 salt,
        bytes memory creationCode
    ) public view returns (uint256) {
        uint256 _total;
        for (uint256 i = 0; i < _vaultChains.length; i++) {
            if (_vaultChains[i] != endpoint) {
                bytes _message = abi.encodeWithSignature(
                    "deployContract(bytes32, bytes)",
                    salt,
                    creationCode
                ); //arguments updated later on need to workon vault
                MsgQuote memory _quote = getMessageQuote(
                 endpoints[_vaultChains[i]], //goes to endpoint in chain provided ,
                    _message,
                    abi.encode(""),
                    messagePeers[i]
                );
                _total += _quote.fee;
            }
        }
        return _total;
    }
    function addPeer(uint32 endpointId, address peerAddress )public{
      bytes32 _peer =   bytes32(uint160(peerAddress));

        _setPeer(_eid, _peer);

    }

    function getSalt()public{}

    function getCreationCode()public[

    ]

    function multichainDeploy(
        address _creator,
        uint256 _id,
        uint32[] memory _vaultChains
    ) public payable {
        for (uint256 i = 0; i < _vaultChains.length; i++) {
            if (_vaultChains[i] != endpoint) {
                bytes _message = abi.encodeWithSignature("deployContract(address,bytes,bytes32,address,uint32[])",_creator,  ); //arguments updated later on need to workon vault
                MsgQuote memory _quote = getMessageQuote(
                    endpoints[_vaultChains[i]], //goes to endpoint in chain provided 
                    _message,
                    abi.encode("")
                );
                sendMessage(_quote);
            } else {
                deploy(_creator, _id);
            }
        }
    }

    //pass in the vault id we get from vault registry only the vault registry and authorized can call this contract
    function deploy(
        address _creator,
        uint256 _id
    ) public payable returns (address) {
        VaultManager subDeployment = new VaultManager(_creator);
        address vaultOriginalAddr = address(subDeployment); //remmebr vault has cosntructor params
        bytes32 salt = keccak256(abi.encode(vaultOriginalAddr));
        bytes memory creationCode = type(VaultManager).creationCode;
        address deployedVault = factory.deploy(salt, creationCode); //deploys address layer zero style we use this to deploy all contract same address on all chans
        // returns layerzero deployment
        storeDeployment(creationCode, salt, deployedVault, _id);
        return deployedVault;
    }

    function storeDeployment(
        bytes memory creationCode,
        bytes32 salt,
        address lzAddress,
        uint256 id
    ) public {
        vaultDeployment[id] = VaultDeployInfo(creationCode, salt, lzAddress);
    }

    function getDeploymentInfo(
        uint256 id
    ) public view returns (VaultDeployInfo memory) {
        return vaultDeployment[id];
    }
    struct MsgQuote {
        uint32 dstEid;
        bytes message;
        bytes options;
        uint256 fee;
    }

    function getMessageQuote(
        uint32 _dstEid,
        bytes _message,
        bytes _options,
        address destination
    ) public view returns (MsgQuote memory) {
        MessagingFee memory _quote = _quote(_dstEid, _message, _options, false);

        return MsgQuote(_dstEid, _message, _options, _fee, _quote.nativeFee);
    }
    function sendMessage(MsgQuote memory _quote) public payable {
        require(msg.value >= _quote.fee, "Not enough funds to coninue:(");
        _lzSend(
            _quote.dstEid,
            _quote.message,
            _quote.options,
            _quote.fee,
            msg.sender
        );
    }

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        address(this).call(_message); //calls to deploy
        //should only call for a dpeloyent
    }
}
//ms g options
// Another example: Token + Native Gas Drop
// Suppose a user is bridging USDT0 (an OFT) to a new chain and wants to start interacting with dApps right away. Normally, they’d receive the token, but they wouldn’t have any native gas on the destination chain to pay for further transactions.
// With extra options, the user can:
// Ensure lzReceive() executes successfully to receive the USDT0.
// Add a native token drop option, funding their wallet with native gas on arrival.
// From the user’s perspective, they com
