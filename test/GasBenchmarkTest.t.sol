// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../packages/comparison-tools/DeployedGasTest.sol";

/**
 * @title Gas Benchmark Test
 * @notice Isolated test for gas benchmarking
 */
contract GasBenchmarkTest is Test {
    DeployedGasTest public gasTest;
    
    function setUp() public {
        gasTest = new DeployedGasTest();
    }
    
    function testGasComparison() public {
        // Test 3-element input
        (uint256 zemseGas, uint256 zemseResult) = gasTest.testZemseGas();
        (uint256 cardinalGas, uint256 cardinalResult) = gasTest.testCardinalGas();
        
        // Log results
        emit log_named_uint("Zemse Gas (3 elements)", zemseGas);
        emit log_named_uint("Cardinal Gas (3 elements)", cardinalGas);
        emit log_named_uint("Gas Difference", cardinalGas > zemseGas ? cardinalGas - zemseGas : 0);
        
        // Calculate savings
        uint256 savings = cardinalGas > zemseGas ? (cardinalGas - zemseGas) * 100 / cardinalGas : 0;
        emit log_named_uint("Savings % vs Cardinal", savings);
        
        // Verify both work
        assertGt(zemseResult, 0);
        assertGt(cardinalResult, 0);
    }
    
    function testInputSizeBenchmark() public {
        GasResult[] memory results = gasTest.benchmarkAllSizes();
        
        emit log("=== Input Size Benchmark Results ===");
        
        uint256 totalZemseGas = 0;
        uint256 totalCardinalGas = 0;
        uint256 zemseCount = 0;
        uint256 cardinalCount = 0;
        
        for (uint256 i = 0; i < results.length; i++) {
            if (keccak256(bytes(results[i].implementation)) == keccak256(bytes("zemse"))) {
                totalZemseGas += results[i].gasUsed;
                zemseCount++;
                emit log_named_uint(string(abi.encodePacked("Zemse ", vm.toString(results[i].inputSize), " elements")), results[i].gasUsed);
            } else if (keccak256(bytes(results[i].implementation)) == keccak256(bytes("cardinal"))) {
                totalCardinalGas += results[i].gasUsed;
                cardinalCount++;
                emit log_named_uint(string(abi.encodePacked("Cardinal ", vm.toString(results[i].inputSize), " elements")), results[i].gasUsed);
            }
        }
        
        uint256 avgZemseGas = totalZemseGas / zemseCount;
        uint256 avgCardinalGas = totalCardinalGas / cardinalCount;
        
        emit log("=== Summary ===");
        emit log_named_uint("Average Zemse Gas", avgZemseGas);
        emit log_named_uint("Average Cardinal Gas", avgCardinalGas);
        
        uint256 overallSavings = avgCardinalGas > avgZemseGas ? (avgCardinalGas - avgZemseGas) * 100 / avgCardinalGas : 0;
        emit log_named_uint("Overall Savings %", overallSavings);
    }
    
    function testMerkleBenchmark() public {
        GasResult[] memory results = gasTest.benchmarkMerkle();
        
        emit log("=== Merkle Tree Benchmark Results ===");
        
        uint256 totalGas = 0;
        for (uint256 i = 0; i < results.length; i++) {
            totalGas += results[i].gasUsed;
            emit log_named_uint(string(abi.encodePacked("Merkle ", vm.toString(i))), results[i].gasUsed);
        }
        
        uint256 avgGas = totalGas / results.length;
        emit log_named_uint("Average Merkle Hash Gas", avgGas);
    }
    
    function testAverageCalculations() public {
        // Run benchmark first
        gasTest.benchmarkAllSizes();
        
        uint256 zemseAvg = gasTest.getAverageGas("zemse");
        uint256 cardinalAvg = gasTest.getAverageGas("cardinal");
        
        emit log_named_uint("Zemse Average Gas", zemseAvg);
        emit log_named_uint("Cardinal Average Gas", cardinalAvg);
        
        // Verify we have data
        assertGt(zemseAvg, 0);
        assertGt(cardinalAvg, 0);
    }
    
    function testBestImplementation() public {
        // Run benchmark first
        gasTest.benchmarkAllSizes();
        
        // Test for 3 elements (common case)
        (string memory bestImpl, uint256 bestGas) = gasTest.getBestImplementation(3);
        
        emit log_named_string("Best Implementation for 3 elements", bestImpl);
        emit log_named_uint("Best Gas for 3 elements", bestGas);
        
        // Verify we got a result
        assertGt(bestGas, 0);
        assertNotEq(bytes(bestImpl).length, 0);
    }
}