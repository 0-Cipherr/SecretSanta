// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
interface IBridge {
    function bridgeQuote(
        address _caller,
        address _asset,
        uint256 _amount,
        address _destinationAddr,
        uint256 _srcChainId,
        uint256 _destChainID,
        bytes memory adapterParams
    ) external payable returns (bytes memory);
    function bridge(bytes memory adapterParams) external payable;
    //should be custom function to calland run to claim incentives
    function customCall(
        bytes memory funSig,
        bytes memory _adapterParams
    ) external;
}
//ibridge

// bridge()
// quote()
// supportedChains()
// status()

//istrat

// deposit()
// withdraw()
// harvest()
// rebalance()
// totalAssets()
