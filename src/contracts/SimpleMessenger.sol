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
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
//gets deployed on all chains excecpt solana where address standard is different
contract SimpeMessenger is Oapp, OAppOptionsType3 {
    ICREATE3Factory factory;

    struct VaultDeployInfo {
        bytes creationCode;
        bytes32 _originalSalt;
        address lzAddress;
        uint32[] _deployedEndpoints;
        VaultManager vault;
    }
    VaultDeployInfo[] vaults;

    constructor(CREATE3Factory _factory) {
        factory = _factory;
    }

    function deployContract(
        address owner,
        bytes creationCode,
        bytes32 _originalSalt,
        address lzAddress,
        uint32[] _deployedEndpoints
    ) {
        VaultManager vault = new VaultManager(owner);
        factory.deploy(salt, creationCode);
        addVault(
            vault,
            creationCode,
            _originalSalt,
            lzAddress,
            _deployedEndpoints
        );
    }

    function addVault(
        address vault,
        bytes creationCode,
        bytes32 _originalSalt,
        address lzAddress,
        uint32[] _deployedEndpoints
    ) public {
        vaults.push(
            VaultManager(
                vault,
                creationCode,
                _originalSalt,
                lzAddress,
                _deployedEndpoints
            )
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
