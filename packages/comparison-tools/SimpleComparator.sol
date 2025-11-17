// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Import main implementations
import "@poseidon2/our-implementation/Poseidon2Main.sol";
import "@poseidon2/zemse-implementation/Poseidon2.sol";
import "@poseidon2/cardinal-implementation/Poseidon2T8.sol";

import "forge-std/Test.sol";

/**
 * @title Simple Poseidon2 Comparator
 * @notice Simplified comparison focusing on main implementations
 */
contract SimpleComparator is Test {
    // Implementation references
    Poseidon2Main public ourImpl;
    
    // Gas tracking
    struct GasMetrics {
        uint256 ourGas;
        uint256 zemseGas;
        uint256 cardinalGas;
        uint256 blockNumber;
        uint256 timestamp;
    }
    
    struct ComparisonResult {
        uint256 inputSize;
        uint256[] inputs;
        uint256 ourResult;
        uint256 zemseResult;
        uint256 cardinalResult;
        GasMetrics gasUsed;
        bool allResultsValid;
    }
    
    // Events
    event ComparisonComplete(ComparisonResult result);
    event GasMetricsRecorded(GasMetrics metrics);
    
    constructor() {
        // Deploy our implementation
        ourImpl = new Poseidon2Main();
    }
    
    /**
     * @notice Compare main implementations with the same input
     */
    function compareMain(uint256[] memory input) public returns (ComparisonResult memory) {
        ComparisonResult memory result;
        result.inputSize = input.length;
        result.inputs = input;
        
        // Test each implementation and record gas usage
        result.gasUsed = _recordGasUsage(input);
        
        // Get results from each implementation
        result.ourResult = _testOurImplementation(input);
        result.zemseResult = _testZemseImplementation(input);
        result.cardinalResult = _testCardinalImplementation(input);
        
        // Validate results
        result.allResultsValid = _validateResults(result);
        
        emit ComparisonComplete(result);
        return result;
    }
    
    /**
     * @notice Benchmark specific input sizes
     */
    function benchmarkInputSizes() public returns (ComparisonResult[] memory) {
        ComparisonResult[] memory results = new ComparisonResult[](8);
        
        for (uint256 i = 1; i <= 8; i++) {
            uint256[] memory input = new uint256[](i);
            for (uint256 j = 0; j < i; j++) {
                input[j] = j + 1;
            }
            results[i-1] = compareMain(input);
        }
        
        return results;
    }
    
    /**
     * @notice Benchmark Merkle tree operations
     */
    function benchmarkMerkleOperations() public returns (ComparisonResult[] memory) {
        ComparisonResult[] memory results = new ComparisonResult[](5);
        
        for (uint256 i = 0; i < 5; i++) {
            uint256 left = uint256(keccak256(abi.encodePacked("left", i)));
            uint256 right = uint256(keccak256(abi.encodePacked("right", i)));
            
            uint256[] memory input = new uint256[](2);
            input[0] = left;
            input[1] = right;
            
            results[i] = compareMain(input);
        }
        
        return results;
    }
    
    // Internal testing functions
    function _testOurImplementation(uint256[] memory input) internal returns (uint256) {
        uint256 gasStart = gasleft();
        uint256 result = ourImpl.hash(input);
        uint256 gasUsed = gasStart - gasleft();
        
        emit log_named_uint("Our Implementation Gas", gasUsed);
        return result;
    }
    
    function _testZemseImplementation(uint256[] memory input) internal returns (uint256) {
        // Convert to Field.Type for zemse implementation
        Field.Type[] memory zemseInput = new Field.Type[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            zemseInput[i] = Field.toField(input[i]);
        }
        
        uint256 gasStart = gasleft();
        Field.Type result = Poseidon2(address(0x1234567890123456789012345678901234567890)).hash(zemseInput, zemseInput.length, false);
        uint256 gasUsed = gasStart - gasleft();
        
        emit log_named_uint("Zemse Implementation Gas", gasUsed);
        return Field.toUint256(result);
    }
    
    function _testCardinalImplementation(uint256[] memory input) internal returns (uint256) {
        uint256 gasStart = gasleft();
        uint256 result = Poseidon2T8.hash(input);
        uint256 gasUsed = gasStart - gasleft();
        
        emit log_named_uint("Cardinal Implementation Gas", gasUsed);
        return result;
    }
    
    function _recordGasUsage(uint256[] memory input) internal returns (GasMetrics memory) {
        GasMetrics memory metrics;
        
        // Our implementation
        uint256 gasStart = gasleft();
        ourImpl.hash(input);
        metrics.ourGas = gasStart - gasleft();
        
        // Zemse implementation
        Field.Type[] memory zemseInput = new Field.Type[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            zemseInput[i] = Field.toField(input[i]);
        }
        gasStart = gasleft();
        Poseidon2(address(0x1234567890123456789012345678901234567890)).hash(zemseInput, zemseInput.length, false);
        metrics.zemseGas = gasStart - gasleft();
        
        // Cardinal implementation
        gasStart = gasleft();
        Poseidon2T8.hash(input);
        metrics.cardinalGas = gasStart - gasleft();
        
        metrics.blockNumber = block.number;
        metrics.timestamp = block.timestamp;
        
        emit GasMetricsRecorded(metrics);
        return metrics;
    }
    
    function _validateResults(ComparisonResult memory result) internal pure returns (bool) {
        // Check all results are valid field elements
        if (result.ourResult >= 0xFFFFFFFF00000001) return false;
        if (result.zemseResult >= 21888242871839275222246405745257275088548364400416034343698204186575808495617) return false;
        if (result.cardinalResult >= 21888242871839275222246405745257275088548364400416034343698204186575808495617) return false;
        
        // Check no zero results (for non-zero inputs)
        bool hasNonZeroInput = false;
        for (uint256 i = 0; i < result.inputs.length; i++) {
            if (result.inputs[i] != 0) hasNonZeroInput = true;
        }
        
        if (hasNonZeroInput) {
            if (result.ourResult == 0) return false;
            if (result.zemseResult == 0) return false;
            if (result.cardinalResult == 0) return false;
        }
        
        return true;
    }
    
    /**
     * @notice Generate comprehensive comparison report
     */
    function generateReport(ComparisonResult[] memory results) public pure returns (string memory) {
        string memory report = "# Poseidon2 Implementation Comparison Report\\n\\n";
        
        uint256 totalOurGas = 0;
        uint256 totalZemseGas = 0;
        uint256 totalCardinalGas = 0;
        
        for (uint256 i = 0; i < results.length; i++) {
            totalOurGas += results[i].gasUsed.ourGas;
            totalZemseGas += results[i].gasUsed.zemseGas;
            totalCardinalGas += results[i].gasUsed.cardinalGas;
        }
        
        report = string(abi.encodePacked(report, "## Summary Statistics\\n"));
        report = string(abi.encodePacked(report, "- Total Our Gas: ", vm.toString(totalOurGas), "\\n"));
        report = string(abi.encodePacked(report, "- Total Zemse Gas: ", vm.toString(totalZemseGas), "\\n"));
        report = string(abi.encodePacked(report, "- Total Cardinal Gas: ", vm.toString(totalCardinalGas), "\\n"));
        
        uint256 avgSavingsZemse = totalZemseGas > totalOurGas ? (totalZemseGas - totalOurGas) * 100 / totalZemseGas : 0;
        uint256 avgSavingsCardinal = totalCardinalGas > totalOurGas ? (totalCardinalGas - totalOurGas) * 100 / totalCardinalGas : 0;
        
        report = string(abi.encodePacked(report, "- Average Savings vs Zemse: ", vm.toString(avgSavingsZemse), "%\\n"));
        report = string(abi.encodePacked(report, "- Average Savings vs Cardinal: ", vm.toString(avgSavingsCardinal), "%\\n"));
        
        return report;
    }
}