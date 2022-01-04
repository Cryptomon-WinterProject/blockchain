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

    function createMonCollection(
        string[] memory _names,
        string[] memory _images,
        string memory _monType
    ) private onlyOwner returns (uint256) {
        monCollections.push(
            MonCollection({names: _names, images: _images, monType: _monType})
        );
        uint256 collectionId = monCollections.length - 1;
        return collectionId;
    }
}
