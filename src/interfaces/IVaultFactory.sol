// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVaultFactory {
    struct VaultDeployInfo {
        bytes creationCode;
        bytes32 originalSalt;
        address lzAddress;
        uint32[] deployedEndpoints;
    }

    struct MsgQuote {
        uint32 dstEid;
        bytes message;
        bytes options;
        uint256 fee;
    }

    // Peer management

    function addLZPeer(uint32 _eid, bytes32 _peer) external;

    function removePeer(uint32 _eid, bytes32 _peer) external;

    // Authorization

    function addAuthorized(address _user) external;

    function removeAuthorized(address _user) external;

    // Vault creation

    function createVaultQuote(
        uint32[] calldata _vaultChains
    ) external view returns (uint256);

    function createVault(
        uint256 _vaultId,
        uint32[] calldata _vaultChains
    ) external returns (address);

    function deploy(uint256 _id) external returns (address);

    // Deployment information

    function storeDeployment(
        bytes calldata creationCode,
        bytes32 salt,
        address lzAddress,
        uint256 id
    ) external;

    function getDeploymentInfo(
        uint256 id
    ) external view returns (VaultDeployInfo memory);

    // Messaging

    function getMultiChainDeployQuote(
        uint32[] calldata _vaultChains
    ) external view returns (uint256);

    function getMessageQuote(
        uint32 _dstEid,
        bytes calldata _message,
        bytes calldata _options
    ) external view returns (MsgQuote memory);

    function sendMessage(MsgQuote calldata _quote) external payable;
}
