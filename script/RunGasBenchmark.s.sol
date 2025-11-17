// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@poseidon2/comparison-tools/GasBenchmarkFixed.sol";

/**
 * @title Run Gas Benchmark Script
 * @notice Executes comprehensive gas benchmarking for all implementations
 */
contract RunGasBenchmark is Script {
    
    function setUp() public {}
    
    function run() public {
        vm.startBroadcast();
        
        console.log("=== Poseidon2 Gas Benchmark ===");
        console.log("Running comprehensive gas analysis...");
        
        // Deploy the gas benchmark contract
        GasBenchmarkFixed benchmark = new GasBenchmarkFixed();
        
        // 1. Benchmark different input sizes
        console.log("\\n1. Input Size Benchmark");
        runInputSizeBenchmark(benchmark);
        
        // 2. Benchmark Merkle operations
        console.log("\\n2. Merkle Tree Benchmark");
        runMerkleBenchmark(benchmark);
        
        // 3. Run comprehensive report
        console.log("\\n3. Comprehensive Report");
        string memory report = benchmark.runComprehensiveBenchmark();
        console.log(report);
        
        // 4. Quick comparison summary
        console.log("\\n4. Quick Comparison Summary");
        runQuickComparison(benchmark);
        
        vm.stopBroadcast();
        
        console.log("\\n✅ Gas benchmark complete!");
    }
    
    function runInputSizeBenchmark(GasBenchmarkFixed benchmark) internal {
        console.log("Input Size | Zemse Gas | Cardinal Gas | Best");
        console.log("-----------|-----------|--------------|-----");
        
        GasBenchmarkFixed.BenchmarkResult[] memory zemseResults = benchmark.benchmarkZemse();
        GasBenchmarkFixed.BenchmarkResult[] memory cardinalResults = benchmark.benchmarkCardinal();
        
        for (uint256 i = 0; i < zemseResults.length; i++) {
            uint256 zemseGas = zemseResults[i].gasUsed;
            uint256 cardinalGas = cardinalResults[i].gasUsed;
            string memory best = zemseGas < cardinalGas ? "Zemse" : "Cardinal";
            
            console.log(
                string(abi.encodePacked(
                    vm.toString(i + 1), "         | ",
                    vm.toString(zemseGas), "     | ",
                    vm.toString(cardinalGas), "     | ",
                    best
                ))
            );
        }
        
        // Calculate averages
        uint256 avgZemseGas = 0;
        uint256 avgCardinalGas = 0;
        
        for (uint256 i = 0; i < zemseResults.length; i++) {
            avgZemseGas += zemseResults[i].gasUsed;
            avgCardinalGas += cardinalResults[i].gasUsed;
        }
        
        avgZemseGas /= zemseResults.length;
        avgCardinalGas /= cardinalResults.length;
        
        console.log("\\nAverage Gas Usage:");
        console.log("Zemse Average:", avgZemseGas);
        console.log("Cardinal Average:", avgCardinalGas);
    }
    
    function runMerkleBenchmark(GasBenchmarkFixed benchmark) internal {
        GasBenchmarkFixed.BenchmarkResult[] memory results = benchmark.benchmarkMerkleOperations();
        
        console.log("Iteration | Gas Used | Result");
        console.log("----------|----------|-------");
        
        uint256 totalGas = 0;
        for (uint256 i = 0; i < results.length; i++) {
            console.log(
                string(abi.encodePacked(
                    vm.toString(i), "         | ",
                    vm.toString(results[i].gasUsed), "     | ",
                    vm.toString(results[i].result)
                ))
            );
            totalGas += results[i].gasUsed;
        }
        
        uint256 avgGas = totalGas / results.length;
        console.log("\\nAverage Merkle Hash Gas:", avgGas);
    }
    
    function runQuickComparison(GasBenchmarkFixed benchmark) internal {
        // Test a few specific cases
        uint256[] memory input1 = new uint256[](1);
        input1[0] = 42;
        
        uint256[] memory input3 = new uint256[](3);
        input3[0] = 1;
        input3[1] = 2;
        input3[2] = 3;
        
        uint256[] memory input7 = new uint256[](7);
        for (uint256 i = 0; i < 7; i++) {
            input7[i] = i + 1;
        }
        
        console.log("\\nQuick Comparison Results:");
        console.log("Input Size | Zemse Gas | Cardinal Gas | Savings");
        console.log("-----------|-----------|--------------|--------");
        
        // Test 1 element
        GasBenchmarkFixed.BenchmarkResult memory result1 = _benchmarkSingle(input1);
        
        // Test 3 elements
        GasBenchmarkFixed.BenchmarkResult memory result3 = _benchmarkSingle(input3);
        
        // Test 7 elements
        GasBenchmarkFixed.BenchmarkResult memory result7 = _benchmarkSingle(input7);
        
        // Calculate savings
        uint256 savings1 = result1.gasUsed < result1.gasUsed ? 0 : ((result1.gasUsed - result1.gasUsed) * 100 / result1.gasUsed);
        uint256 savings3 = result3.gasUsed < result3.gasUsed ? 0 : ((result3.gasUsed - result3.gasUsed) * 100 / result3.gasUsed);
        uint256 savings7 = result7.gasUsed < result7.gasUsed ? 0 : ((result7.gasUsed - result7.gasUsed) * 100 / result7.gasUsed);
        
        console.log(
            string(abi.encodePacked(
                "1          | ", vm.toString(result1.gasUsed), "     | ",
                vm.toString(result1.gasUsed), "     | ",
                vm.toString(savings1), "%"
            ))
        );
        console.log(
            string(abi.encodePacked(
                "3          | ", vm.toString(result3.gasUsed), "     | ",
                vm.toString(result3.gasUsed), "     | ",
                vm.toString(savings3), "%"
            ))
        );
        console.log(
            string(abi.encodePacked(
                "7          | ", vm.toString(result7.gasUsed), "     | ",
                vm.toString(result7.gasUsed), "     | ",
                vm.toString(savings7), "%"
            ))
        );
    }
    
    function _benchmarkSingle(uint256[] memory input) internal returns (GasBenchmarkFixed.BenchmarkResult memory) {
        // This is a simplified version - in practice you'd test both implementations
        GasBenchmarkFixed.BenchmarkResult[] memory results = new GasBenchmarkFixed.BenchmarkResult[](2);
        
        // Test zemse
        Field.Type[] memory zemseInput = new Field.Type[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            zemseInput[i] = Field.toField(input[i]);
        }
        
        uint256 gasStart = gasleft();
        Field.Type zemseResult = zemseImpl.hash(zemseInput, zemseInput.length, false);
        uint256 zemseGas = gasStart - gasleft();
        
        // Test Cardinal
        gasStart = gasleft();
        uint256 cardinalResult = Poseidon2T8.hash(input);
        uint256 cardinalGas = gasStart - gasleft();
        
        // Return the better result
        if (zemseGas < cardinalGas) {
            return GasBenchmarkFixed.BenchmarkResult({
                implementation: "zemse",
                inputSize: input.length,
                gasUsed: zemseGas,
                result: Field.toUint256(zemseResult),
                success: true
            });
        } else {
            return GasBenchmarkFixed.BenchmarkResult({
                implementation: "cardinal",
                inputSize: input.length,
                gasUsed: cardinalGas,
                result: cardinalResult,
                success: true
            });
        }
    }
}