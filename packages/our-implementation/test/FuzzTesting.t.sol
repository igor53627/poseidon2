// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../Poseidon2Main.sol";
import "../../lib/forge-std/src/Test.sol";

/**
 * @title Poseidon2 Fuzz Testing
 * @notice Comprehensive fuzz testing for security validation
 */
contract FuzzTesting is Test {
    Poseidon2Main public poseidon;
    
    event FuzzTestCompleted(string testName, uint256 iterations, bool success);
    
    function setUp() public {
        poseidon = new Poseidon2Main();
    }
    
    /**
     * @notice Test hash consistency with random inputs
     * @dev Same input should always produce same output
     */
    function testFuzzHashConsistency(uint256[3] memory input) public {
        uint256[] memory inputArray = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            inputArray[i] = input[i] % 0xFFFFFFFF00000001;
        }
        
        uint256 result1 = poseidon.hash(inputArray);
        uint256 result2 = poseidon.hash(inputArray);
        
        assertEq(result1, result2, "Hash should be deterministic");
        emit FuzzTestCompleted("HashConsistency", 1, true);
    }
    
    /**
     * @notice Test input validation with random array lengths
     * @dev Should revert for invalid input lengths
     */
    function testFuzzInputValidation(uint8 arrayLength) public {
        vm.assume(arrayLength != 2 && arrayLength != 3 && arrayLength != 4 && 
                 arrayLength != 5 && arrayLength != 6 && arrayLength != 7 && 
                 arrayLength != 8 && arrayLength != 9 && arrayLength != 10 && 
                 arrayLength != 11 && arrayLength != 12);
        
        uint256[] memory input = new uint256[](arrayLength);
        for (uint256 i = 0; i < arrayLength; i++) {
            input[i] = uint256(keccak256(abi.encodePacked(i, block.timestamp)));
        }
        
        vm.expectRevert();
        poseidon.hash(input);
        emit FuzzTestCompleted("InputValidation", 1, true);
    }
    
    /**
     * @notice Test gas bounds with random valid inputs
     * @dev Gas usage should be within reasonable bounds
     */
    function testFuzzGasBounds(uint256[12] memory input, uint8 validLength) public {
        // Only test valid array lengths
        validLength = uint8(bound(validLength, 2, 12));
        
        uint256[] memory inputArray = new uint256[](validLength);
        for (uint256 i = 0; i < validLength; i++) {
            inputArray[i] = input[i] % 0xFFFFFFFF00000001;
        }
        
        uint256 gasStart = gasleft();
        uint256 result = poseidon.hash(inputArray);
        uint256 gasUsed = gasStart - gasleft();
        
        // Gas should be reasonable (between 30k and 100k)
        assertGt(gasUsed, 30000, "Gas usage too low - potential optimization issue");
        assertLt(gasUsed, 100000, "Gas usage too high - potential inefficiency");
        assertNotEq(result, 0, "Result should not be zero");
        
        emit FuzzTestCompleted("GasBounds", 1, true);
    }
    
    /**
     * @notice Test state integrity with sequential calls
     * @dev Multiple calls should not interfere with each other
     */
    function testFuzzStateIntegrity(uint256[3] memory input1, uint256[3] memory input2) public {
        uint256[] memory inputArray1 = new uint256[](3);
        uint256[] memory inputArray2 = new uint256[](3);
        
        for (uint256 i = 0; i < 3; i++) {
            inputArray1[i] = input1[i] % 0xFFFFFFFF00000001;
            inputArray2[i] = input2[i] % 0xFFFFFFFF00000001;
        }
        
        uint256 result1 = poseidon.hash(inputArray1);
        uint256 result2 = poseidon.hash(inputArray2);
        uint256 result1_again = poseidon.hash(inputArray1);
        uint256 result2_again = poseidon.hash(inputArray2);
        
        // Results should be consistent
        assertEq(result1, result1_again, "First input result should be consistent");
        assertEq(result2, result2_again, "Second input result should be consistent");
        
        // Different inputs should produce different results (with high probability)
        if (keccak256(abi.encodePacked(input1)) != keccak256(abi.encodePacked(input2))) {
            assertNotEq(result1, result2, "Different inputs should produce different results");
        }
        
        emit FuzzTestCompleted("StateIntegrity", 1, true);
    }
    
    /**
     * @notice Test boundary values
     * @dev Edge cases should be handled correctly
     */
    function testFuzzBoundaryValues() public {
        // Test with zero inputs
        uint256[] memory zeros = new uint256[](3);
        uint256 hashZeros = poseidon.hash(zeros);
        assertNotEq(hashZeros, 0, "Hash of zeros should not be zero");
        
        // Test with maximum field elements
        uint256[] memory maxValues = new uint256[](3);
        uint256 maxField = 0xFFFFFFFF00000000; // P - 1
        for (uint256 i = 0; i < 3; i++) {
            maxValues[i] = maxField;
        }
        uint256 hashMax = poseidon.hash(maxValues);
        assertNotEq(hashMax, 0, "Hash of max values should not be zero");
        assertNotEq(hashMax, hashZeros, "Different inputs should produce different hashes");
        
        // Test with single element arrays of different sizes
        uint256[] memory single2 = new uint256[](2);
        uint256[] memory single3 = new uint256[](3);
        single2[0] = 1; single2[1] = 2;
        single3[0] = 1; single3[1] = 2; single3[2] = 0;
        
        uint256 hash2 = poseidon.hash(single2);
        uint256 hash3 = poseidon.hash(single3);
        assertNotEq(hash2, hash3, "Different length inputs should produce different hashes");
        
        emit FuzzTestCompleted("BoundaryValues", 1, true);
    }
    
    /**
     * @notice Test overflow protection
     * @dev Large inputs should not cause overflow issues
     */
    function testFuzzOverflowProtection(uint256[3] memory input) public {
        uint256[] memory inputArray = new uint256[](3);
        
        // Use large values that might cause overflow
        for (uint256 i = 0; i < 3; i++) {
            // Make values large but within field bounds
            inputArray[i] = (input[i] % 0xFFFFFFFF00000001);
        }
        
        // Should not revert
        uint256 result = poseidon.hash(inputArray);
        assertNotEq(result, 0, "Result should not be zero");
        assertLt(result, 0xFFFFFFFF00000001, "Result should be within field bounds");
        
        emit FuzzTestCompleted("OverflowProtection", 1, true);
    }
    
    /**
     * @notice Test performance consistency
     * @dev Similar inputs should have similar gas costs
     */
    function testFuzzPerformanceConsistency(uint256[3] memory input) public {
        uint256[] memory inputArray = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            inputArray[i] = input[i] % 0xFFFFFFFF00000001;
        }
        
        // Measure gas for multiple similar calls
        uint256 gasUsed1 = _measureGas(inputArray);
        uint256 gasUsed2 = _measureGas(inputArray);
        uint256 gasUsed3 = _measureGas(inputArray);
        
        // Gas usage should be very consistent (within 1%)
        uint256 avgGas = (gasUsed1 + gasUsed2 + gasUsed3) / 3;
        uint256 deviation1 = gasUsed1 > avgGas ? gasUsed1 - avgGas : avgGas - gasUsed1;
        uint256 deviation2 = gasUsed2 > avgGas ? gasUsed2 - avgGas : avgGas - gasUsed2;
        uint256 deviation3 = gasUsed3 > avgGas ? gasUsed3 - avgGas : avgGas - gasUsed3;
        
        assertLt(deviation1 * 100 / avgGas, 1, "Gas deviation too high");
        assertLt(deviation2 * 100 / avgGas, 1, "Gas deviation too high");
        assertLt(deviation3 * 100 / avgGas, 1, "Gas deviation too high");
        
        emit FuzzTestCompleted("PerformanceConsistency", 1, true);
    }
    
    /**
     * @notice Helper function to measure gas usage
     */
    function _measureGas(uint256[] memory input) internal returns (uint256) {
        uint256 gasStart = gasleft();
        poseidon.hash(input);
        return gasStart - gasleft();
    }
}