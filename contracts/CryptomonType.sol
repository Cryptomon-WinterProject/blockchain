// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Helper.sol";

contract CryptomonType is Ownable, Helper {
    mapping(string => string[]) public cryptomonTypesAdvantages;

    function updateCryptomonTypeAdvantages(
        string memory _type,
        string[] memory _advantagesAgainst
    ) public onlyOwner {
        cryptomonTypesAdvantages[_type] = _advantagesAgainst;
    }
}
