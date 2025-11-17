// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../Poseidon2Main.sol";

/**
 * @title Poseidon2 Deployment Script
 * @notice Deploys the Poseidon2 hash function contract
 */
contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        console.log("Deploying Poseidon2...");
        
        // Deploy the main contract
        Poseidon2Main poseidon = new Poseidon2Main();
        
        console.log("Poseidon2 deployed at:", address(poseidon));
        console.log("Gas used for deployment:", vm.lastCallGas().gasTotalUsed);
        
        // Test basic functionality
        console.log("Testing basic hash...");
        uint256[] memory testInput = new uint256[](3);
        testInput[0] = 1;
        testInput[1] = 2;
        testInput[2] = 3;
        
        uint256 testHash = poseidon.hash(testInput);
        console.log("Test hash result:", testHash);
        
        // Verify it's a valid field element
        require(testHash < 0xFFFFFFFF00000001, "Invalid hash result");
        require(testHash != 0, "Hash should not be zero");
        
        console.log("Deployment successful!");
        
        vm.stopBroadcast();
    }
}