// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../Poseidon2Constants.sol";

contract Poseidon2ConstantsHarness {
    function getRoundConstant(uint256 round, uint256 index) external pure returns (uint256) {
        return Poseidon2Constants.getRoundConstant(round, index);
    }
}

contract Poseidon2ConstantsTest is Test {
    using stdJson for string;

    string constant ARTIFACT_PATH = "packages/our-implementation/scripts/artifacts/poseidon2_goldilocks_t12.json";

    function testRoundConstantsMatchArtifacts() public {
        Poseidon2ConstantsHarness harness = new Poseidon2ConstantsHarness();
        string memory raw = vm.readFile(ARTIFACT_PATH);
        uint256 totalRounds = raw.readUint(".totalRounds");
        uint256 width = raw.readUint(".t");

        for (uint256 r = 0; r < totalRounds; r++) {
            for (uint256 i = 0; i < width; i++) {
                string memory key = string(
                    abi.encodePacked(
                        ".roundConstants[",
                        vm.toString(r),
                        "][",
                        vm.toString(i),
                        "]"
                    )
                );
                string memory valueHex = raw.readString(key);
                uint256 expected = _hexStringToUint(valueHex);
                uint256 onchain = harness.getRoundConstant(r, i);
                assertEq(onchain, expected, string.concat("Mismatch at round ", vm.toString(r), ", index ", vm.toString(i)));
            }
        }
    }

    function _hexStringToUint(string memory input) internal pure returns (uint256 result) {
        bytes memory strBytes = bytes(input);
        require(strBytes.length >= 3, "hex string too short");
        require(strBytes[0] == '0' && (strBytes[1] == 'x' || strBytes[1] == 'X'), "invalid hex prefix");

        for (uint256 i = 2; i < strBytes.length; i++) {
            uint8 charCode = uint8(strBytes[i]);
            uint8 value;
            if (charCode >= 48 && charCode <= 57) {
                value = charCode - 48;
            } else if (charCode >= 65 && charCode <= 70) {
                value = charCode - 55;
            } else if (charCode >= 97 && charCode <= 102) {
                value = charCode - 87;
            } else {
                revert("invalid hex char");
            }
            result = (result << 4) | value;
        }
    }
}
