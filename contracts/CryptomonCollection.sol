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
    event CollectionCreated(string[] names, string[] images, string monType);

    MonCollection[] public monCollections;

    function createMonCollection(
        string[] memory _names,
        string[] memory _images,
        string memory _monType
    ) public returns (uint256) {
        MonCollection memory monColl = MonCollection(
            new string[](0),
            new string[](0),
            new string(0)
        );
        monCollections.push(monColl);
        uint256 collectionId = monCollections.length - 1;
        for (uint256 i = 0; i < _names.length; i++) {
            monCollections[collectionId].names.push(_names[i]);
            monCollections[collectionId].images.push(_images[i]);
        }
        monCollections[collectionId].monType = _monType;
        emit CollectionCreated(_names, _images, _monType);
        return collectionId;
    }

    function getMonCollection(uint256 _index)
        public
        view
        returns (MonCollection memory)
    {
        return monCollections[_index];
    }
}
