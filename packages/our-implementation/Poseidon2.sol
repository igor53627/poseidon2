// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./Poseidon2Constants.sol";

/**
 * @title Poseidon2 Hash Function
 * @author Poseidon2 Implementation Team
 * @notice Implementation of Poseidon2: A Faster Version of the Poseidon Hash Function
 * @dev Based on IACR 2023/323 paper: https://eprint.iacr.org/2023/323.pdf
 */
library Poseidon2 {
    // Goldilocks field prime: p = 2^64 - 2^32 + 1
    uint256 constant P = 0xFFFFFFFF00000001;
    
    // S-box exponent alpha = 5 (since gcd(5, p-1) = 1 for Goldilocks field)
    uint256 constant ALPHA = 5;
    
    // Default parameters for width t=12 (common in Plonky3)
    uint256 constant T = 12;
    uint256 constant RF = 8;  // Full rounds (RF/2 + RP + RF/2)
    uint256 constant RP = 26; // Partial rounds
    
    // Error messages
    error InvalidInputLength();
    error InvalidFieldElement();
    
    /**
     * @notice Main Poseidon2 hash function
     * @param input Array of field elements to hash
     * @param domainSeparator Domain separation tag
     * @return Output hash as a field element
     */
    function hash(uint256[] memory input, uint256 domainSeparator) 
        internal 
        pure 
        returns (uint256) 
    {
        if (input.length == 0 || input.length >= T) {
            revert InvalidInputLength();
        }
        
        // Validate all inputs are valid field elements
        for (uint256 i = 0; i < input.length; i++) {
            if (input[i] >= P) {
                revert InvalidFieldElement();
            }
        }
        
        // Initialize state with padding
        uint256[] memory state = new uint256[](T);
        
        // Set domain separator and input
        state[0] = domainSeparator;
        for (uint256 i = 0; i < input.length; i++) {
            state[i + 1] = input[i];
        }
        
        // Apply padding with capacity elements
        state[input.length + 1] = 1; // Padding delimiter
        
        // Apply Poseidon2 permutation
        permute(state);
        
        // Return first element as hash output
        return state[0];
    }
    
    /**
     * @notice Poseidon2 permutation function
     * @param state State array of t field elements (modified in-place)
     */
    function permute(uint256[] memory state) internal pure {
        uint256 t = state.length;
        
        // Apply initial linear layer (external matrix multiplication)
        externalLinearLayer(state);
        
        // First half of full rounds
        uint256 rf_half = RF / 2;
        for (uint256 r = 0; r < rf_half; r++) {
            fullRound(state, r);
        }
        
        // Partial rounds
        for (uint256 r = 0; r < RP; r++) {
            partialRound(state, r + rf_half);
        }
        
        // Second half of full rounds
        for (uint256 r = 0; r < rf_half; r++) {
            fullRound(state, r + rf_half + RP);
        }
    }
    
    /**
     * @notice Full round: applies S-box to all elements
     */
    function fullRound(uint256[] memory state, uint256 round) internal pure {
        // Add round constants
        addRoundConstants(state, round);
        
        // Apply S-box to all elements
        for (uint256 i = 0; i < state.length; i++) {
            state[i] = sbox(state[i]);
        }
        
        // Apply linear layer (MDS matrix multiplication)
        externalLinearLayer(state);
    }
    
    /**
     * @notice Partial round: applies S-box only to first element
     */
    function partialRound(uint256[] memory state, uint256 round) internal pure {
        // Add round constants
        addRoundConstants(state, round);
        
        // Apply S-box only to first element
        state[0] = sbox(state[0]);
        
        // Apply linear layer (different matrix for internal rounds)
        internalLinearLayer(state);
    }
    
    /**
     * @notice S-box function: x^alpha mod p
     */
    function sbox(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        
        // x^5 mod p using modular exponentiation
        return modExp(x, ALPHA);
    }
    
    /**
     * @notice Add round constants to state
     */
    function addRoundConstants(uint256[] memory state, uint256 round) internal pure {
        for (uint256 i = 0; i < state.length; i++) {
            uint256 rc = Poseidon2Constants.getRoundConstant(round, i);
            state[i] = addmod(state[i], rc, P);
        }
    }
    
    /**
     * @notice External linear layer matrix multiplication
     * Optimized for t >= 4 using special matrix structure
     */
    function externalLinearLayer(uint256[] memory state) internal pure {
        uint256 t = state.length;
        
        if (t == 12) {
            // Optimized matrix for t=12 (common case)
            externalMatrixMul12(state);
        } else {
            // Generic implementation for other widths
            genericExternalMatrixMul(state);
        }
    }
    
    /**
     * @notice Internal linear layer matrix multiplication
     * Uses different matrix for internal rounds
     */
    function internalLinearLayer(uint256[] memory state) internal pure {
        uint256 t = state.length;
        
        if (t == 12) {
            // Optimized internal matrix for t=12
            internalMatrixMul12(state);
        } else {
            // Generic implementation
            genericInternalMatrixMul(state);
        }
    }
    
    /**
     * @notice Optimized external matrix multiplication for t=12
     * Uses circulant matrix structure for efficiency
     */
    function externalMatrixMul12(uint256[] memory state) internal pure {
        // Implementation will be optimized with assembly
        // For now, using simplified version
        uint256[12] memory temp;
        
        // Matrix multiplication with optimized structure
        // This will be replaced with efficient assembly implementation
        for (uint256 i = 0; i < 12; i++) {
            temp[i] = 0;
            for (uint256 j = 0; j < 12; j++) {
                // Simplified matrix element - will be precomputed
                uint256 matrixElement = getExternalMatrixElement(i, j);
                temp[i] = addmod(temp[i], mulmod(state[j], matrixElement, P), P);
            }
        }
        
        // Copy back to state
        for (uint256 i = 0; i < 12; i++) {
            state[i] = temp[i];
        }
    }
    
    /**
     * @notice Optimized internal matrix multiplication for t=12
     */
    function internalMatrixMul12(uint256[] memory state) internal pure {
        uint256[12] memory temp;
        
        // Internal matrix has special structure for efficiency
        for (uint256 i = 0; i < 12; i++) {
            temp[i] = 0;
            for (uint256 j = 0; j < 12; j++) {
                uint256 matrixElement = getInternalMatrixElement(i, j);
                temp[i] = addmod(temp[i], mulmod(state[j], matrixElement, P), P);
            }
        }
        
        for (uint256 i = 0; i < 12; i++) {
            state[i] = temp[i];
        }
    }
    
    /**
     * @notice Generic external matrix multiplication
     */
    function genericExternalMatrixMul(uint256[] memory state) internal pure {
        uint256 t = state.length;
        uint256[] memory temp = new uint256[](t);
        
        for (uint256 i = 0; i < t; i++) {
            temp[i] = 0;
            for (uint256 j = 0; j < t; j++) {
                uint256 matrixElement = getExternalMatrixElement(i, j);
                temp[i] = addmod(temp[i], mulmod(state[j], matrixElement, P), P);
            }
        }
        
        for (uint256 i = 0; i < t; i++) {
            state[i] = temp[i];
        }
    }
    
    /**
     * @notice Generic internal matrix multiplication
     */
    function genericInternalMatrixMul(uint256[] memory state) internal pure {
        uint256 t = state.length;
        uint256[] memory temp = new uint256[](t);
        
        for (uint256 i = 0; i < t; i++) {
            temp[i] = 0;
            for (uint256 j = 0; j < t; j++) {
                uint256 matrixElement = getInternalMatrixElement(i, j);
                temp[i] = addmod(temp[i], mulmod(state[j], matrixElement, P), P);
            }
        }
        
        for (uint256 i = 0; i < t; i++) {
            state[i] = temp[i];
        }
    }
    
    /**
     * @notice Get external matrix element (simplified for now)
     */
    function getExternalMatrixElement(uint256 i, uint256 j) internal pure returns (uint256) {
        // This will be replaced with precomputed matrix elements
        // For now, using a simple pattern that ensures invertibility
        if (i == j) return 2;
        if (i == (j + 1) % T) return 1;
        return 0;
    }
    
    /**
     * @notice Get internal matrix element (simplified for now)
     */
    function getInternalMatrixElement(uint256 i, uint256 j) internal pure returns (uint256) {
        // Internal matrix has different structure
        if (i == 0 || j == 0) {
            return 1; // First row/column special
        }
        if (i == j) return 2;
        return 0;
    }
    
    /**
     * @notice Modular exponentiation: base^exp mod p
     */
    function modExp(uint256 base, uint256 exponent) internal pure returns (uint256) {
        // Use assembly for better performance
        assembly {
            let result := 1
            let b := base
            let e := exponent
            let m := P
            
            // Reduce base modulo p
            if gt(b, m) { b := mod(b, m) }
            
            for {} gt(e, 0) {} {
                if and(e, 1) {
                    result := mulmod(result, b, m)
                }
                b := mulmod(b, b, m)
                e := shr(1, e)
            }
            
            // Store result
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }
}