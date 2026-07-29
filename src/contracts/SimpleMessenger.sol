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
    constructor(CREATE3Factory _factory) {}

    function deployContract(bytes32 salt, bytes memory creationCode) {
        factory.deploy(salt, creationCode);
    }
}
