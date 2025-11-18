// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title Poseidon2 Constants and Precomputed Values
 * @notice Precomputed round constants and MDS matrices for Poseidon2
 * @dev Based on Goldilocks field (p = 2^64 - 2^32 + 1)
 */
library Poseidon2Constants {
    // Goldilocks field prime
    uint256 constant P = 0xFFFFFFFF00000001;

    // Default parameters for t=12
    uint256 constant T = 12;
    uint256 constant RF = 8;  // Full rounds
    uint256 constant RP = 26; // Partial rounds
    uint256 constant TOTAL_ROUNDS = RF + RP;

    error RoundConstantOutOfBounds();

    uint64[TOTAL_ROUNDS][T] internal constant ROUND_CONSTANTS_T12 = [
        [0xdf1a9d6908a569a1, 0xd60336620e6733d4, 0xd3ad8f882f5bd967, 0xb845423d1ea61a3d, 0x96f1182ac87910b5, 0x3c422183fcfa352e,
 0x426526d37d541d01, 0x3257e7511594fca3, 0x04352662e2727e37, 0xe9aa9822d44bcd3f, 0x9feab5087b13a565, 0xb98bec3dfbf7ff30],
        [0xd1b7b97fb33ca5b3, 0xa352ffc4d53a2e59, 0x504792c523f0f355, 0x6246e667dc993e56, 0x54e17d0354826249, 0x9153fed3ed581612,
 0x5ec036fdaec96c1d, 0x5e8b572c7b9b8a2a, 0xb2a6f0ac494eb8cf, 0x0a58b9da148a831e, 0x0f0f79a872ddba1f, 0xbff9d679449531f1],
        [0x1bedb195f1c31073, 0x6d35bc3bed78ccdf, 0x6852f54f3d5f85e2, 0xb0f28ee0c0bcaf3a, 0xf1fac6f03d3f6be7, 0x7486116942922294,
 0xa575b906b7e4bacc, 0x779c837bc59dc59d, 0xbaed4ab9fa8dfc89, 0x68f583ebfe2e7564, 0x3dd9e2a0da05387d, 0xc1766075ec1d149d],
        [0x5865470fa37c3aef, 0x424cd1da63990ff9, 0x9405e1233e21b5a5, 0xac4ff2511cff6a36, 0xe9a71c9caccff984, 0xcf74f00dca56de16,
 0x07ff6d099f8d34fb, 0xbef321993d202c10, 0xdf1779883c90c6b2, 0x4be0926e4ca139b3, 0x81ea6e57adacaee5, 0xe7f2bbe94b45da2a],
        [0x49b4b757f0353309, 0x79f339c1edd53234, 0x55154be6da3f7900, 0x0ec7d421988bcefd, 0xd38231f3223cb6f5, 0x1c35f190a76c9e23,
 0x3364adf19eb2b132, 0x37c165d4a9f93f42, 0x90f9c47bfad9af4e, 0x3d35e503da9cfdd4, 0xd599d647077be3c9, 0xf7fe42b2315e42e2],
        [0x2323c312bcc2957b, 0x474a2a0e2e0881d0, 0x45a206f0dacaf64b, 0x793eb57680052d4b, 0x4a565cea3e690c19, 0xca2ee132cd2f2286,
 0x8bedaaa9b2779a4d, 0x59a261e4b89c3a17, 0x39015b9fb67a8b14, 0x3c8263456395b7a9, 0x3066cdebe8f334a6, 0xe7f081f9b9cf51c4],
        [0x4c42c2ae3f69dee6, 0x66b8b80dbf138e71, 0x245030c4ed2e345d, 0x4f86489823f47ba5, 0xf8ded39fd9bd14b5, 0xbed654a06a3fecd4,
 0x64e5672abfed7edc, 0x76c7f8d8440a1685, 0xcc0f62301258b228, 0x4169bd97c956dd2b, 0x6d61e47f853d90be, 0x9e4b784d9f1740f3],
        [0xe68abe2cf637bb0a, 0x0467bcd0a06978ea, 0x0f78b9e9829632d0, 0x657bdac182c4a508, 0xee635da8e2eddcaa, 0x10cbd2a4e8c82d38,
 0x05b5842e4c3d662a, 0x7c8d6430ca010839, 0xcb9107a852d72a0e, 0x3a56c624347dccf3, 0x8193e3dc9dbfb6b8, 0xf14cd33c2e5ebe13],
        [0x76b6e615a5a05bf2, 0x36f533e48f443a49, 0x28f6a04498f6473a, 0xe218b1ca06902eb8, 0x51aec308a3841d42, 0x9c2e26ba2f4443fd,
 0x3b7d80557919c8cb, 0x0b124a099c80ffd8, 0xf00bda21fbcf4955, 0xf31eb367b6dc6004, 0xfe2d4ee188b8ee44, 0x6c447a38ece15d5a],
        [0xa66cd07a018bf188, 0xd72b1b7895101bf4, 0x4058542b3590eb8b, 0xcde432288a7ce86f, 0x4d5b08b13adcef89, 0x759b3a9699b748b0,
 0xaf747373668cee05, 0xf180ddeadd8e6604, 0xafd3c3f64f517c1b, 0x81fbc6e71a6f3b06, 0x1fa8f0e7a841f0ba, 0xb38f84383d925ae4],
        [0x5051c8a38edbd461, 0x49198d77cb5f0d4f, 0x8097df233da88edb, 0x4674565254f3160b, 0x9b0ee06bc8a838e5, 0x52bcdc1e49e05f6c,
 0x6a326ea31ea07ee8, 0xfc792bdf42ab2d54, 0xfe115bb9d5eccb0c, 0x958e61ba1a3cee36, 0x825359a327164669, 0xdd696deb8abc0c9f],
        [0x2949feb47fc4a39c, 0xe21c58c0e1a394af, 0x68ec80b0751e6030, 0x595ae29cc59c3fb5, 0x9089747125b3cac5, 0x3091191fa5aa0343,
 0x2c465568bd5bc463, 0x8c704972935d9266, 0x6846c0715769464f, 0xab54aeb252039707, 0xfa95a1047b479498, 0x805bbcd2aa93bb07],
        [0xc7bacd4a73cb7d6a, 0x21af533fa87d5a76, 0xa9f640e302ce7455, 0xe5a577a560b8dbaf, 0xcb483dbf5a16f903, 0xb37f726b2fb95725,
 0xb31a0ac45e66e72a, 0x3ef7d8645646fc9a, 0xca6e60ee088cd313, 0x8072866a1d5f1dff, 0xa458759f49f6afdf, 0x9bd1e4c7d7d05ca2],
        [0x9733f039bf2761d6, 0xd97b6521cfdcd367, 0x10436b38fdf24454, 0xabcb5d98e4daeb28, 0x8d613539f128392c, 0x34481777561dadf0,
 0x75b369d346ca16ae, 0x9ac4e1bcd4516fff, 0xcdd0e7710472eb9f, 0xded33ff3a3aa9b87, 0x64653c11288ad0ec, 0x22c33aa227b1991c],
        [0x5f171b650f04498a, 0x6c624b1519937ef4, 0x48c23e965a9df05c, 0x775b34f0f2a77553, 0xcd149f9f6b559792, 0x7efe4ef611d4ca20,
 0xcc22703849284393, 0x8b6652622c9d162f, 0xd006376164ff869a, 0x4a27706577991946, 0xb997ad1972e8c929, 0x36c21b54e5cc8bcf],
        [0x011179855a6a63a7, 0x0864f5e10875d089, 0xb74f8a4b9e88fd08, 0xe6f8eb4b65986a3f, 0xe6f4a7d23d2cee46, 0x07ebadf916270d36,
 0xe7b942d892e8e28b, 0x574798571306b356, 0x63428def4d00a88a, 0xeba55f015cc9d54f, 0xebb1121843a0e2fc, 0x919771222989596c],
        [0x8ecfa6378aa942bd, 0x871946da40c64bbe, 0x5b1611c60d3cecdb, 0x9209d115561b1d66, 0x12677f21c893ae32, 0x8402090693df498a,
 0x9d8b5f94ba88d56f, 0x1a6ad89ba4287c0e, 0x63a701bad47f541c, 0x3e417684c1f18dd2, 0x3b6190364c4ffc66, 0xa91c9e456da619ae],
        [0xf446f008b72ddc25, 0x77646fbbd26e0a66, 0x9aa41fb5df9b2521, 0xa2d709ff7ba8bd85, 0xa2c7d9edb4d1fa69, 0x273685eef271dee5,
 0x6f6a709e59524e87, 0xf4f44204e0c0eb1d, 0x35f86065451a1535, 0xd206cb093e4196b4, 0x08702360f6360940, 0x26f144832a45a268],
        [0x13e3bcdd1d1cfdcc, 0x901eba1f56242547, 0x4fe49266f3ed6db7, 0x14d11eb248c42d87, 0x95c06da17cac21da, 0x632b5da255b883ec,
 0xbd6f26c7a0ec9da4, 0xed425c9ba3e0ed80, 0x1ae9036ac014de99, 0x10a009af965a0718, 0xad50448743e85cfd, 0x550178ba6fa51892],
        [0xf67e6f595460c654, 0x8138e17923894022, 0x92bc8171784b5111, 0xd2abdb0507667513, 0xcc5a8825f485a741, 0xe70acff3abea97d6,
 0x65de59fdaf4344f8, 0xd7a048a6654301de, 0x1474a7ba9ad4be41, 0x1d4758411f9c8be8, 0xd7f5c649327e3510, 0x147f90485d9f8722],
        [0x66baedc0020f7f04, 0x4a56a33cc0406625, 0x9401a3886315b22f, 0xafbd8d1409feab11, 0x74d7e5232e7437a1, 0xd8c1193e48de247c,
 0x68bc420a49b06dc8, 0x1f3c5b365a44791d, 0x8cc88d9693cf0257, 0x49ff22aa22eb26b8, 0x8a7b8a87f9017745, 0xacbb20139170b37b],
        [0x436ab7945dfdc70f, 0xa074dbb4cf45fba6, 0xd9cc198f88d2df2e, 0xa8f6f54aa4c13df1, 0x07e9732004d61d7c, 0x9241cd9192b4d6a4,
 0x34fd041dd33e4666, 0x179dbe05062a391b, 0x7ae48a1b44bc0ac5, 0x895d1fa60a58587b, 0x22678e293a0ba634, 0xb97eb6f6a5b02409],
        [0xdf33eca54722bd1f, 0x81de5d5330f5f66f, 0x1f6347ef6d0d7020, 0x5b0390cf03c8401e, 0x44af3c0e0c81baf5, 0x6482c529ef7ef716,
 0x2542cc561254fc53, 0x09c4987587a3a007, 0x61ef9f1e543da8af, 0x11cac1a9709f21b2, 0xb3af1771eeb2af76, 0x8817597b32f294a5],
        [0xfdfed54253fde066, 0x5791ccd5fb2012f6, 0x496cc0b1420feb29, 0x02afefe828f30884, 0x384f58fb7cf887fc, 0x818bb3530ac54a48,
 0x37da44986c445b3f, 0x0b0f4072777e25e1, 0xa3705d4c3daa340b, 0x31fcdfaf7c5f8149, 0x06b550f971e42a15, 0x8ecde76b237d7e15],
        [0x4c4af3a1ffe181e3, 0xcf3fd085eed379af, 0xd9dbfef3b7c5d7b9, 0xf8a6c1aed82f0cea, 0x7a58f9d82288f353, 0x74560cb38926784d,
 0xfeb367c2d6dd2b75, 0x3b6c25d7d1316bd3, 0xcbc18dca74ede61f, 0x356be628b6bc7401, 0xd9f378b37cd8ea97, 0x79618d835a00521e],
        [0x6d0b0e6cb85bb94f, 0xa3cd09d9cc791c94, 0xf5adc083f3b2e0cb, 0x851b965bad8243f4, 0x50164d3d279f7417, 0xe3b84f9efd2d7b0e,
 0x71cd934d10151ec2, 0xb48c5889fb236082, 0x2cfd277847fb6cda, 0xabaed00dce100339, 0xb59ba7dfa54c53be, 0x56620528a7c426d5],
        [0xdfa597b3c61971cf, 0x096e57164f8d02a5, 0xbfebacaac24bd248, 0x798bfbb980e1aaca, 0xe5421282c335dfda, 0xb72ba6aa6680b8c8,
 0xad3f5ffa05d6a66b, 0x4196e82c4195acc3, 0x98ff4dee4330b963, 0x7493484bfd84eef1, 0xd951eb1b99fbbad9, 0x4ee57fb417a40555],
        [0x45df36e749d34a4a, 0xcc3a1c473aad8eff, 0x339739aadc9bad32, 0x0b686e56caacbb19, 0xb0cd2ce3f7e92dc8, 0x635dc3114bf4e633,
 0x2f9e66becd5a6b54, 0x16a6a46636a036e7, 0xc48c14ad1b30b375, 0x0487866b32fc7c92, 0xdc45a694e2b32c3f, 0x1daa8f53711071a3],
        [0xbd1631e20a214df5, 0x11c129e114f7eac4, 0x34c0aedbb7ee4e76, 0x7ad9f1ca5e006636, 0x0273c7775fd6746c, 0x9796f6741f1871b7,
 0x7cb6901010c2cc06, 0xf462ac39a75d5471, 0x0d1413dfa5066538, 0x02d9f75d1ce0d839, 0x6c1f64ef8fd0374c, 0xc05c0654fb48eb89],
        [0x87d65191c27d85bd, 0x6f28aec4dc284fbf, 0x8a1ec0e61968c518, 0xef175051ad2a3c04, 0xd3547e5b37808d75, 0x508006182bac0c15,
 0x84a6ff278dd5583d, 0xddb0a90ecade67d9, 0x04250d1f930f39df, 0xa0d01d65220f83d1, 0x4ab9359876e4b09c, 0x6142261ac4849678],
        [0x173bdad1446fc498, 0x39b99a4ff64c7449, 0x03cff50aba52fff1, 0x74005a1ce3106dd0, 0xf807143ce6fdcfd9, 0xfe33ca27a28f88a3,
 0x52e183f4fe963ec4, 0x0c54c5cb6953ef4f, 0xef17a7cd12c45b1e, 0x32d0e604aa4f931b, 0x1af632d276a86304, 0x68603d627672b50b],
        [0xfb30eda7449d4a0d, 0xb5aa5b841c638860, 0x42366e2bbbe671bc, 0xb620e6b59fbff0c4, 0xb6097488423ab37b, 0x0e3face5498ada48,
 0xc09646c681e5e2be, 0xc853cff3a8b9f47a, 0xc40da03111933c71, 0xb1c1eccff8523795, 0x6802c04f9c11442b, 0x182d6d811ee82796],
        [0xaa356233b0eafa3f, 0x064ea7a0c629eac0, 0x9c48225a0c0e76cf, 0x98e0cdb210a1b33d, 0x13410badc496e74a, 0x041a584bf7613334,
 0xb7b528b2475a76cd, 0x9797407fd8785602, 0x29fa8f37105dbbf6, 0x8a2b09fb3d5565e4, 0x85381d8f27e2a5cc, 0xd6d9456ebace8ae2],
        [0xd6bf7de060fbe569, 0x6ab1f707cce341a6, 0x78558c02ac5ba0e8, 0x929bd83ae9fca565, 0xebf05267feb654a0, 0x073198febfc56ef1,
 0xcc4bcdff0e7c7eeb, 0x8984cdfe862df215, 0x61e717d762f0b597, 0xe3fc95dfb6235adf, 0x8c382e0bc6310b68, 0x91c6974b6412262b]
    ];
    
    // External MDS matrix for t=12 (circulant structure)
    // This is a simplified version - real implementation uses carefully generated matrices
    function getExternalMatrix() internal pure returns (uint256[T][T] memory) {
        uint256[T][T] memory matrix;
        
        // Initialize with identity-like structure
        for (uint256 i = 0; i < T; i++) {
            for (uint256 j = 0; j < T; j++) {
                if (i == j) {
                    matrix[i][j] = 2;
                } else if (i == (j + 1) % T) {
                    matrix[i][j] = 1;
                } else {
                    matrix[i][j] = 0;
                }
            }
        }
        
        return matrix;
    }
    
    // Internal MDS matrix for t=12 (different structure for internal rounds)
    function getInternalMatrix() internal pure returns (uint256[T][T] memory) {
        uint256[T][T] memory matrix;
        
        // Internal matrix has special structure for efficiency
        for (uint256 i = 0; i < T; i++) {
            for (uint256 j = 0; j < T; j++) {
                if (i == 0 || j == 0) {
                    matrix[i][j] = 1; // First row/column
                } else if (i == j) {
                    matrix[i][j] = 2; // Diagonal
                } else {
                    matrix[i][j] = 0;
                }
            }
        }
        
        return matrix;
    }
    
    // Access a single round constant
    function getRoundConstant(uint256 round, uint256 index) internal pure returns (uint256) {
        if (round >= TOTAL_ROUNDS || index >= T) {
            revert RoundConstantOutOfBounds();
        }
        return ROUND_CONSTANTS_T12[round][index];
    }

    // Return the full set of round constants for initialization routines
    function getRoundConstants() internal pure returns (uint256[TOTAL_ROUNDS][T] memory rc) {
        for (uint256 r = 0; r < TOTAL_ROUNDS; r++) {
            for (uint256 i = 0; i < T; i++) {
                rc[r][i] = ROUND_CONSTANTS_T12[r][i];
            }
        }
    }
    
    // Optimized external matrix multiplication for t=12
    function externalMatrixMul12(uint256[T] memory state) 
        internal 
        pure 
        returns (uint256[T] memory) 
    {
        uint256[T] memory result;
        uint256[T][T] memory matrix = getExternalMatrix();
        
        // Matrix-vector multiplication
        for (uint256 i = 0; i < T; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < T; j++) {
                sum = addmod(sum, mulmod(state[j], matrix[i][j], P), P);
            }
            result[i] = sum;
        }
        
        return result;
    }
    
    // Optimized internal matrix multiplication for t=12
    function internalMatrixMul12(uint256[T] memory state) 
        internal 
        pure 
        returns (uint256[T] memory) 
    {
        uint256[T] memory result;
        uint256[T][T] memory matrix = getInternalMatrix();
        
        // Matrix-vector multiplication
        for (uint256 i = 0; i < T; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < T; j++) {
                sum = addmod(sum, mulmod(state[j], matrix[i][j], P), P);
            }
            result[i] = sum;
        }
        
        return result;
    }
    
    // Ultra-optimized matrix multiplication using assembly
    function externalMatrixMul12Asm(uint256[T] memory state) 
        internal 
        pure 
        returns (uint256[T] memory result) 
    {
        assembly {
            let p := P
            let statePtr := add(state, 0x20)
            let resultPtr := add(result, 0x20)
            
            // Load all state elements into stack for efficiency
            let s0 := mload(statePtr)
            let s1 := mload(add(statePtr, 0x20))
            let s2 := mload(add(statePtr, 0x40))
            let s3 := mload(add(statePtr, 0x60))
            let s4 := mload(add(statePtr, 0x80))
            let s5 := mload(add(statePtr, 0xA0))
            let s6 := mload(add(statePtr, 0xC0))
            let s7 := mload(add(statePtr, 0xE0))
            let s8 := mload(add(statePtr, 0x100))
            let s9 := mload(add(statePtr, 0x120))
            let s10 := mload(add(statePtr, 0x140))
            let s11 := mload(add(statePtr, 0x160))
            
            // Optimized matrix multiplication for external matrix
            // Row 0: [2,1,0,0,0,0,0,0,0,0,0,0]
            let r0 := addmod(mulmod(s0, 2, p), s1, p)
            
            // Row 1: [0,2,1,0,0,0,0,0,0,0,0,0]
            let r1 := addmod(mulmod(s1, 2, p), s2, p)
            
            // Row 2: [0,0,2,1,0,0,0,0,0,0,0,0]
            let r2 := addmod(mulmod(s2, 2, p), s3, p)
            
            // Row 3: [0,0,0,2,1,0,0,0,0,0,0,0]
            let r3 := addmod(mulmod(s3, 2, p), s4, p)
            
            // Row 4: [0,0,0,0,2,1,0,0,0,0,0,0]
            let r4 := addmod(mulmod(s4, 2, p), s5, p)
            
            // Row 5: [0,0,0,0,0,2,1,0,0,0,0,0]
            let r5 := addmod(mulmod(s5, 2, p), s6, p)
            
            // Row 6: [0,0,0,0,0,0,2,1,0,0,0,0]
            let r6 := addmod(mulmod(s6, 2, p), s7, p)
            
            // Row 7: [0,0,0,0,0,0,0,2,1,0,0,0]
            let r7 := addmod(mulmod(s7, 2, p), s8, p)
            
            // Row 8: [0,0,0,0,0,0,0,0,2,1,0,0]
            let r8 := addmod(mulmod(s8, 2, p), s9, p)
            
            // Row 9: [0,0,0,0,0,0,0,0,0,2,1,0]
            let r9 := addmod(mulmod(s9, 2, p), s10, p)
            
            // Row 10: [0,0,0,0,0,0,0,0,0,0,2,1]
            let r10 := addmod(mulmod(s10, 2, p), s11, p)
            
            // Row 11: [1,0,0,0,0,0,0,0,0,0,0,2] (circulant)
            let r11 := addmod(s0, mulmod(s11, 2, p), p)
            
            // Store results
            mstore(resultPtr, r0)
            mstore(add(resultPtr, 0x20), r1)
            mstore(add(resultPtr, 0x40), r2)
            mstore(add(resultPtr, 0x60), r3)
            mstore(add(resultPtr, 0x80), r4)
            mstore(add(resultPtr, 0xA0), r5)
            mstore(add(resultPtr, 0xC0), r6)
            mstore(add(resultPtr, 0xE0), r7)
            mstore(add(resultPtr, 0x100), r8)
            mstore(add(resultPtr, 0x120), r9)
            mstore(add(resultPtr, 0x140), r10)
            mstore(add(resultPtr, 0x160), r11)
        }
    }
    
    // Ultra-optimized internal matrix multiplication
    function internalMatrixMul12Asm(uint256[T] memory state) 
        internal 
        pure 
        returns (uint256[T] memory result) 
    {
        assembly {
            let p := P
            let statePtr := add(state, 0x20)
            let resultPtr := add(result, 0x20)
            
            // Load state elements
            let s0 := mload(statePtr)
            let s1 := mload(add(statePtr, 0x20))
            let s2 := mload(add(statePtr, 0x40))
            let s3 := mload(add(statePtr, 0x60))
            let s4 := mload(add(statePtr, 0x80))
            let s5 := mload(add(statePtr, 0xA0))
            let s6 := mload(add(statePtr, 0xC0))
            let s7 := mload(add(statePtr, 0xE0))
            let s8 := mload(add(statePtr, 0x100))
            let s9 := mload(add(statePtr, 0x120))
            let s10 := mload(add(statePtr, 0x140))
            let s11 := mload(add(statePtr, 0x160))
            
            // Internal matrix: first row/column = 1, diagonal = 2
            // Row 0: [1,1,1,1,1,1,1,1,1,1,1,1]
            let sum := add(add(add(add(add(add(add(add(add(add(add(s0, s1), s2), s3), s4), s5), s6), s7), s8), s9), s10), s11)
            mstore(resultPtr, mod(sum, p))
            
            // Rows 1-11: [1,2,0,0,0,0,0,0,0,0,0,0] pattern
            mstore(add(resultPtr, 0x20), addmod(s0, mulmod(s1, 2, p), p))
            mstore(add(resultPtr, 0x40), addmod(s0, mulmod(s2, 2, p), p))
            mstore(add(resultPtr, 0x60), addmod(s0, mulmod(s3, 2, p), p))
            mstore(add(resultPtr, 0x80), addmod(s0, mulmod(s4, 2, p), p))
            mstore(add(resultPtr, 0xA0), addmod(s0, mulmod(s5, 2, p), p))
            mstore(add(resultPtr, 0xC0), addmod(s0, mulmod(s6, 2, p), p))
            mstore(add(resultPtr, 0xE0), addmod(s0, mulmod(s7, 2, p), p))
            mstore(add(resultPtr, 0x100), addmod(s0, mulmod(s8, 2, p), p))
            mstore(add(resultPtr, 0x120), addmod(s0, mulmod(s9, 2, p), p))
            mstore(add(resultPtr, 0x140), addmod(s0, mulmod(s10, 2, p), p))
            mstore(add(resultPtr, 0x160), addmod(s0, mulmod(s11, 2, p), p))
        }
    }
}