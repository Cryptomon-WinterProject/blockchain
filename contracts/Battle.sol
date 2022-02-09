// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./User.sol";

contract Battle is User {
    struct CalcParams {
        uint16 randomNumberMultiplier;
        uint16 monWinXPIncrease;
        uint16 monWinXPLevelImpact;
        uint16 winnerMoncoinsIncrease;
        uint16 winnerMoncoinsLevelImpactFactor;
        uint16 typeFactor;
    }

    CalcParams calcParams =
        CalcParams({
            randomNumberMultiplier: 1000,
            monWinXPIncrease: 50,
            monWinXPLevelImpact: 20,
            winnerMoncoinsIncrease: 1,
            winnerMoncoinsLevelImpactFactor: 20,
            typeFactor: 1
        });

    struct BattlingMons {
        uint256[] challengerMons;
        uint256[] opponentMons;
    }

    mapping(bytes32 => uint8) public challengeStatus;
    // 0 -> non going on OR settled battle
    // 1 -> Challanged but not yet accepted
    // 2 -> Challanged, accepted and ongoing

    mapping(bytes32 => BattlingMons) internal monsInBattle;

    event ChallengeReady(address _player);
    event NewChallenge(
        address _challenger,
        address indexed _opponent,
        uint256[] _monIds
    );
    event AcceptChallenge(
        bytes32 _challengeHash,
        uint256[] _challengerMons,
        uint256[] _opponentMons
    );

    event AnnounceRoundWinner(
        bytes32 _challengeHash,
        address _winner,
        uint16 _xpGained
    );
    event AnnounceWinner(bytes32 _challengeHash, address _winner);

    modifier onlyOnlinePlayer(address _player) {
        require(
            users[_player].availableForChallenge,
            "Player is not ready for a challenge"
        );
        _;
    }

    modifier onlyAvailableMons(uint256[] memory _monIds) {
        for (uint256 i = 0; i < _monIds.length; i++) {
            require(
                cryptomons[_monIds[i]].owner == msg.sender,
                "You don't own this mon!"
            );
            // commented out because available is not implemented yet in the contract cryptomons
            // require(cryptomons[_monIds[i]].available, "Mon not available");
        }
        _;
    }

    function setCalcParams(
        uint16 _randomNumberMultiplier,
        uint16 _monWinXPIncrease,
        uint16 _monWinXPLevelImpact,
        uint16 _winnerMoncoinsIncrease,
        uint16 _winnerMoncoinsLevelImpact,
        uint16 _typeFactor
    ) public onlyOwner {
        calcParams = CalcParams({
            randomNumberMultiplier: _randomNumberMultiplier,
            monWinXPIncrease: _monWinXPIncrease,
            monWinXPLevelImpact: _monWinXPLevelImpact,
            winnerMoncoinsIncrease: _winnerMoncoinsIncrease,
            winnerMoncoinsLevelImpactFactor: _winnerMoncoinsLevelImpact,
            typeFactor: _typeFactor
        });
    }

    function getMonsInBattle(bytes32 _challengeHash)
        public
        view
        returns (BattlingMons memory)
    {
        return monsInBattle[_challengeHash];
    }

    function challenge(address _opponent, uint256[] memory _monIds)
        external
        onlyOnlinePlayer(msg.sender)
        onlyOnlinePlayer(_opponent)
        onlyAvailableMons(_monIds)
    {
        bytes32 challengeHash = keccak256(
            abi.encodePacked(msg.sender, _opponent)
        );

        challengeStatus[challengeHash] = 1;

        BattlingMons memory mons = BattlingMons({
            challengerMons: _monIds,
            opponentMons: new uint256[](3)
        });

        monsInBattle[challengeHash] = mons;

        users[msg.sender].availableForChallenge = false;

        emit NewChallenge(msg.sender, _opponent, _monIds);
    }

    function acceptChallenge(address _challenger, uint256[] memory _monIds)
        external
        onlyOnlinePlayer(msg.sender)
        onlyAvailableMons(_monIds)
    {
        bytes32 challengeHash = keccak256(
            abi.encodePacked(_challenger, msg.sender)
        );
        require(
            challengeStatus[challengeHash] == 1,
            "Challenge does not exist"
        );

        challengeStatus[challengeHash] = 2;

        BattlingMons storage mons = monsInBattle[challengeHash];

        mons.opponentMons = _monIds;
        users[_challenger].availableForChallenge = false;

        emit AcceptChallenge(challengeHash, mons.challengerMons, _monIds);
    }

    function getTypeAdvantage(string memory _type1, string memory _type2)
        internal
        view
        returns (uint256)
    {
        if (compareStrings(_type1, _type2)) {
            return 0;
        } else if (
            containsStringInArray(cryptomonTypesAdvantages[_type1], _type2)
        ) {
            return 1;
        } else {
            return 0;
        }
    }

    function decideWinner(
        uint256 _x,
        uint256 _y,
        uint16 _rand
    ) internal view returns (bool) {
        if ((_x + _y) * _rand <= _x * calcParams.randomNumberMultiplier) {
            return true;
        } else {
            return false;
        }
    }

    function calculateMonWinXPIncrease(Cryptomon memory _mon)
        internal
        view
        returns (uint16)
    {
        return
            calcParams.monWinXPIncrease -
            ((_mon.monLevel * calcParams.monWinXPLevelImpact) /
                calcXPRange(_mon.monLevel));
    }

    function settleChallenge(
        bytes32 _challengeHash,
        uint16[] memory _randomNumber
    ) public onlyOwner {
        require(
            challengeStatus[_challengeHash] == 2,
            "Challenge is not ongoing"
        );

        BattlingMons memory battleMons = monsInBattle[_challengeHash];

        Cryptomon[] memory challengerMons = new Cryptomon[](3);
        Cryptomon[] memory opponentMons = new Cryptomon[](3);

        for (uint256 i = 0; i < battleMons.challengerMons.length; i++) {
            challengerMons[i] = cryptomons[battleMons.challengerMons[i]];
            opponentMons[i] = cryptomons[battleMons.opponentMons[i]];
        }

        Player memory challenger = users[challengerMons[0].owner];
        Player memory opponent = users[opponentMons[0].owner];

        uint8 challangerWinCount = 0;
        for (uint8 index = 0; index < 3; index++) {
            int256 challengerAdvantagePts = int256(
                (challengerMons[index].monLevel) *
                    (1 +
                        calcParams.typeFactor *
                        getTypeAdvantage(
                            monCollections[challengerMons[index].monIndex]
                                .monType,
                            monCollections[opponentMons[index].monIndex].monType
                        )) +
                    challenger.level +
                    exponential(challenger.lossStreak) -
                    exponential(challenger.winStreak)
            );
            int256 opponentAdvantagePts = int256(
                (opponentMons[index].monLevel) *
                    (1 +
                        calcParams.typeFactor *
                        getTypeAdvantage(
                            monCollections[opponentMons[index].monIndex]
                                .monType,
                            monCollections[challengerMons[index].monIndex]
                                .monType
                        )) +
                    opponent.level +
                    exponential(opponent.lossStreak) -
                    exponential(opponent.winStreak)
            );

            if (challengerAdvantagePts < 0) {
                challengerAdvantagePts = 1;
            }
            if (opponentAdvantagePts < 0) {
                opponentAdvantagePts = 1;
            }

            if (
                decideWinner(
                    uint256(challengerAdvantagePts),
                    uint256(opponentAdvantagePts),
                    _randomNumber[index]
                )
            ) {
                challangerWinCount++;
                uint16 monWinXPIncrease = calculateMonWinXPIncrease(
                    challengerMons[index]
                );
                increaseXP(battleMons.challengerMons[index], monWinXPIncrease);
                emit AnnounceRoundWinner(
                    _challengeHash,
                    challengerMons[0].owner,
                    monWinXPIncrease
                );
            } else {
                uint16 monWinXPIncrease = calculateMonWinXPIncrease(
                    opponentMons[index]
                );
                increaseXP(battleMons.opponentMons[index], monWinXPIncrease);
                emit AnnounceRoundWinner(
                    _challengeHash,
                    opponentMons[0].owner,
                    monWinXPIncrease
                );
            }
        }
        if (challangerWinCount >= 2) {
            challenger.winStreak++;
            challenger.lossStreak = 0;
            opponent.lossStreak++;
            opponent.winStreak = 0;
            emit AnnounceWinner(_challengeHash, challengerMons[0].owner);
            
        } else {
            challenger.lossStreak++;
            challenger.winStreak = 0;
            opponent.lossStreak++;
            opponent.winStreak = 0;
            emit AnnounceWinner(_challengeHash, opponentMons[0].owner);
        }
    }
}
