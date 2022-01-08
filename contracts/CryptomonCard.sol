// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./CryptomonCollection.sol";

contract CryptomonCard is CryptomonCollection {
    struct Cryptomon {
        uint256 monIndex;
        uint8 monLevel;
        uint8 evolution;
        uint16 XP;
        uint32 readyTime;
        address owner;
    }

    Cryptomon[] public cryptomons;
    event LogCryptomonCard(address indexed owner, uint256 monIndex);

    modifier checkCardOwner(uint256 _monIndex) {
        require(
            cryptomons[_monIndex].owner == msg.sender,
            "You are not the owner of this card"
        );
        _;
    }

    function createCryptomonCard(uint256 _monIndex) public {
        cryptomons.push(
            Cryptomon(_monIndex, 1, 1, 0, uint32(block.timestamp), msg.sender)
        );
        emit LogCryptomonCard(msg.sender, _monIndex);
    }

    function getCryptomonCard(uint256 _monId)
        public
        view
        returns (Cryptomon memory)
    {
        return cryptomons[_monId];
    }

    function increaseXP(uint256 _monId, uint16 _XPToIncrease)
        public
        checkCardOwner(_monId)
    {
        uint16 XP = cryptomons[_monId].XP;
        uint16 noOfEvolution = uint16(
            monCollections[cryptomons[_monId].monIndex].names.length
        );
        XP = XP + _XPToIncrease;
        uint16 rangeOfXP = 80 + uint16(cryptomons[_monId].monLevel) * 20;
        if (XP >= rangeOfXP) {
            XP = XP - rangeOfXP;
            cryptomons[_monId].monLevel = cryptomons[_monId].monLevel + 1;
            uint8 monLevel = cryptomons[_monId].monLevel;

            uint256 evolution = uint256(
                1 +
                    ((uint256(noOfEvolution) - 1) * 10 * uint256(monLevel)) /
                    (100 + 9 * uint256(monLevel))
            );
            if (evolution > uint256(cryptomons[_monId].evolution)) {
                cryptomons[_monId].evolution = cryptomons[_monId].evolution + 1;
            }
        }
        cryptomons[_monId].XP = XP;
    }
}
