// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
interface IBridge {
    function bridgeQuote(
        bytes memory adapterParams
    ) external returns (bytes memory);
    function bridge(bytes memory adapterParams) external payable;
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
