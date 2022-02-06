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
        return (11 * a) / (4 * a);
    }
}