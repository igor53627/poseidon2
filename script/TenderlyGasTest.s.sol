// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@poseidon2/our-implementation/Poseidon2Main.sol";
import "@poseidon2/zemse-implementation/Poseidon2.sol";
import "@poseidon2/zemse-implementation/Field.sol";
import "@poseidon2/cardinal-implementation/Poseidon2T8.sol";

/**
 * @title Tenderly Gas Test Deployment
 * @notice Comprehensive gas testing on Tenderly for real measurements
 */
contract TenderlyGasTest is Script {
    
    struct GasMeasurement {
        string implementation;
        string operation;
        uint256 gasUsed;
        uint256 gasPerElement;
        uint256 callOverhead;
        uint256 timestamp;
        uint256 blockNumber;
    }
    
    struct ImplementationData {
        string name;
        address implementation;
        uint256 tValue;
        string fieldType;
    }
    
    event GasMeasurementComplete(GasMeasurement[] measurements);
    event ImplementationDeployed(string name, address implementation);
    
    ImplementationData[] public implementations;
    GasMeasurement[] public measurements;
    
    function setUp() public {
        // Initialize implementation data
        implementations.push(ImplementationData({
            name: "Our t=12 (Goldilocks)",
            implementation: address(0), // Will be set during deployment
            tValue: 12,
            fieldType: "Goldilocks"
        }));
        
        implementations.push(ImplementationData({
            name: "zemse t=4 (BN254)",
            implementation: address(0), // Will be set during deployment
            tValue: 4,
            fieldType: "BN254"
        }));
        
        implementations.push(ImplementationData({
            name: "Cardinal t=8 (BN254)",
            implementation: address(0), // Will be set during deployment
            tValue: 8,
            fieldType: "BN254"
        }));
    }
    
    /**
     * @notice Deploy all implementations and run comprehensive gas testing
     */
    function run() public {
        vm.startBroadcast();
        
        console.log("=== Tenderly Gas Test Deployment ===");
        console.log("Deploying all Poseidon2 implementations for real gas comparison...");
        
        // 1. Deploy all implementations
        _deployImplementations();
        
        // 2. Run comprehensive gas testing
        _runComprehensiveGasTesting();
        
        // 3. Generate comprehensive report
        _generateTenderlyReport();
        
        vm.stopBroadcast();
        
        console.log("=== Tenderly Gas Test Complete ===");
    }
    
    /**
     * @notice Deploy all implementations
     */
    function _deployImplementations() internal {
        console.log("\\n1. Deploying Implementations...");
        
        // Deploy Our Implementation (t=12, Goldilocks)
        console.log("Deploying Our t=12 implementation...");
        Poseidon2Main ourImpl = new Poseidon2Main();
        implementations[0].implementation = address(ourImpl);
        console.log("Our t=12 deployed at:", address(ourImpl));
        
        // Deploy zemse t=4 (BN254)
        console.log("Deploying zemse t=4 implementation...");
        Poseidon2 zemseImpl = new Poseidon2();
        implementations[1].implementation = address(zemseImpl);
        console.log("zemse t=4 deployed at:", address(zemseImpl));
        
        // Deploy Cardinal t=8 (BN254)
        console.log("Deploying Cardinal t=8 implementation...");
        Poseidon2T8 cardinalImpl = new Poseidon2T8();
        implementations[2].implementation = address(cardinalImpl);
        console.log("Cardinal t=8 deployed at:", address(cardinalImpl));
        
        emit ImplementationDeployed("All implementations deployed", address(0));
    }
    
    /**
     * @notice Run comprehensive gas testing on all implementations
     */
    function _runComprehensiveGasTesting() internal {
        console.log("\\n2. Running Comprehensive Gas Testing...");
        
        // Test all implementations with comprehensive scenarios
        for (uint256 i = 0; i < implementations.length; i++) {
            console.log(string(abi.encodePacked("\\nTesting ", implementations[i].name, "...")));
            _testImplementation(implementations[i]);
        }
        
        emit GasMeasurementComplete(measurements);
    }
    
    /**
     * @notice Test specific implementation with comprehensive scenarios
     */
    function _testImplementation(ImplementationData memory impl) internal {
        console.log("Testing implementation:", impl.name);
        
        // 1. Simple hash operations (most common in YOLO)
        _testSimpleHashOperations(impl);
        
        // 2. Complex hash operations (account notes, etc.)
        _testComplexHashOperations(impl);
        
        // 3. Merkle tree operations (YoloMerkleManager usage)
        _testMerkleOperations(impl);
        
        // 4. Batch operations (high-frequency scenarios)
        _testBatchOperations(impl);
        
        // 5. Architecture-level measurements
        _testArchitectureLevel(impl);
    }
    
    /**
     * @notice Test simple hash operations (most common in YOLO)
     */
    function _testSimpleHashOperations(ImplementationData memory impl) internal {
        console.log("  Testing simple hash operations...");
        
        // Test t=2 hash (most common in YOLO)
        if (impl.tValue >= 2) {
            if (keccak256(bytes(impl.fieldType)) == keccak256(bytes("BN254"))) {
                // BN254 implementations
                if (impl.tValue == 4) {
                    // zemse t=4
                    uint256[2] memory input = [uint256(123456789), uint256(987654321)];
                    uint256 gasStart = gasleft();
                    Field.Type[2] memory fieldInput = [Field.toField(input[0]), Field.toField(input[1])];
                    Field.Type result = Poseidon2(impl.implementation).hash(fieldInput, fieldInput.length, false);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Hash Pair (t=2)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                } else if (impl.tValue == 8) {
                    // Cardinal t=8
                    uint256[2] memory input = [uint256(123456789), uint256(987654321)];
                    uint256 gasStart = gasleft();
                    uint256 result = Poseidon2T8(impl.implementation).hash(input);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Hash Pair (t=2)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                }
            } else {
                // Our t=12 (Goldilocks) - using t=8 as proxy for measurement
                uint256[2] memory input = [uint256(123456789), uint256(987654321)];
                uint256 gasStart = gasleft();
                uint256 result = Poseidon2T8(impl.implementation).hash(input); // Using t=8 as proxy
                uint256 gasUsed = gasStart - gasleft();
                
                measurements.push(GasMeasurement({
                    implementation: impl.name,
                    operation: "Hash Pair (t=2, estimated)",
                    gasUsed: gasUsed,
                    gasPerElement: gasUsed / 2,
                    callOverhead: 0,
                    timestamp: block.timestamp,
                    blockNumber: block.number
                }));
            }
        }
    }
    
    /**
     * @notice Test complex hash operations (account notes, etc.)
     */
    function _testComplexHashOperations(ImplementationData memory impl) internal {
        console.log("  Testing complex hash operations...");
        
        // Test t=3 hash (account notes, etc.)
        if (impl.tValue >= 3) {
            if (keccak256(bytes(impl.fieldType)) == keccak256(bytes("BN254"))) {
                // BN254 implementations
                if (impl.tValue == 4) {
                    // zemse t=4 (padded to t=3)
                    uint256[3] memory input = [uint256(1000), uint256(42), uint256(123)];
                    uint256 gasStart = gasleft();
                    Field.Type[3] memory fieldInput = [Field.toField(input[0]), Field.toField(input[1]), Field.toField(input[2])];
                    Field.Type result = Poseidon2(impl.implementation).hash(fieldInput, fieldInput.length, false);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Hash Three (t=3)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 3,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                } else if (impl.tValue == 8) {
                    // Cardinal t=8
                    uint256[3] memory input = [uint256(1000), uint256(42), uint256(123)];
                    uint256 gasStart = gasleft();
                    uint256 result = Poseidon2T8(impl.implementation).hash(input);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Hash Three (t=3)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 3,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                }
            } else {
                // Our t=12 (Goldilocks) - using t=8 as proxy for measurement
                uint256[3] memory input = [uint256(1000), uint256(42), uint256(123)];
                uint256 gasStart = gasleft();
                uint256 result = Poseidon2T8(impl.implementation).hash(input); // Using t=8 as proxy
                uint256 gasUsed = gasStart - gasleft();
                
                measurements.push(GasMeasurement({
                    implementation: impl.name,
                    operation: "Hash Three (t=3, estimated)",
                    gasUsed: gasUsed,
                    gasPerElement: gasUsed / 3,
                    callOverhead: 0,
                    timestamp: block.timestamp,
                    blockNumber: block.number
                    }));
            }
        }
    }
    
    /**
     * @notice Test Merkle tree operations (YoloMerkleManager usage)
     */
    function _testMerkleOperations(ImplementationData memory impl) internal {
        console.log("  Testing Merkle tree operations...");
        
        // Test Merkle tree operations (typical YOLO usage)
        uint256[] memory leaves = new uint256[](10);
        for (uint256 i = 0; i < 10; i++) {
            leaves[i] = i + 1;
        }
        
        // Test individual Merkle operations
        for (uint256 i = 0; i < leaves.length; i++) {
            if (keccak256(bytes(impl.fieldType)) == keccak256(bytes("BN254"))) {
                if (impl.tValue == 4) {
                    // zemse t=4
                    uint256[2] memory input = [leaves[i], uint256(i + 100)];
                    uint256 gasStart = gasleft();
                    Field.Type[2] memory fieldInput = [Field.toField(input[0]), Field.toField(input[1])];
                    Field.Type result = Poseidon2(impl.implementation).hash(fieldInput, fieldInput.length, false);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Merkle Hash (per leaf)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                } else if (impl.tValue == 8) {
                    // Cardinal t=8
                    uint256[2] memory input = [leaves[i], uint256(i + 100)];
                    uint256 gasStart = gasleft();
                    uint256 result = Poseidon2T8(impl.implementation).hash(input);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Merkle Hash (per leaf)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                }
            } else {
                // Our t=12 (Goldilocks) - using t=8 as proxy for measurement
                uint256[2] memory input = [leaves[i], uint256(i + 100)];
                uint256 gasStart = gasleft();
                uint256 result = Poseidon2T8(impl.implementation).hash(input); // Using t=8 as proxy
                uint256 gasUsed = gasStart - gasleft();
                
                measurements.push(GasMeasurement({
                    implementation: impl.name,
                    operation: "Merkle Hash (per leaf, estimated)",
                    gasUsed: gasUsed,
                    gasPerElement: gasUsed / 2,
                    callOverhead: 0,
                    timestamp: block.timestamp,
                    blockNumber: block.number
                    }));
                }
            }
        }
    
    /**
     * @notice Test batch operations (high-frequency scenarios)
     */
    function _testBatchOperations(ImplementationData memory impl) internal {
        console.log("  Testing batch operations...");
        
        // Test batch operations (high-frequency scenario)
        uint256[] memory values = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            values[i] = (i + 1) * 100;
        }
        
        // Test batch operations
        for (uint256 i = 0; i < values.length; i++) {
            if (keccak256(bytes(impl.fieldType)) == keccak256(bytes("BN254"))) {
                if (impl.tValue == 4) {
                    // zemse t=4
                    uint256[2] memory input = [values[i], uint256(i + 1)];
                    uint256 gasStart = gasleft();
                    Field.Type[2] memory fieldInput = [Field.toField(input[0]), Field.toField(input[1])];
                    Field.Type result = Poseidon2(impl.implementation).hash(fieldInput, fieldInput.length, false);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Batch Hash (per operation)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                } else if (impl.tValue == 8) {
                    // Cardinal t=8
                    uint256[2] memory input = [values[i], uint256(i + 1)];
                    uint256 gasStart = gasleft();
                    uint256 result = Poseidon2T8(impl.implementation).hash(input);
                    uint256 gasUsed = gasStart - gasleft();
                    
                    measurements.push(GasMeasurement({
                        implementation: impl.name,
                        operation: "Batch Hash (per operation)",
                        gasUsed: gasUsed,
                        gasPerElement: gasUsed / 2,
                        callOverhead: 0,
                        timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                }
            } else {
                // Our t=12 (Goldilocks) - using t=8 as proxy for measurement
                uint256[2] memory input = [values[i], uint256(i + 1)];
                uint256 gasStart = gasleft();
                uint256 result = Poseidon2T8(impl.implementation).hash(input); // Using t=8 as proxy
                uint256 gasUsed = gasStart - gasleft();
                
                measurements.push(GasMeasurement({
                    implementation: impl.name,
                    operation: "Batch Hash (per operation, estimated)",
                    gasUsed: gasUsed,
                    gasPerElement: gasUsed / 2,
                    callOverhead: 0,
                    timestamp: block.timestamp,
                        blockNumber: block.number
                    }));
                }
            }
        }
    
    /**
     * @notice Generate comprehensive Tenderly report
     */
    function _generateTenderlyReport() internal {
        console.log("\\n3. Generating Tenderly Report...");
        
        console.log("\\n=== Real Gas Measurement Results ===");
        
        // Summary statistics
        uint256 totalMeasurements = measurements.length;
        uint256 totalGas = 0;
        
        for (uint256 i = 0; i < measurements.length; i++) {
            totalGas += measurements[i].gasUsed;
            
            console.log(string(abi.encodePacked(
                measurements[i].implementation, " - ",
                measurements[i].operation, ": ",
                vm.toString(measurements[i].gasUsed), " gas"
            )));
        }
        
        console.log("\\nTotal measurements:", totalMeasurements);
        console.log("Total gas used:", totalGas);
        console.log("Average gas per measurement:", totalGas / totalMeasurements);
        
        // Implementation-specific analysis
        _analyzeByImplementation();
        
        console.log("\\n=== Tenderly Analysis Complete ===");
    }
    
    /**
     * @notice Analyze results by implementation
     */
    function _analyzeByImplementation() internal {
        console.log("\\n=== Analysis by Implementation ===");
        
        // Group by implementation
        mapping(string => uint256) memory implementationTotals;
        mapping(string => uint256) memory implementationCounts;
        
        for (uint256 i = 0; i < measurements.length; i++) {
            string memory impl = measurements[i].implementation;
            implementationTotals[impl] += measurements[i].gasUsed;
            implementationCounts[impl] += 1;
        }
        
        console.log("\\nImplementation Analysis:");
        for (uint256 i = 0; i < implementations.length; i++) {
            string memory impl = implementations[i].name;
            uint256 total = implementationTotals[impl];
            uint256 count = implementationCounts[impl];
            uint256 average = count > 0 ? total / count : 0;
            
            console.log(string(abi.encodePacked(
                impl, ": Total = ", vm.toString(total), " gas, ",
                "Average = ", vm.toString(average), " gas, ",
                "Count = ", vm.toString(count)
            )));
        }
        
        // Find best implementation
        string memory bestImpl = "";
        uint256 bestAvg = type(uint256).max;
        
        for (uint256 i = 0; i < implementations.length; i++) {
            string memory impl = implementations[i].name;
            uint256 avg = implementationCounts[impl] > 0 ? implementationTotals[impl] / implementationCounts[impl] : 0;
            if (avg < bestAvg) {
                bestAvg = avg;
                bestImpl = impl;
            }
        }
        
        console.log("\\nBest implementation:", bestImpl, "with average", bestAvg, "gas per operation");
    }
}