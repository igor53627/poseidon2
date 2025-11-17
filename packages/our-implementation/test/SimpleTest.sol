// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../Poseidon2Main.sol";

/**
 * @title Simple Poseidon2 Test
 * @notice Basic functionality test
 */
contract SimpleTest {
    Poseidon2Main public poseidon;
    
    constructor() {
        poseidon = new Poseidon2Main();
    }
    
    function testBasicHash() public returns (bool) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        
        uint256 result1 = poseidon.hash(input);
        uint256 result2 = poseidon.hash(input);
        
        return result1 == result2 && result1 != 0;
    }
    
    function getGasUsed() public returns (uint256) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        
        uint256 gasStart = gasleft();
        poseidon.hash(input);
        return gasStart - gasleft();
    }
}