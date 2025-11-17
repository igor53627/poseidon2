// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../packages/comparison-tools/TenderlyGasTest.sol";

/**
 * @title Tenderly Deployment Script
 * @notice Deploys all Poseidon2 implementations for real gas comparison on Tenderly
 */
contract DeployTenderly is Script {
    
    function setUp() public {}
    
    function run() public {
        vm.startBroadcast();
        
        console.log("=== Tenderly Deployment for Real Gas Comparison ===");
        console.log("Deploying comprehensive gas testing suite...");
        
        // Deploy the comprehensive gas testing contract
        TenderlyGasTest gasTest = new TenderlyGasTest();
        
        console.log("TenderlyGasTest deployed at:", address(gasTest));
        
        // Run the comprehensive analysis
        console.log("\\nRunning comprehensive gas analysis...");
        
        // Run all comparisons
        YOLOComparison[] memory comparisons = gasTest.compareForYOLO();
        GasScenario[] memory scenarios = gasTest.analyzeYOLOScenarios();
        
        console.log("\\n=== Analysis Results ===");
        
        // Print summary results
        for (uint256 i = 0; i < comparisons.length; i++) {
            console.log(string(abi.encodePacked(
                comparisons[i].implementation, ": ",
                "t=", vm.toString(comparisons[i].tValue), ", ",
                "Gas: ", vm.toString(comparisons[i].totalGas), " gas"
            )));
        }
        
        console.log("\\n=== Tenderly Deployment Complete ===");
        console.log("Gas testing suite deployed and analyzed successfully!");
        
        vm.stopBroadcast();
    }
}