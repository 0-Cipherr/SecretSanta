// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IBridge} from "../interfaces/IBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {Authorizer} from "../contracts/Authorizer.sol";
import {IStrategy} from "../interfaces/IStrategy.sol";
contract StrategyAdapter is Ownable {
    Authorizer authorizerz;
    uint256 currentStratId; //should be the id

    modifier verifyCaller(address caller) {
        bool found = authorizerz.authorizers[caller];
        require(msg.sender == caller, "Unauthorized");
        require(found == true, "Caller no authorized");
        _;
    }

    struct StrategyInfo {
        uint256 id;
        IStrategy adapter;
        uint16 chainId;
        bool enabled;
        bool paused;
        uint8 strategyType;
        address asset;
        uint256 allocationBps;
        bytes config;
    }

    struct StrategyMetrics {
        uint256 totalAssets;
        uint256 totalShares;
        uint256 pricePerShare;
        uint256 rewardRate;
        uint256 lastUpdated;
    }

    StrategyMetrics metrics;

    StrategyInfo[] strategy;
    // growth = currentPricePerShare / previousPricePerShare

    // APR = (growth - 1) * (365 days / elapsed)

    // APY = (1 + APR / periods)^periods - 1
    constructor(
        Authorizer _authorizer,
        address[] memory authorized
    ) Ownable(msg.sender) {
        authorizerz = Authorizer(_authorizer);
        if (authorized.length > 0) {
            authorizerz.bulkAdd(authorized);
        }
    }

    function getStrategy(uint256 id) public {
        return strategy[id];
    }

    function disableStrategy(uint256 id) public {
        strategy[id].enabled = false;
    }

    function enableStrategy(uint256 id) public {
        strategy[id].enabled = true;
    }

    function addStrategy(
        IStrategy adapter,
        uint8 strategyType,
        address asset,
        uint256 allocationBps,
        bytes config
    ) public verifyCaller(msg.sender) {
        strategy.push(
            StrategyInfo(
                currentStratId,
                block.chainid,
                adapter,
                true,
                false,
                0,
                asset,
                0,
                bytes(0)
            )
        );
        increaseCurrentStratId();
    }

    function increaseCurrentStratId() public {
        ++currentStratId;
    }
    //initial adapters are gonna be uniswap pools
    function updateUniswapPools(
        uint256 id,
        address pairA,
        address pairB,
        address _caller
    ) public verifyCaller {}

    function uniswapLPDeposit(
        uint256 id,
        uint256 _amount,
        address _caller
    ) public payable {}

    function deposit(
        uint256 id,
        bytes memory adapterParams
    ) public payable verifyCaller(msg.sender) {
        strategy[id].adapter.deposit{value: msg.value}(adapterParams);
    }

    function updateMetrics(
        StrategyMetrics memory _metrics
    ) public verifyCaller(msg.sender) {
        metrics = _metrics;
    }
    //price totalassets/totalshares

    function calculateApy(
        uint256 id
    ) public verifyCaller(msg.sender) returns (uint256) {
        uint256 apy = strategy[id].calculateApy();
        return 1;
    }
    function updateApy(
        uint256 id
    ) public verifyCaller(msg.sender) returns (uint256) {
        uint256 apy = strategy[id].updateApy();

        return 1;
    }

    //     growth = currentPricePerShare / previousPricePerShare

    // APR = (growth - 1) * (365 days / elapsed)

    // APY = (1 + APR / periods)^periods - 1
    function withdraw(
        uint256 id,
        bytes memory adapterParams
    ) public payable verifyCaller(msg.sender) {
        strategy[id].adapter.withdraw(adapterParams);
    }

    function rebalance(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.deposit(adapterParams);
    }
    function harvest(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.harvest(adapterParams);
    }

    function claimRewards(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.claimRewards(adapterParams);
    }

    function totalAssets(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.totalAssets(adapterParams);
    }

    function getApy(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.getApy(adapterParams);
    }

    function pendingRewards(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.pendingRewards(adapterParams);
    }

    function emergencyWithdraw(
        uint256 id,
        bytes memory adapterParams
    ) public verifyCaller(msg.sender) {
        strategy[id].adapter.emergencyWithdraw(adapterParams);
    }
}

// APY Formula: APY = (1 + r/n)^n - 1
// r = Nominal annual interest rate (as a decimal, e.g., 0.05 for 5%)
// n = Number of compounding periods per year (e.g., 52 for weekly, 365 for daily)
