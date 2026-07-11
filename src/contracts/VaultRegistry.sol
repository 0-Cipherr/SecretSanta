// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import {RefferalCodeManager} from "./RefferalCodeManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ProtocolUsers} from "./ProtocolUsers.sol";
contract VaultRegistry is Ownable, ProtocolUsers {
    uint256 _currentId;
    IVaultFactory factory;
    struct VaultInfo {
        uint256 id;
        address vaultAddr;
        address owner;
        uint256 strategyId;
        uint256 bridgeId;
        uint256 tvl;
        uint256 totalShares;
        bool status;
        uint256 createdAt;
        uint32[] deployedEndpoints;
    }
    mapping(uint256 => VaultInfo) vaults;
    constructor(IVaultFactory _factory) Ownable(msg.sender) {
        factory = _factory;
        _currentId = 0;
    }
    function updateId() public {
        ++_currentId;
    }

    function createVaultQuote(
        uint32[] memory _vaultChains
    ) public view returns (uint256) {
        uint256 _quote = factory.createVaultQuote(_vaultChains);
        return _quote;
    }

    function createVault(
        address _owner, //vault owner
        uint32[] memory _vaultChains, //lz endpoints to deploy on
        uint256 _quote // amount from quoter
    ) public payable {
        require(_quote == msg.value, "Not enough");
        address deployment = factory.createVault(_currentId, _vaultChains); //returns layerzero address
        registerVault(_owner, deployment, block.timestamp, _vaultChains);
    }

    function increaseId() public {
        ++_currentId;
    }

    function registerVault(
        address _owner,
        address vaultAddr,
        uint256 createdAt,
        uint32[] memory _vaultChains
    ) public {
        vaults[_currentId] = VaultInfo(
            _currentId,
            vaultAddr,
            _owner,
            0,
            0,
            0,
            0,
            true,
            createdAt,
            _vaultChains
        );

        increaseId();
    }
    //     Vault

    // id

    // owner

    // asset

    // strategyId

    // bridgeId

    // tvl

    // totalShares

    // status

    // fee

    // createdAt
}
