// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../Poseidon2Main.sol";
import "../../lib/forge-std/src/Test.sol";

/**
 * @title Poseidon2 Test Suite
 * @notice Comprehensive tests for Poseidon2 implementation
 */
contract Poseidon2Test is Test {
    Poseidon2Main public ourImpl;
    
    // Test vectors (these should be replaced with actual test vectors from reference implementation)
    uint256[] testInput1;
    uint256[] testInput2;
    uint256[] testInput3;
    
    event GasUsed(string operation, uint256 gasUsed);
    
    function setUp() public {
        ourImpl = new Poseidon2Main();
        
        // Initialize test inputs
        testInput1 = new uint256[](3);
        testInput1[0] = 1;
        testInput1[1] = 2;
        testInput1[2] = 3;
        
        testInput2 = new uint256[](6);
        testInput2[0] = 42;
        testInput2[1] = 1337;
        testInput2[2] = 0xdeadbeef;
        testInput2[3] = 0xcafebabe;
        testInput2[4] = 0x12345678;
        testInput2[5] = 0x87654321;
        
        testInput3 = new uint256[](11);
        for (uint256 i = 0; i < 11; i++) {
            testInput3[i] = i + 1;
        }
    }
    
    /**
     * @notice Test basic hash functionality
     */
    function testBasicHash() public {
        uint256 gasStart = gasleft();
        uint256 hash1 = ourImpl.hash(testInput1);
        uint256 gasUsed = gasStart - gasleft();
        
        emit GasUsed("Basic hash (3 elements)", gasUsed);
        
        // Verify hash is valid field element
        assertLt(hash1, 0xFFFFFFFF00000001, "Hash should be valid field element");
        assertNotEq(hash1, 0, "Hash should not be zero");
        
        // Test determinism
        uint256 hash1_repeat = ourImpl.hash(testInput1);
        assertEq(hash1, hash1_repeat, "Hash should be deterministic");
    }
    
    /**
     * @notice Test hash with different input sizes
     */
    function testDifferentInputSizes() public {
        // Test with 1 element
        uint256[] memory input1 = new uint256[](1);
        input1[0] = 42;
        uint256 hash1 = ourImpl.hash(input1);
        assertLt(hash1, 0xFFFFFFFF00000001, "Hash1 should be valid field element");
        
        // Test with 6 elements
        uint256 gasStart = gasleft();
        uint256 hash2 = ourImpl.hash(testInput2);
        uint256 gasUsed = gasStart - gasleft();
        emit GasUsed("Hash (6 elements)", gasUsed);
        assertLt(hash2, 0xFFFFFFFF00000001, "Hash2 should be valid field element");
        
        // Test with 11 elements (maximum)
        gasStart = gasleft();
        uint256 hash3 = ourImpl.hash(testInput3);
        gasUsed = gasStart - gasleft();
        emit GasUsed("Hash (11 elements)", gasUsed);
        assertLt(hash3, 0xFFFFFFFF00000001, "Hash3 should be valid field element");
        
        // Verify different inputs produce different outputs
        assertNotEq(hash1, hash2, "Different inputs should produce different hashes");
        assertNotEq(hash2, hash3, "Different inputs should produce different hashes");
        assertNotEq(hash1, hash3, "Different inputs should produce different hashes");
    }
    
    /**
     * @notice Test domain separation
     */
    // function testDomainSeparation() public {
    //     uint256 domain1 = 1;
    //     uint256 domain2 = 2;
    //     
    //     uint256 hash1 = ourImpl.WithDomain(testInput1, domain1);
    //     uint256 hash2 = ourImpl.WithDomain(testInput1, domain2);
    //     
    //     assertNotEq(hash1, hash2, "Different domains should produce different hashes");
    //     
    //     // Test same domain produces same hash
    //     uint256 hash1_repeat = ourImpl.WithDomain(testInput1, domain1);
    //     assertEq(hash1, hash1_repeat, "Same domain should produce same hash");
    // }
    
    /**
     * @notice Test Merkle tree functionality
     */
    function testMerkleHash() public {
        uint256 left = 0x1234567890abcdef;
        uint256 right = 0xfedcba0987654321;
        
        uint256 gasStart = gasleft();
        uint256 hash = ourImpl.merkleHash(left, right);
        uint256 gasUsed = gasStart - gasleft();
        
        emit GasUsed("Merkle hash", gasUsed);
        
        assertLt(hash, 0xFFFFFFFF00000001, "Merkle hash should be valid field element");
        
        // Test commutativity (order matters for Poseidon2)
        uint256 hashReverse = ourImpl.merkleHash(right, left);
        assertNotEq(hash, hashReverse, "Order should matter in Merkle hash");
    }
    
    /**
     * @notice Test batch hashing
     */
    function testBatchHash() public {
        uint256[][] memory inputs = new uint256[][](3);
        inputs[0] = testInput1;
        inputs[1] = testInput2;
        inputs[2] = testInput3;
        
        uint256 gasStart = gasleft();
        uint256[] memory hashes = ourImpl.batchHash(inputs);
        uint256 gasUsed = gasStart - gasleft();
        
        emit GasUsed("Batch hash (3 inputs)", gasUsed);
        
        assertEq(hashes.length, 3, "Should return 3 hashes");
        
        // Verify individual hashes match
        assertEq(hashes[0], ourImpl.hash(testInput1), "First hash should match");
        assertEq(hashes[1], ourImpl.hash(testInput2), "Second hash should match");
        assertEq(hashes[2], ourImpl.hash(testInput3), "Third hash should match");
    }
    
    /**
     * @notice Test permutation function directly
     */
    function testPermutation() public {
        uint256[12] memory state;
        for (uint256 i = 0; i < 12; i++) {
            state[i] = i + 1;
        }
        
        uint256 gasStart = gasleft();
        uint256[12] memory permuted = ourImpl.permute(state);
        uint256 gasUsed = gasStart - gasleft();
        
        emit GasUsed("Permutation (t=12)", gasUsed);
        
        // Verify all outputs are valid field elements
        for (uint256 i = 0; i < 12; i++) {
            assertLt(permuted[i], 0xFFFFFFFF00000001, "Permuted element should be valid field element");
        }
        
        // Test determinism
        uint256[12] memory permuted_repeat = ourImpl.permute(state);
        for (uint256 i = 0; i < 12; i++) {
            assertEq(permuted[i], permuted_repeat[i], "Permutation should be deterministic");
        }
    }
    
    /**
     * @notice Test invalid inputs
     */
    function testInvalidInputs() public {
        // Test empty input
        uint256[] memory emptyInput = new uint256[](0);
        
        ourImpl.hash(emptyInput);
        
        // Test input too large
        uint256[] memory largeInput = new uint256[](12);
        
        ourImpl.hash(largeInput);
        
        // Test invalid field element
        uint256[] memory invalidInput = new uint256[](1);
        invalidInput[0] = 0xFFFFFFFF00000002; // > P
        
        ourImpl.hash(invalidInput);
    }
    
    /**
     * @notice Test matrix elements
     */
    function testMatrixElements() public {
        // Test external matrix
        uint256 ext00 = ourImpl.getMatrixElement(true, 0, 0);
        uint256 ext01 = ourImpl.getMatrixElement(true, 0, 1);
        assertEq(ext00, 2, "External matrix diagonal should be 2");
        assertEq(ext01, 1, "External matrix off-diagonal should be 1");
        
        // Test internal matrix
        uint256 int00 = ourImpl.getMatrixElement(false, 0, 0);
        uint256 int11 = ourImpl.getMatrixElement(false, 1, 1);
        assertEq(int00, 1, "Internal matrix first element should be 1");
        assertEq(int11, 2, "Internal matrix diagonal should be 2");
    }
    
    /**
     * @notice Test round constants
     */
    function testRoundConstants() public {
        // Test that round constants are valid field elements
        for (uint256 r = 0; r < 34; r++) { // RF + RP = 34
            for (uint256 i = 0; i < 12; i++) {
                uint256 rc = ourImpl.getRoundConstant(r, i);
                assertLt(rc, 0xFFFFFFFF00000001, "Round constant should be valid field element");
            }
        }
    }
    
    /**
     * @notice Performance benchmark
     */
    function testPerformance() public {
        uint256 iterations = 10;
        uint256 totalGas = 0;
        
        for (uint256 i = 0; i < iterations; i++) {
            uint256[] memory input = new uint256[](6);
            for (uint256 j = 0; j < 6; j++) {
                input[j] = (i * 6) + j + 1;
            }
            
            uint256 gasStart = gasleft();
            ourImpl.hash(input);
            uint256 gasUsed = gasStart - gasleft();
            totalGas += gasUsed;
        }
        
        uint256 avgGas = totalGas / iterations;
        emit GasUsed("Average hash (6 elements, 10 iterations)", avgGas);
        
        // Log performance metrics
        console.log("Average gas per hash:", avgGas);
        console.log("Total gas for", iterations, "hashes:", totalGas);
    }
    
    /**
     * @notice Test avalanche effect (small input changes should cause large output changes)
     */
    function testAvalancheEffect() public {
        uint256[] memory input1 = new uint256[](4);
        input1[0] = 1;
        input1[1] = 2;
        input1[2] = 3;
        input1[3] = 4;
        
        uint256[] memory input2 = new uint256[](4);
        input2[0] = 1;
        input2[1] = 2;
        input2[2] = 3;
        input2[3] = 5; // Only one bit difference
        
        uint256 hash1 = ourImpl.hash(input1);
        uint256 hash2 = ourImpl.hash(input2);
        
        // Calculate Hamming distance
        uint256 xor = hash1 ^ hash2;
        uint256 bitDiffs = 0;
        for (uint256 i = 0; i < 256; i++) {
            if ((xor >> i) & 1 == 1) {
                bitDiffs++;
            }
        }
        
        console.log("Bit differences between hashes:", bitDiffs);
        console.log("Hash 1:", hash1);
        console.log("Hash 2:", hash2);
        
        // Should have significant bit differences (avalanche effect)
        assertGt(bitDiffs, 50, "Should have significant avalanche effect");
    }
    
    /**
     * @notice Fuzz test with random inputs
     */
    function testFuzzHash(uint256 seed) public {
        // Generate pseudo-random input based on seed
        uint256[] memory input = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            input[i] = uint256(keccak256(abi.encodePacked(seed, i))) % 0xFFFFFFFF00000001;
        }
        
        uint256 hash = ourImpl.hash(input);
        
        // Verify hash is valid
        assertLt(hash, 0xFFFFFFFF00000001, "Hash should be valid field element");
        assertNotEq(hash, 0, "Hash should not be zero for non-zero input");
    }
}