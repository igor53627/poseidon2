// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../Poseidon2Main.sol";

/**
 * @title Poseidon2 Gas Benchmark Script
 * @notice Comprehensive gas usage benchmarking for our implementation
 */
contract BenchmarkScript is Script {
    Poseidon2Main public poseidon;
    
    struct BenchmarkResult {
        uint256 inputSize;
        uint256 gasUsed;
        uint256 gasPerElement;
    }
    
    function setUp() public {
        // Deploy contract for benchmarking
        poseidon = new Poseidon2Main();
    }
    
    function run() public {
        console.log("=== Poseidon2 Gas Benchmark ===");
        console.log("Contract deployed at:", address(poseidon));
        
        // Benchmark different input sizes
        BenchmarkResult[] memory results = new BenchmarkResult[](11);
        
        for (uint256 i = 1; i <= 11; i++) {
            results[i-1] = benchmarkInputSize(i);
        }
        
        // Display results
        displayResults(results);
        
        // Benchmark specific operations
        benchmarkOperations();
        
        // Compare with estimates
        compareWithEstimates(results);
    }
    
    function benchmarkInputSize(uint256 size) internal returns (BenchmarkResult memory) {
        uint256[] memory input = new uint256[](size);
        for (uint256 j = 0; j < size; j++) {
            input[j] = j + 1; // Simple test data
        }
        
        // Warm up
        poseidon.hash(input);
        
        // Actual benchmark
        uint256 gasStart = gasleft();
        uint256 result = poseidon.hash(input);
        uint256 gasUsed = gasStart - gasleft();
        
        // Verify result is valid
        require(result < 0xFFFFFFFF00000001, "Invalid result");
        require(result != 0, "Zero result");
        
        return BenchmarkResult({
            inputSize: size,
            gasUsed: gasUsed,
            gasPerElement: gasUsed / size
        });
    }
    
    function benchmarkOperations() internal {
        console.log("\n=== Operation-Specific Benchmarks ===");
        
        // Benchmark Merkle hash
        uint256 left = 0x1234567890abcdef;
        uint256 right = 0xfedcba0987654321;
        
        uint256 gasStart = gasleft();
        uint256 merkleResult = poseidon.merkleHash(left, right);
        uint256 merkleGas = gasStart - gasleft();
        
        console.log("Merkle Hash (2 elements):", merkleGas, "gas");
        
        // Benchmark batch hash
        uint256[][] memory batchInputs = new uint256[][](5);
        for (uint256 i = 0; i < 5; i++) {
            batchInputs[i] = new uint256[](3);
            batchInputs[i][0] = i + 1;
            batchInputs[i][1] = i + 2;
            batchInputs[i][2] = i + 3;
        }
        
        gasStart = gasleft();
        uint256[] memory batchResults = poseidon.batchHash(batchInputs);
        uint256 batchGas = gasStart - gasleft();
        
        console.log("Batch Hash (5x3 elements):", batchGas, "gas");
        console.log("Per hash average:", batchGas / 5, "gas");
        
        // Benchmark permutation directly
        uint256[12] memory state;
        for (uint256 i = 0; i < 12; i++) {
            state[i] = i + 1;
        }
        
        gasStart = gasleft();
        uint256[12] memory permuted = poseidon.permute(state);
        uint256 permuteGas = gasStart - gasleft();
        
        console.log("Full Permutation (t=12):", permuteGas, "gas");
    }
    
    function displayResults(BenchmarkResult[] memory results) internal view {
        console.log("\n=== Input Size Benchmark Results ===");
        console.log("Size | Gas Used | Gas/Element | Est. USD*");
        console.log("-----|----------|-------------|----------");
        
        for (uint256 i = 0; i < results.length; i++) {
            BenchmarkResult memory result = results[i];
            uint256 usdCost = (result.gasUsed * 20 gwei * 2000) / 1e18; // Assumes 20 gwei, $2000/ETH
            
            console.log(
                string(abi.encodePacked(
                    vm.toString(result.inputSize), "   | ",
                    vm.toString(result.gasUsed), "  | ",
                    vm.toString(result.gasPerElement), "      | $",
                    vm.toString(usdCost)
                ))
            );
        }
        
        console.log("\n*USD cost assumes 20 gwei gas price, $2000/ETH");
    }
    
    function compareWithEstimates(BenchmarkResult[] memory actual) internal view {
        console.log("\n=== Comparison with Estimates ===");
        
        uint256[] memory estimates = new uint256[](11);
        estimates[0] = 45000;  // 1 element
        estimates[1] = 55000;  // 2 elements
        estimates[2] = 65000;  // 3 elements
        estimates[3] = 75000;  // 4 elements
        estimates[4] = 85000;  // 5 elements
        estimates[5] = 95000;  // 6 elements
        estimates[6] = 105000; // 7 elements
        estimates[7] = 115000; // 8 elements
        estimates[8] = 125000; // 9 elements
        estimates[9] = 135000; // 10 elements
        estimates[10] = 145000; // 11 elements
        
        console.log("Size | Actual | Estimate | Difference");
        console.log("-----|--------|----------|----------");
        
        uint256 totalDifference = 0;
        for (uint256 i = 0; i < actual.length; i++) {
            int256 difference = int256(actual[i].gasUsed) - int256(estimates[i]);
            totalDifference += uint256(difference > 0 ? difference : -difference);
            
            console.log(
                string(abi.encodePacked(
                    vm.toString(actual[i].inputSize), "   | ",
                    vm.toString(actual[i].gasUsed), "   | ",
                    vm.toString(estimates[i]), "    | ",
                    difference > 0 ? "+" : "",
                    vm.toString(uint256(difference > 0 ? difference : -difference))
                ))
            );
        }
        
        uint256 avgDifference = totalDifference / actual.length;
        console.log("Average difference:", avgDifference, "gas");
        
        if (avgDifference < 5000) {
            console.log("✅ Estimates are very accurate!");
        } else if (avgDifference < 15000) {
            console.log("⚠️  Estimates are reasonably accurate");
        } else {
            console.log("❌ Estimates need significant adjustment");
        }
    }
    
    function benchmarkComparison() internal view {
        console.log("\n=== Comparison with zemse/poseidon2-evm ===");
        
        // Their reported gas costs
        uint256[] memory theirCosts = new uint256[](10);
        theirCosts[0] = 219544; // 1 element
        theirCosts[1] = 220018; // 2 elements
        theirCosts[2] = 220641; // 3 elements
        theirCosts[3] = 416486; // 4 elements
        theirCosts[4] = 417197; // 5 elements
        theirCosts[5] = 417952; // 6 elements
        theirCosts[6] = 604599; // 7 elements
        theirCosts[7] = 605311; // 8 elements
        theirCosts[8] = 606064; // 9 elements
        theirCosts[9] = 792604; // 10 elements
        
        // Our actual costs (from benchmark)
        uint256[] memory ourCosts = new uint256[](10);
        // These would be populated from actual benchmark results
        
        console.log("Size | Their Gas | Our Gas | Savings | Savings %");
        console.log("-----|-----------|---------|---------|----------");
        
        for (uint256 i = 0; i < 10; i++) {
            if (ourCosts[i] > 0) {
                uint256 savings = theirCosts[i] - ourCosts[i];
                uint256 savingsPercent = (savings * 100) / theirCosts[i];
                
                console.log(
                    string(abi.encodePacked(
                        vm.toString(i + 1), "   | ",
                        vm.toString(theirCosts[i]), "   | ",
                        vm.toString(ourCosts[i]), "   | ",
                        vm.toString(savings), "   | ",
                        vm.toString(savingsPercent), "%"
                    ))
                );
            }
        }
    }
}