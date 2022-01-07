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
        cryptomons.push(Cryptomon(_monIndex, 1, 1, 0, msg.sender));
        emit LogCryptomonCard(msg.sender, _monIndex);
    }

    function getCryptomonCard(uint256 _monIndex)
        public
        view
        returns (Cryptomon memory)
    {
        return cryptomons[_monIndex];
    }

    function increaseXP(uint256 _monIndex, uint16 _XPToIncrease)
        public
        checkCardOwner(_monIndex)
    {
        uint16 XP = cryptomons[_monIndex].XP;
        uint16 noOfEvolution = uint16(
            monCollections[cryptomons[_monIndex].monIndex].names.length
        );
        XP = XP + _XPToIncrease;
        uint16 rangeOfXP = 80 + uint16(cryptomons[_monIndex].monLevel) * 20;
        if (XP >= rangeOfXP) {
            XP = XP - rangeOfXP;
            cryptomons[_monIndex].monLevel = cryptomons[_monIndex].monLevel + 1;
            uint8 monLevel = cryptomons[_monIndex].monLevel;

            uint256 evolution = uint256(
                1 +
                    ((uint256(noOfEvolution) - 1) * 10 * uint256(monLevel)) /
                    (100 + 9 * uint256(monLevel))
            );
            if (evolution > uint256(cryptomons[_monIndex].evolution)) {
                cryptomons[_monIndex].evolution =
                    cryptomons[_monIndex].evolution +
                    1;
            }
        }
        cryptomons[_monIndex].XP = XP;
    }
}
