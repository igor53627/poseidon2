// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./Poseidon2Constants.sol";

/**
 * @title Poseidon2 Main Implementation
 * @notice Complete Poseidon2 hash function implementation with all optimizations
 * @dev Combines constants, optimized operations, and main permutation logic
 */
contract Poseidon2Main {
    using Poseidon2Constants for uint256[];
    
    // Goldilocks field parameters
    uint256 constant P = 0xFFFFFFFF00000001;
    uint256 constant T = 12;
    uint256 constant RF = 8;
    uint256 constant RP = 26;
    uint256 constant RF_HALF = RF / 2;
    uint256 constant TOTAL_ROUNDS = RF + RP;
    
    // Storage for precomputed values
    uint256[T][T] public externalMatrix;
    uint256[T][T] public internalMatrix;
    uint256[TOTAL_ROUNDS][T] public roundConstants;
    
    // Events
    event HashComputed(bytes32 indexed inputHash, uint256 output);
    event PermutationApplied(uint256[T] state);
    
    // Errors
    error InvalidInputLength();
    error InvalidFieldElement();
    error InvalidWidth();
    
    constructor() {
        _initializeMatrices();
        _initializeRoundConstants();
    }
    
    /**
     * @notice Initialize MDS matrices with proper values
     */
    function _initializeMatrices() internal {
        // External matrix (circulant structure for t=12)
        // This should be generated using the proper algorithm from the paper
        uint256[T][T] memory extMatrix = Poseidon2Constants.getExternalMatrix();
        for (uint256 i = 0; i < T; i++) {
            for (uint256 j = 0; j < T; j++) {
                externalMatrix[i][j] = extMatrix[i][j];
            }
        }
        
        // Internal matrix (different structure for internal rounds)
        uint256[T][T] memory intMatrix = Poseidon2Constants.getInternalMatrix();
        for (uint256 i = 0; i < T; i++) {
            for (uint256 j = 0; j < T; j++) {
                internalMatrix[i][j] = intMatrix[i][j];
            }
        }
    }
    
    /**
     * @notice Initialize round constants using Grain LFSR
     */
    function _initializeRoundConstants() internal {
        uint256[TOTAL_ROUNDS][T] memory rc = Poseidon2Constants.getRoundConstants();
        for (uint256 r = 0; r < TOTAL_ROUNDS; r++) {
            for (uint256 i = 0; i < T; i++) {
                roundConstants[r][i] = rc[r][i];
            }
        }
    }
    
    /**
     * @notice Main hash function interface
     * @param input Array of field elements to hash
     * @return Hash output as a field element
     */
    function hash(uint256[] memory input) public returns (uint256) {
        if (input.length == 0 || input.length >= T) {
            revert InvalidInputLength();
        }
        
        // Validate all inputs are valid field elements
        for (uint256 i = 0; i < input.length; i++) {
            if (input[i] >= P) {
                revert InvalidFieldElement();
            }
        }
        
        // Initialize state
        uint256[T] memory state;
        
        // Set input with padding
        state[0] = 0; // Domain separator (can be customized)
        for (uint256 i = 0; i < input.length; i++) {
            state[i + 1] = input[i];
        }
        
        // Add padding delimiter and capacity
        state[input.length + 1] = 1; // Padding delimiter
        // Remaining elements are already 0 (capacity)
        
        // Apply permutation
        permute(state);
        
        // Emit event for tracking
        bytes32 inputHash = keccak256(abi.encodePacked(input));
        emit HashComputed(inputHash, state[0]);
        
        return state[0];
    }
    
    /**
     * @notice Hash with custom domain separator
     */
    function hashWithDomain(uint256[] memory input, uint256 domainSeparator) 
        public 
        returns (uint256) 
    {
        if (input.length == 0 || input.length >= T) {
            revert InvalidInputLength();
        }
        
        uint256[T] memory state;
        state[0] = domainSeparator;
        
        for (uint256 i = 0; i < input.length; i++) {
            if (input[i] >= P) revert InvalidFieldElement();
            state[i + 1] = input[i];
        }
        
        state[input.length + 1] = 1;
        
        permute(state);
        
        bytes32 inputHash = keccak256(abi.encodePacked(input, domainSeparator));
        emit HashComputed(inputHash, state[0]);
        
        return state[0];
    }
    
    /**
     * @notice Main permutation function
     */
    function permute(uint256[T] memory state) public view returns (uint256[T] memory) {
        // Apply initial external linear layer
        state = _externalLinearLayer(state);
        
        // First half of full rounds
        for (uint256 r = 0; r < RF_HALF; r++) {
            state = _fullRound(state, r);
        }
        
        // Partial rounds
        for (uint256 r = 0; r < RP; r++) {
            state = _partialRound(state, r + RF_HALF);
        }
        
        // Second half of full rounds
        for (uint256 r = 0; r < RF_HALF; r++) {
            state = _fullRound(state, r + RF_HALF + RP);
        }
        
        return state;
    }
    
    /**
     * @notice Full round implementation
     */
    function _fullRound(uint256[T] memory state, uint256 round) internal view returns (uint256[T] memory) {
        // Add round constants
        for (uint256 i = 0; i < T; i++) {
            state[i] = addmod(state[i], roundConstants[round][i], P);
        }
        
        // Apply S-box to all elements
        for (uint256 i = 0; i < T; i++) {
            state[i] = _sbox(state[i]);
        }
        
        // Apply external linear layer
        state = _externalLinearLayer(state);
        
        return state;
    }
    
    /**
     * @notice Partial round implementation
     */
    function _partialRound(uint256[T] memory state, uint256 round) internal view returns (uint256[T] memory) {
        // Add round constants
        for (uint256 i = 0; i < T; i++) {
            state[i] = addmod(state[i], roundConstants[round][i], P);
        }
        
        // Apply S-box only to first element
        state[0] = _sbox(state[0]);
        
        // Apply internal linear layer
        state = _internalLinearLayer(state);
        
        return state;
    }
    
    /**
     * @notice S-box function: x^5 mod p
     */
    function _sbox(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        
        // x^5 mod p
        uint256 x2 = mulmod(x, x, P);
        uint256 x4 = mulmod(x2, x2, P);
        return mulmod(x4, x, P);
    }
    
    /**
     * @notice External linear layer using precomputed matrix
     */
    function _externalLinearLayer(uint256[T] memory state) internal view returns (uint256[T] memory) {
        uint256[T] memory result;
        
        // Matrix-vector multiplication with external matrix
        for (uint256 i = 0; i < T; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < T; j++) {
                sum = addmod(sum, mulmod(state[j], externalMatrix[i][j], P), P);
            }
            result[i] = sum;
        }
        
        return result;
    }
    
    /**
     * @notice Internal linear layer using precomputed matrix
     */
    function _internalLinearLayer(uint256[T] memory state) internal view returns (uint256[T] memory) {
        uint256[T] memory result;
        
        // Matrix-vector multiplication with internal matrix
        for (uint256 i = 0; i < T; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < T; j++) {
                sum = addmod(sum, mulmod(state[j], internalMatrix[i][j], P), P);
            }
            result[i] = sum;
        }
        
        return result;
    }
    
    /**
     * @notice Get matrix element (for testing/debugging)
     */
    function getMatrixElement(bool isExternal, uint256 i, uint256 j) 
        public 
        view 
        returns (uint256) 
    {
        return isExternal ? externalMatrix[i][j] : internalMatrix[i][j];
    }
    
    /**
     * @notice Get round constant (for testing/debugging)
     */
    function getRoundConstant(uint256 round, uint256 index) 
        public 
        view 
        returns (uint256) 
    {
        return roundConstants[round][index];
    }
    
    /**
     * @notice Batch hash multiple inputs (gas efficient for Merkle trees)
     */
    function batchHash(uint256[][] memory inputs) 
        public 
        returns (uint256[] memory outputs) 
    {
        outputs = new uint256[](inputs.length);
        
        for (uint256 i = 0; i < inputs.length; i++) {
            outputs[i] = hash(inputs[i]);
        }
        
        return outputs;
    }
    
    /**
     * @notice Compute Merkle tree using Poseidon2
     */
    function merkleHash(uint256 left, uint256 right) public returns (uint256) {
        uint256[] memory input = new uint256[](2);
        input[0] = left;
        input[1] = right;
        return hash(input);
    }
}