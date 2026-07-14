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
    ) external returns (bytes memory);
    function bridge(bytes memory adapterParams) external payable;
    //should be custom function to calland run to claim incentives
    function customCall(
        address _toCall,
        bytes memory funSig,
        bytes memory _adapterParams
    ) external payable;
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
