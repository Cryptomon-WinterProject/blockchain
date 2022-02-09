// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./CryptomonType.sol";

contract CryptomonCollection is CryptomonType {
    struct MonCollection {
        string[] names;
        string[] images;
        uint256 price;
        string monType;
        uint8 trainingGainPerHour;
    }
    event CollectionCreated(
        string[] names,
        string[] images,
        string monType,
        uint8 trainingGainPerHour
    );

    MonCollection[] public monCollections;

    function editMonCollection(
        string[] memory _names,
        string[] memory _images,
        uint256 _price,
        string memory _monType,
        uint8 _trainingGainPerHour,
        uint256 id
    ) public onlyOwner {
        monCollections[id].names = _names;
        monCollections[id].images = _images;
        monCollections[id].price = _price;
        monCollections[id].monType = _monType;
        monCollections[id].trainingGainPerHour = _trainingGainPerHour;
        emit CollectionCreated(_names, _images, _monType, _trainingGainPerHour);
    }

    function createMonCollection(
        string[] memory _names,
        string[] memory _images,
        uint256 _price,
        string memory _monType,
        uint8 _trainingGainPerHour
    ) public onlyOwner returns (uint256) {
        MonCollection memory monColl = MonCollection(
            new string[](0),
            new string[](0),
            0,
            new string(0),
            0
        );
        monCollections.push(monColl);
        uint256 collectionId = monCollections.length - 1;
        for (uint256 i = 0; i < _names.length; i++) {
            monCollections[collectionId].names.push(_names[i]);
            monCollections[collectionId].images.push(_images[i]);
        }
        monCollections[collectionId].price = _price;
        monCollections[collectionId].monType = _monType;
        monCollections[collectionId].trainingGainPerHour = _trainingGainPerHour;
        emit CollectionCreated(_names, _images, _monType, _trainingGainPerHour);
        return collectionId;
    }

    function getMonCollection(uint256 _index)
        public
        view
        returns (MonCollection memory)
    {
        return monCollections[_index];
    }

    function getMonCollectionCount() public view returns (uint256) {
        uint256 monCollectionsLength = monCollections.length;
        return monCollectionsLength;
    }

    function deleteMonCollection(uint256 index)
        public
        onlyOwner
        returns (MonCollection[] memory)
    {
        if (index >= monCollections.length) return monCollections;

        for (uint256 i = index; i < monCollections.length - 1; i++) {
            monCollections[i] = monCollections[i + 1];
        }
        delete monCollections[monCollections.length - 1];
        monCollections.pop();
        return monCollections;
    }
}
