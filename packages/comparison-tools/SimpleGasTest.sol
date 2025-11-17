// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@poseidon2/zemse-implementation/Poseidon2.sol";
import "@poseidon2/zemse-implementation/Field.sol";
import "@poseidon2/cardinal-implementation/Poseidon2T8.sol";

/**
 * @title Simple Gas Test
 * @notice Basic gas testing without console dependencies
 */
contract SimpleGasTest {
    
    struct GasResult {
        string implementation;
        uint256 inputSize;
        uint256 gasUsed;
        uint256 result;
    }
    
    GasResult[] public results;
    
    function testZemseGas() public returns (uint256 gasUsed, uint256 result) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        
        // Convert to Field.Type
        Field.Type[] memory zemseInput = new Field.Type[](3);
        zemseInput[0] = Field.toField(input[0]);
        zemseInput[1] = Field.toField(input[1]);
        zemseInput[2] = Field.toField(input[2]);
        
        uint256 gasStart = gasleft();
        Field.Type output = Poseidon2.hash(zemseInput, zemseInput.length, false);
        gasUsed = gasStart - gasleft();
        result = Field.toUint256(output);
        
        results.push(GasResult("zemse", 3, gasUsed, result));
        return (gasUsed, result);
    }
    
    function testCardinalGas() public returns (uint256 gasUsed, uint256 result) {
        uint256[] memory input = new uint256[](3);
        input[0] = 1;
        input[1] = 2;
        input[2] = 3;
        
        uint256 gasStart = gasleft();
        uint256 output = Poseidon2T8.hash(input);
        gasUsed = gasStart - gasleft();
        result = output;
        
        results.push(GasResult("cardinal", 3, gasUsed, result));
        return (gasUsed, result);
    }
    
    function benchmarkAllSizes() public returns (GasResult[] memory) {
        // Clear previous results
        delete results;
        
        // Test different input sizes
        for (uint256 size = 1; size <= 7; size++) {
            _benchmarkSize(size);
        }
        
        return results;
    }
    
    function _benchmarkSize(uint256 size) internal {
        uint256[] memory input = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            input[i] = i + 1;
        }
        
        // Test zemse
        Field.Type[] memory zemseInput = new Field.Type[](size);
        for (uint256 i = 0; i < size; i++) {
            zemseInput[i] = Field.toField(input[i]);
        }
        
        uint256 gasStart = gasleft();
        Field.Type zemseResult = Poseidon2.hash(zemseInput, zemseInput.length, false);
        uint256 zemseGas = gasStart - gasleft();
        
        results.push(GasResult("zemse", size, zemseGas, Field.toUint256(zemseResult)));
        
        // Test Cardinal
        gasStart = gasleft();
        uint256 cardinalResult = Poseidon2T8.hash(input);
        uint256 cardinalGas = gasStart - gasleft();
        
        results.push(GasResult("cardinal", size, cardinalGas, cardinalResult));
    }
    
    function benchmarkMerkle() public returns (GasResult[] memory) {
        // Clear previous results
        delete results;
        
        for (uint256 i = 0; i < 10; i++) {
            uint256 left = uint256(keccak256(abi.encodePacked("left", i)));
            uint256 right = uint256(keccak256(abi.encodePacked("right", i)));
            
            uint256[] memory input = new uint256[](2);
            input[0] = left;
            input[1] = right;
            
            Field.Type[] memory zemseInput = new Field.Type[](2);
            zemseInput[0] = Field.toField(left);
            zemseInput[1] = Field.toField(right);
            
            uint256 gasStart = gasleft();
            Field.Type result = Poseidon2.hash(zemseInput, zemseInput.length, false);
            uint256 gasUsed = gasStart - gasleft();
            
            results.push(GasResult("merkle", 2, gasUsed, Field.toUint256(result)));
        }
        
        return results;
    }
    
    function getResults() public view returns (GasResult[] memory) {
        return results;
    }
    
    function getAverageGas(string memory implementation) public view returns (uint256) {
        uint256 totalGas = 0;
        uint256 count = 0;
        
        for (uint256 i = 0; i < results.length; i++) {
            if (keccak256(bytes(results[i].implementation)) == keccak256(bytes(implementation))) {
                totalGas += results[i].gasUsed;
                count++;
            }
        }
        
        return count > 0 ? totalGas / count : 0;
    }
    
    function getBestImplementation(uint256 inputSize) public view returns (string memory, uint256) {
        uint256 bestGas = type(uint256).max;
        string memory bestImpl = "";
        
        for (uint256 i = 0; i < results.length; i++) {
            if (results[i].inputSize == inputSize && results[i].gasUsed < bestGas) {
                bestGas = results[i].gasUsed;
                bestImpl = results[i].implementation;
            }
        }
        
        return (bestImpl, bestGas);
    }
}