// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./User.sol";

contract Training is User {
    modifier _isReady(uint32 _readyTime) {
        require(
            _readyTime <= uint32(block.timestamp),
            "Cryptomon is not ready yet"
        );
        _;
    }

    function trainCryptomon(
        uint256 _monId,
        uint8 _timeToTrain,
        uint256 _monCoins
    ) public _isReady(cryptomons[_monId].readyTime) checkCardOwner(_monId) {
        require(
            _timeToTrain >= 5 &&
                _timeToTrain <= 180 &&
                users[msg.sender].monCoinBalance >= _monCoins,
            "Time to train must be between 5 Mins to 180 Mins"
        );
        cryptomons[_monId].readyTime = uint32(
            block.timestamp + (uint32(_timeToTrain) * 60)
        );
        users[msg.sender].monCoinBalance -= _monCoins;
        uint16 XPToIncrease = uint16(
            (monCollections[cryptomons[_monId].monIndex].trainingGainPerHour *
                ((uint16(_timeToTrain) * 100) / 60 + (_monCoins * 100) / 20)) /
                100
        );
        increaseXP(_monId, XPToIncrease);
    }
}
