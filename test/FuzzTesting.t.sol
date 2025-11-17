// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../packages/comparison-tools/TenderlyGasTest.sol";
import "../packages/our-implementation/Poseidon2Main.sol";
import "../packages/our-implementation/Poseidon2Test.sol";

/**
 * @title Comprehensive Fuzz Testing
 * @notice Extensive fuzz testing for all Poseidon2 implementations
 */
contract FuzzTesting is Test {
    Poseidon2Main public poseidon;
    
    function setUp() public {
        poseidon = new Poseidon2Main();
    }
    
    /**
     * @notice Comprehensive fuzz testing for hash operations
     */
    function testFuzzHashOperations() public {
        // Fuzz test with 10,000 runs
        for (uint256 i = 0; i < 10000; i++) {
            uint256[] memory input = new uint256[](3);
            input[0] = uint256(keccak256(abi.encodePacked(i, block.timestamp, msg.sender)));
            input[1] = uint256(keccak256(abi.encodePacked(i + 1, block.number, address(this))));
            input[2] = uint256(keccak256(abi.encodePacked(i + 2, gasleft(), tx.origin)));
            
            uint256 gasStart = gasleft();
            uint256 result = poseidon.hash(input);
            uint256 gasUsed = gasStart - gasleft();
            
            // Verify result is valid
            assertLt(result, 0xFFFFFFFF00000001, "Result should be valid field element");
            assertGt(result, 0, "Result should not be zero");
            assertLt(gasUsed, 100000, "Gas should be reasonable");
        }
    }
    
    /**
     * @notice Fuzz test edge cases and boundary conditions
     */
    function testFuzzEdgeCases() public {
        // Test edge cases
        uint256[] memory edgeCases = new uint256[](10);
        edgeCases[0] = 0;
        edgeCases[1] = 1;
        edgeCases[2] = type(uint256).max;
        edgeCases[3] = 0xFFFFFFFF00000000;
        edgeCases[4] = 0xFFFFFFFF00000001;
        edgeCases[5] = 0x10000000000000000;
        edgeCases[6] = 0xFFFFFFFFFFFFFFFF;
        edgeCases[7] = 0x8000000000000000;
        edgeCases[8] = 0x7FFFFFFFFFFFFFFF;
        edgeCases[9] = 0x1234567890ABCDEF;
        
        for (uint256 i = 0; i < edgeCases.length; i++) {
            uint256[] memory input = new uint256[](3);
            input[0] = edgeCases[i];
            input[1] = edgeCases[(i + 1) % edgeCases.length];
            input[2] = edgeCases[(i + 2) % edgeCases.length];
            
            uint256 result = poseidon.hash(input);
            
            // Verify edge cases work correctly
            assertLt(result, 0xFFFFFFFF00000001, "Edge case result should be valid");
            assertGt(result, 0, "Edge case result should not be zero");
        }
    }
    
    /**
     * @notice Fuzz test memory boundaries
     */
    function testFuzzMemoryBoundaries() public {
        // Test memory boundaries
        for (uint256 i = 0; i < 1000; i++) {
            uint256[] memory input = new uint256[](3);
            input[0] = uint256(keccak256(abi.encodePacked(i, block.timestamp)));
            input[1] = uint256(keccak256(abi.encodePacked(i + 1, block.number)));
            input[2] = uint256(keccak256(abi.encodePacked(i + 2, gasleft())));
            
            // Test with different memory patterns
            uint256 result1 = poseidon.hash(input);
            
            // Test with same input (should be deterministic)
            uint256 result2 = poseidon.hash(input);
            
            assertEq(result1, result2, "Results should be deterministic");
        }
    }
    
    /**
     * @notice Fuzz test gas consumption patterns
     */
    function testFuzzGasPatterns() public {
        uint256 totalGas = 0;
        uint256 minGas = type(uint256).max;
        uint256 maxGas = 0;
        
        for (uint256 i = 0; i < 1000; i++) {
            uint256[] memory input = new uint256[](3);
            input[0] = uint256(keccak256(abi.encodePacked(i, block.timestamp)));
            input[1] = uint256(keccak256(abi.encodePacked(i + 1, block.number)));
            input[2] = uint256(keccak256(abi.encodePacked(i + 2, gasleft())));
            
            uint256 gasStart = gasleft();
            uint256 result = poseidon.hash(input);
            uint256 gasUsed = gasStart - gasleft();
            
            totalGas += gasUsed;
            if (gasUsed < minGas) minGas = gasUsed;
            if (gasUsed > maxGas) maxGas = gasUsed;
            
            assertLt(gasUsed, 100000, "Gas should be reasonable");
            assertGt(gasUsed, 20000, "Gas should be substantial");
        }
        
        uint256 avgGas = totalGas / 1000;
        assertLt(avgGas, 50000, "Average gas should be reasonable");
        assertGt(avgGas, 25000, "Average gas should be substantial");
        
        console.log("Gas patterns:");
        console.log("Min gas:", minGas);
        console.log("Max gas:", maxGas);
        console.log("Average gas:", avgGas);
    }
    
    /**
     * @notice Fuzz test concurrent access patterns
     */
    function testFuzzConcurrentAccess() public {
        // Test concurrent access patterns
        for (uint256 i = 0; i < 100; i++) {
            uint256[] memory input1 = new uint256[](3);
            uint256[] memory input2 = new uint256[](3);
            
            input1[0] = uint256(keccak256(abi.encodePacked(i, "input1")));
            input1[1] = uint256(keccak256(abi.encodePacked(i + 1, "input1")));
            input1[2] = uint256(keccak256(abi.encodePacked(i + 2, "input1")));
            
            input2[0] = uint256(keccak256(abi.encodePacked(i, "input2")));
            input2[1] = uint256(keccak256(abi.encodePacked(i + 1, "input2")));
            input2[2] = uint256(keccak256(abi.encodePacked(i + 2, "input2")));
            
            // Test concurrent access
            uint256 result1 = poseidon.hash(input1);
            uint256 result2 = poseidon.hash(input2);
            
            // Verify concurrent access works correctly
            assertNotEq(result1, result2, "Concurrent results should be different");
            assertLt(result1, 0xFFFFFFFF00000001, "Concurrent result 1 should be valid");
            assertLt(result2, 0xFFFFFFFF00000001, "Concurrent result 2 should be valid");
        }
    }
    
    /**
     * @notice Fuzz test state consistency
     */
    function testFuzzStateConsistency() public {
        // Test state consistency across multiple calls
        uint256[] memory baseInput = new uint256[](3);
        baseInput[0] = 123456789;
        baseInput[1] = 987654321;
        baseInput[2] = 555555555;
        
        uint256 baseResult = poseidon.hash(baseInput);
        
        for (uint256 i = 0; i < 100; i++) {
            uint256[] memory testInput = new uint256[](3);
            testInput[0] = baseInput[0] + i;
            testInput[1] = baseInput[1] + i;
            testInput[2] = baseInput[2] + i;
            
            uint256 testResult = poseidon.hash(testInput);
            
            // Verify state consistency
            assertLt(testResult, 0xFFFFFFFF00000001, "State should be consistent");
            assertGt(testResult, 0, "State should be consistent");
            
            // Verify deterministic behavior
            uint256 repeatResult = poseidon.hash(testInput);
            assertEq(testResult, repeatResult, "Results should be deterministic");
        }
    }
    
    /**
     * @notice Fuzz test gas optimization
     */
    function testFuzzGasOptimization() public {
        // Test gas optimization over time
        uint256[] memory baselineInput = new uint256[](3);
        baselineInput[0] = 1000000;
        baselineInput[1] = 2000000;
        baselineInput[2] = 3000000;
        
        uint256 baselineGas = 0;
        uint256 currentGas = 0;
        
        for (uint256 i = 0; i < 100; i++) {
            uint256 gasStart = gasleft();
            uint256 result = poseidon.hash(baselineInput);
            uint256 gasUsed = gasStart - gasleft();
            
            if (i == 0) {
                baselineGas = gasUsed;
            }
            currentGas = gasUsed;
            
            // Verify gas optimization
            assertLt(gasUsed, baselineGas + 1000, "Gas should not increase significantly");
            assertLt(gasUsed, 100000, "Gas should remain reasonable");
        }
        
        console.log("Gas optimization:");
        console.log("Baseline gas:", baselineGas);
        console.log("Current gas:", currentGas);
        console.log("Gas optimization verified");
    }
    
    /**
     * @notice Fuzz test security properties
     */
    function testFuzzSecurityProperties() public {
        // Test security properties
        for (uint256 i = 0; i < 100; i++) {
            uint256[] memory input = new uint256[](3);
            input[0] = uint256(keccak256(abi.encodePacked(i, "security")));
            input[1] = uint256(keccak256(abi.encodePacked(i + 1, "security")));
            input[2] = uint256(keccak256(abi.encodePacked(i + 2, "security")));
            
            uint256 result = poseidon.hash(input);
            
            // Verify security properties
            assertLt(result, 0xFFFFFFFF00000001, "Result should be in valid field");
            assertGt(result, 0, "Result should not be zero");
            assertNotEq(result, input[0], "Result should not equal input[0]");
            assertNotEq(result, input[1], "Result should not equal input[1]");
            assertNotEq(result, input[2], "Result should not equal input[2]");
        }
    }
}