// contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

import {CREATE3Factory} from "./CREATE3Factory.sol";
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
    CREATE3Factory factory;
    address[] authorized;

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
    constructor(address _endpoint) Ownable(msg.sender) OApp(_endpoint, _owner) {
        factory = new CREATE3Factory();
        authorized.push(address(this));
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

    //vault chains is optional
    function createVault(
        uint256 _vaultId,
        uint32[] memory _vaultChains
    ) public {
        if (_vaultChains.length > 0) {
            multichainDeploy(_vaultChains);
        } else {
            deploy(_vaultId);
        }
    }

    function multichainDeploy(uint32[] memory _vaultChains) public {
        for (uint256 i = 0; i < _vaultChains.length; i++){
            MessagingFee
        }
    }

    //pass in the vault id we get from vault registry only the vault registry and authorized can call this contract
    function deploy(uint256 _id) public returns (address) {
        VaultManager subDeployment = new VaultManager();
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
        bytes _options
    ) public view returns (MsgQuote memory) {
        MessagingFee memory _quote = _quote(_dstEid, _message, _options, false);

        return MsgQuote(_dstEid, _message, _options, _fee, _quote.nativeFee);
    }
    function sendMessage(MsgQuote memory _quote) public payable {
        require(msg.vale >= _quote.fee, "Not enough funds to coninue:(");
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
