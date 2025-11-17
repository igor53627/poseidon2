// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@poseidon2/zemse-implementation/Poseidon2.sol";
import "@poseidon2/zemse-implementation/Field.sol";
import "@poseidon2/cardinal-implementation/Poseidon2T8.sol";
import "forge-std/Test.sol";

/**
 * @title Gas Benchmark for Poseidon2 Implementations
 * @notice Comprehensive gas usage benchmarking
 */
contract GasBenchmark is Test {
    
    struct BenchmarkResult {
        string implementation;
        uint256 inputSize;
        uint256 gasUsed;
        uint256 result;
        bool success;
    }
    
    event BenchmarkComplete(BenchmarkResult result);
    
    /**
     * @notice Benchmark zemse implementation with different input sizes
     */
    function benchmarkZemse() public returns (BenchmarkResult[] memory) {
        BenchmarkResult[] memory results = new BenchmarkResult[](7);
        
        for (uint256 i = 1; i <= 7; i++) {
            results[i-1] = _benchmarkZemseInput(i);
        }
        
        return results;
    }
    
    /**
     * @notice Benchmark Cardinal implementation with different input sizes
     */
    function benchmarkCardinal() public returns (BenchmarkResult[] memory) {
        BenchmarkResult[] memory results = new BenchmarkResult[](7);
        
        for (uint256 i = 1; i <= 7; i++) {
            results[i-1] = _benchmarkCardinalInput(i);
        }
        
        return results;
    }
    
    /**
     * @notice Run comprehensive gas benchmark
     */
    function runComprehensiveBenchmark() public returns (string memory) {
        BenchmarkResult[] memory zemseResults = benchmarkZemse();
        BenchmarkResult[] memory cardinalResults = benchmarkCardinal();
        
        return _generateBenchmarkReport(zemseResults, cardinalResults);
    }
    
    /**
     * @notice Benchmark specific input size for zemse
     */
    function _benchmarkZemseInput(uint256 inputSize) internal returns (BenchmarkResult memory) {
        require(inputSize <= 7, "zemse implementation supports max 7 inputs");
        
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < inputSize; i++) {
            input[i] = i + 1;
        }
        
        // Convert to Field.Type for zemse
        Field.Type[] memory zemseInput = new Field.Type[](inputSize);
        for (uint256 i = 0; i < inputSize; i++) {
            zemseInput[i] = Field.toField(input[i]);
        }
        
        uint256 gasStart = gasleft();
        Field.Type result = Poseidon2.hash(zemseInput, zemseInput.length, false);
        uint256 gasUsed = gasStart - gasleft();
        
        BenchmarkResult memory benchmark = BenchmarkResult({
            implementation: "zemse",
            inputSize: inputSize,
            gasUsed: gasUsed,
            result: Field.toUint256(result),
            success: true
        });
        
        emit BenchmarkComplete(benchmark);
        return benchmark;
    }
    
    /**
     * @notice Benchmark specific input size for Cardinal
     */
    function _benchmarkCardinalInput(uint256 inputSize) internal returns (BenchmarkResult memory) {
        require(inputSize <= 7, "Cardinal implementation supports max 7 inputs");
        
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < inputSize; i++) {
            input[i] = i + 1;
        }
        
        uint256 gasStart = gasleft();
        uint256 result = Poseidon2T8.hash(input);
        uint256 gasUsed = gasStart - gasleft();
        
        BenchmarkResult memory benchmark = BenchmarkResult({
            implementation: "cardinal",
            inputSize: inputSize,
            gasUsed: gasUsed,
            result: result,
            success: true
        });
        
        emit BenchmarkComplete(benchmark);
        return benchmark;
    }
    
    /**
     * @notice Benchmark Merkle tree operations
     */
    function benchmarkMerkleOperations() public returns (BenchmarkResult[] memory) {
        BenchmarkResult[] memory results = new BenchmarkResult[](10);
        
        for (uint256 i = 0; i < 10; i++) {
            uint256 left = uint256(keccak256(abi.encodePacked("left", i)));
            uint256 right = uint256(keccak256(abi.encodePacked("right", i)));
            
            // Test zemse Merkle hash
            uint256[] memory input = new uint256[](2);
            input[0] = left;
            input[1] = right;
            
            Field.Type[] memory zemseInput = new Field.Type[](2);
            zemseInput[0] = Field.toField(left);
            zemseInput[1] = Field.toField(right);
            
            uint256 gasStart = gasleft();
            Field.Type zemseResult = Poseidon2.hash(zemseInput, zemseInput.length, false);
            uint256 zemseGas = gasStart - gasleft();
            
            results[i] = BenchmarkResult({
                implementation: "merkle",
                inputSize: 2,
                gasUsed: zemseGas,
                result: Field.toUint256(zemseResult),
                success: true
            });
            
            emit BenchmarkComplete(results[i]);
        }
        
        return results;
    }
    
    /**
     * @notice Stress test with random inputs
     */
    function stressTest(uint256 iterations) public returns (BenchmarkResult[] memory) {
        BenchmarkResult[] memory results = new BenchmarkResult[](iterations);
        
        for (uint256 i = 0; i < iterations; i++) {
            uint256 inputSize = (i % 7) + 1; // 1-7 elements
            
            if (i % 2 == 0) {
                // Test zemse
                results[i] = _benchmarkZemseInput(inputSize);
            } else {
                // Test Cardinal
                results[i] = _benchmarkCardinalInput(inputSize);
            }
        }
        
        return results;
    }
    
    /**
     * @notice Generate comprehensive benchmark report
     */
    function _generateBenchmarkReport(
        BenchmarkResult[] memory zemseResults,
        BenchmarkResult[] memory cardinalResults
    ) internal pure returns (string memory) {
        string memory report = "# Poseidon2 Gas Benchmark Report\\n\\n";
        
        // Calculate totals
        uint256 totalZemseGas = 0;
        uint256 totalCardinalGas = 0;
        
        for (uint256 i = 0; i < zemseResults.length; i++) {
            totalZemseGas += zemseResults[i].gasUsed;
        }
        for (uint256 i = 0; i < cardinalResults.length; i++) {
            totalCardinalGas += cardinalResults[i].gasUsed;
        }
        
        uint256 avgZemseGas = totalZemseGas / zemseResults.length;
        uint256 avgCardinalGas = totalCardinalGas / cardinalResults.length;
        
        report = string(abi.encodePacked(report, "## Summary Statistics\\n"));
        report = string(abi.encodePacked(report, "- Total Zemse Gas: ", vm.toString(totalZemseGas), "\\n"));
        report = string(abi.encodePacked(report, "- Total Cardinal Gas: ", vm.toString(totalCardinalGas), "\\n"));
        report = string(abi.encodePacked(report, "- Average Zemse Gas: ", vm.toString(avgZemseGas), "\\n"));
        report = string(abi.encodePacked(report, "- Average Cardinal Gas: ", vm.toString(avgCardinalGas), "\\n\\n"));
        
        // Add detailed results
        report = string(abi.encodePacked(report, "## Detailed Results by Input Size\\n"));
        report = string(abi.encodePacked(report, "| Input Size | Zemse Gas | Cardinal Gas |\\n"));
        report = string(abi.encodePacked(report, "|------------|-----------|--------------|\\n"));
        
        for (uint256 i = 0; i < zemseResults.length; i++) {
            report = string(abi.encodePacked(
                report, "| ", vm.toString(zemseResults[i].inputSize), " | ",
                vm.toString(zemseResults[i].gasUsed), " | ",
                vm.toString(cardinalResults[i].gasUsed), " |\\n"
            ));
        }
        
        return report;
    }
}