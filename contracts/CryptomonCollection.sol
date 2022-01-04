// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptomonCollection is Ownable {
    struct MonCollection {
        string[] names;
        string[] images;
        string monType;
    }

    MonCollection[] public monCollections;

    function createMonCollection() private onlyOwner {}
}
