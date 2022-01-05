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

    function createCryptomonCard(uint256 _monIndex) public {
        cryptomons.push(Cryptomon(_monIndex, 1, 0, 0, msg.sender));
        emit LogCryptomonCard(msg.sender, _monIndex);
    }

    function getCryptomonCard(uint256 _monIndex)
        public
        view
        returns (Cryptomon memory)
    {
        return cryptomons[_monIndex];
    }
}
