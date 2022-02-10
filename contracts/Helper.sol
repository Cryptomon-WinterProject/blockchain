// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Helper {
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function exponential(uint256 a) public pure returns (uint256) {
        return (11 ** a) / (4 ** a);
    }

    function containsStringInArray(string[] memory array, string memory value)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < array.length; i++) {
            if (compareStrings(array[i], value)) {
                return true;
            }
        }
        return false;
    }
}
