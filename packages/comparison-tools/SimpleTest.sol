// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Import main implementations
import "@poseidon2/our-implementation/Poseidon2Main.sol";
import "@poseidon2/zemse-implementation/Poseidon2.sol";
import "@poseidon2/zemse-implementation/Field.sol";
import "@poseidon2/cardinal-implementation/Poseidon2T8.sol";

/**
 * @title Simple Test for Poseidon2 Implementations
 * @notice Basic functionality test
 */
contract SimpleTest {
    function testOurImplementation() public pure returns (uint256) {
        Poseidon2Main impl = new Poseidon2Main();
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        return impl.hash(input);
    }
    
    function testCardinalImplementation() public pure returns (uint256) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        return Poseidon2T8.hash(input);
    }
    
    function compareSimple() public pure returns (uint256 ourResult, uint256 cardinalResult) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        
        ourResult = testOurImplementation();
        cardinalResult = testCardinalImplementation();
        
        return (ourResult, cardinalResult);
    }
}