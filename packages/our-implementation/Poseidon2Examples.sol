// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./Poseidon2Main.sol";

/**
 * @title Poseidon2 Usage Examples
 * @notice Demonstrates various use cases for Poseidon2 hash function
 */
contract Poseidon2Examples {
    Poseidon2Main public immutable poseidon;
    
    // Domain separators for different applications
    uint256 constant DOMAIN_TRANSACTION = 1;
    uint256 constant DOMAIN_STATE = 2;
    uint256 constant DOMAIN_EVENT = 3;
    uint256 constant DOMAIN_MERKLE = 4;
    
    // Events for demonstration
    event TransactionHashed(bytes32 indexed txId, uint256 hash);
    event StateUpdated(bytes32 indexed stateId, uint256 hash);
    event MerkleTreeUpdated(uint256 indexed level, uint256 oldRoot, uint256 newRoot);
    
    constructor(address _poseidon) {
        poseidon = Poseidon2Main(_poseidon);
    }
    
    /**
     * @notice Example: Hash a transaction with domain separation
     */
    function hashTransaction(
        address from,
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 timestamp
    ) public returns (uint256) {
        uint256[] memory input = new uint256[](5);
        input[0] = uint256(uint160(from));
        input[1] = uint256(uint160(to));
        input[2] = amount;
        input[3] = nonce;
        input[4] = timestamp;
        
        uint256 hash = poseidon.hashWithDomain(input, DOMAIN_TRANSACTION);
        
        bytes32 txId = keccak256(abi.encodePacked(from, to, amount, nonce, timestamp));
        emit TransactionHashed(txId, hash);
        
        return hash;
    }
    
    /**
     * @notice Example: Hash contract state
     */
    function hashContractState(
        uint256 balance,
        uint256 totalSupply,
        uint256 lastUpdate,
        address owner,
        bytes32 merkleRoot
    ) public returns (uint256) {
        uint256[] memory input = new uint256[](5);
        input[0] = balance;
        input[1] = totalSupply;
        input[2] = lastUpdate;
        input[3] = uint256(uint160(owner));
        input[4] = uint256(merkleRoot);
        
        uint256 hash = poseidon.hashWithDomain(input, DOMAIN_STATE);
        
        bytes32 stateId = keccak256(abi.encodePacked(balance, totalSupply, lastUpdate, owner, merkleRoot));
        emit StateUpdated(stateId, hash);
        
        return hash;
    }
    
    /**
     * @notice Example: Build a Merkle tree
     */
    function buildMerkleTree(uint256[] memory leaves) public returns (uint256) {
        require(leaves.length > 0, "Empty leaves array");
        require(leaves.length <= 2048, "Too many leaves"); // Reasonable limit
        
        // Ensure power of 2 for simplicity (pad with zeros if needed)
        uint256 n = leaves.length;
        uint256 powerOfTwo = 1;
        while (powerOfTwo < n) powerOfTwo <<= 1;
        
        uint256[] memory currentLevel = new uint256[](powerOfTwo);
        
        // Copy leaves and pad with zeros
        for (uint256 i = 0; i < n; i++) {
            currentLevel[i] = leaves[i];
        }
        for (uint256 i = n; i < powerOfTwo; i++) {
            currentLevel[i] = 0;
        }
        
        // Build tree level by level
        while (currentLevel.length > 1) {
            uint256 nextLevelSize = currentLevel.length / 2;
            uint256[] memory nextLevel = new uint256[](nextLevelSize);
            
            for (uint256 i = 0; i < nextLevelSize; i++) {
                uint256 left = currentLevel[i * 2];
                uint256 right = currentLevel[i * 2 + 1];
                nextLevel[i] = poseidon.merkleHash(left, right);
            }
            
            currentLevel = nextLevel;
        }
        
        return currentLevel[0];
    }
    
    /**
     * @notice Example: Verify Merkle proof
     */
    function verifyMerkleProof(
        uint256 leaf,
        uint256 index,
        uint256 root,
        uint256[] memory proof
    ) public view returns (bool) {
        uint256 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            if (index & (1 << i) == 0) {
                // Current element is left sibling
                computedHash = poseidon.merkleHash(computedHash, proof[i]);
            } else {
                // Current element is right sibling
                computedHash = poseidon.merkleHash(proof[i], computedHash);
            }
        }
        
        return computedHash == root;
    }
    
    /**
     * @notice Example: Batch process multiple hashes
     */
    function batchProcessTransactions(
        address[] memory from,
        address[] memory to,
        uint256[] memory amounts,
        uint256[] memory nonces,
        uint256 timestamp
    ) public returns (uint256[] memory) {
        require(
            from.length == to.length && 
            to.length == amounts.length && 
            amounts.length == nonces.length,
            "Array length mismatch"
        );
        
        uint256[][] memory inputs = new uint256[][](from.length);
        
        // Prepare all inputs
        for (uint256 i = 0; i < from.length; i++) {
            inputs[i] = new uint256[](5);
            inputs[i][0] = uint256(uint160(from[i]));
            inputs[i][1] = uint256(uint160(to[i]));
            inputs[i][2] = amounts[i];
            inputs[i][3] = nonces[i];
            inputs[i][4] = timestamp;
        }
        
        // Batch hash for efficiency
        return poseidon.batchHash(inputs);
    }
    
    /**
     * @notice Example: Commit-reveal scheme
     */
    struct Commitment {
        uint256 commitment;
        uint256 timestamp;
        bool revealed;
        uint256 revealedValue;
    }
    
    mapping(address => Commitment) public commitments;
    
    function commit(uint256 secret) public returns (uint256) {
        uint256[] memory input = new uint256[](2);
        input[0] = uint256(uint160(msg.sender));
        input[1] = secret;
        
        uint256 commitment = poseidon.hashWithDomain(input, DOMAIN_EVENT);
        
        commitments[msg.sender] = Commitment({
            commitment: commitment,
            timestamp: block.timestamp,
            revealed: false,
            revealedValue: 0
        });
        
        return commitment;
    }
    
    function reveal(uint256 secret) public {
        Commitment storage userCommitment = commitments[msg.sender];
        require(userCommitment.commitment != 0, "No commitment found");
        require(!userCommitment.revealed, "Already revealed");
        
        uint256[] memory input = new uint256[](2);
        input[0] = uint256(uint160(msg.sender));
        input[1] = secret;
        
        uint256 computedCommitment = poseidon.hashWithDomain(input, DOMAIN_EVENT);
        require(computedCommitment == userCommitment.commitment, "Invalid secret");
        
        userCommitment.revealed = true;
        userCommitment.revealedValue = secret;
    }
    
    /**
     * @notice Example: Zero-knowledge friendly data structure
     */
    struct ZKData {
        uint256 hash;
        uint256 timestamp;
        bytes32 metadata;
    }
    
    mapping(uint256 => ZKData) public zkData;
    
    function storeZKData(
        uint256 id,
        uint256[] memory privateData,
        bytes32 metadata
    ) public returns (uint256) {
        uint256 dataHash = poseidon.hash(privateData);
        
        zkData[id] = ZKData({
            hash: dataHash,
            timestamp: block.timestamp,
            metadata: metadata
        });
        
        return dataHash;
    }
    
    function verifyZKData(
        uint256 id,
        uint256[] memory claimedData
    ) public view returns (bool) {
        ZKData storage data = zkData[id];
        require(data.hash != 0, "Data not found");
        
        uint256 computedHash = poseidon.hash(claimedData);
        return computedHash == data.hash;
    }
    
    /**
     * @notice Example: Efficient signature verification (hash-based)
     */
    function verifySignature(
        address signer,
        bytes32 message,
        uint256 r,
        uint256 s
    ) public pure returns (bool) {
        // This is a simplified example - real implementation would use proper crypto
        uint256[] memory input = new uint256[](4);
        input[0] = uint256(uint160(signer));
        input[1] = uint256(message);
        input[2] = r;
        input[3] = s;
        
        // In a real implementation, this would verify against a stored public key
        // For demo purposes, we just show the hashing pattern
        uint256 signatureHash = uint256(keccak256(abi.encodePacked(input)));
        
        return signatureHash != 0; // Simplified verification
    }
    
    /**
     * @notice Example: Generate deterministic randomness
     */
    function generateRandomness(
        uint256 seed,
        uint256 blockNumber,
        address caller
    ) public view returns (uint256) {
        uint256[] memory input = new uint256[](3);
        input[0] = seed;
        input[1] = blockNumber;
        input[2] = uint256(uint160(caller));
        
        return poseidon.hash(input);
    }
    
    /**
     * @notice Example: Create a simple accumulator
     */
    struct Accumulator {
        uint256 currentValue;
        uint256 count;
        mapping(uint256 => uint256) values;
    }
    
    Accumulator public accumulator;
    
    function addToAccumulator(uint256 value) public {
        uint256[] memory input = new uint256[](2);
        input[0] = accumulator.currentValue;
        input[1] = value;
        
        accumulator.values[accumulator.count] = value;
        accumulator.currentValue = poseidon.hash(input);
        accumulator.count++;
    }
    
    function getAccumulatorHash() public view returns (uint256) {
        return accumulator.currentValue;
    }
    
    /**
     * @notice Example: Time-locked commitment
     */
    struct TimeLock {
        uint256 commitment;
        uint256 unlockTime;
        bool unlocked;
    }
    
    mapping(address => TimeLock) public timeLocks;
    
    function createTimeLock(uint256 secret, uint256 lockDuration) public returns (uint256) {
        uint256[] memory input = new uint256[](2);
        input[0] = uint256(uint160(msg.sender));
        input[1] = secret;
        
        uint256 commitment = poseidon.hashWithDomain(input, DOMAIN_EVENT);
        
        timeLocks[msg.sender] = TimeLock({
            commitment: commitment,
            unlockTime: block.timestamp + lockDuration,
            unlocked: false
        });
        
        return commitment;
    }
    
    function unlockTimeLock(uint256 secret) public {
        TimeLock storage lock = timeLocks[msg.sender];
        require(lock.commitment != 0, "No time lock found");
        require(block.timestamp >= lock.unlockTime, "Too early to unlock");
        require(!lock.unlocked, "Already unlocked");
        
        uint256[] memory input = new uint256[](2);
        input[0] = uint256(uint160(msg.sender));
        input[1] = secret;
        
        uint256 computedCommitment = poseidon.hashWithDomain(input, DOMAIN_EVENT);
        require(computedCommitment == lock.commitment, "Invalid secret");
        
        lock.unlocked = true;
    }
}