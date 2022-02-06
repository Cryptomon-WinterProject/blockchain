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
    }

    CalcParams calcParams =
        CalcParams({
            randomNumberMultiplier: 1000,
            monWinXPIncrease: 50,
            monWinXPLevelImpact: 20,
            winnerMoncoinsIncrease: 1,
            winnerMoncoinsLevelImpactFactor: 20
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
        uint256[] _xpGained
    );
    event AnnounceWinner(bytes32 _challengeHash, uint256 _winnerMon);

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
        uint16 _winnerMoncoinsLevelImpact
    ) public onlyOwner {
        calcParams = CalcParams({
            randomNumberMultiplier: _randomNumberMultiplier,
            monWinXPIncrease: _monWinXPIncrease,
            monWinXPLevelImpact: _monWinXPLevelImpact,
            winnerMoncoinsIncrease: _winnerMoncoinsIncrease,
            winnerMoncoinsLevelImpactFactor: _winnerMoncoinsLevelImpact
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
        pure
        returns (uint256)
    {
        if (compareStrings(_type1, _type2)) {
            return 0;
        } else {
            return 1;
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

    function calculateMonWinXPIncrease(Cryptomon memory _challengerMon)
        internal
        view
        returns (uint16)
    {
        return
            calcParams.randomNumberMultiplier -
            ((_challengerMon.monLevel * calcParams.monWinXPLevelImpact) /
                calcXPRange(_challengerMon.monLevel));
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
        address challenger = cryptomons[battleMons.challengerMons[0]].owner;
        address opponent = cryptomons[battleMons.opponentMons[0]].owner;

        Cryptomon[] memory challengerMons = new Cryptomon[](3);
        Cryptomon[] memory opponentMons = new Cryptomon[](3);

        for (uint256 i = 0; i < battleMons.challengerMons.length; i++) {
            challengerMons[i] = cryptomons[battleMons.challengerMons[i]];
            opponentMons[i] = cryptomons[battleMons.opponentMons[i]];
        }

        uint8 challangerWinCount = 0;
        for (uint8 index = 0; index < 3; index++) {
            int256 challengerAdvantagePts = int256(
                (challengerMons[index].monLevel) *
                    (1 +
                        getTypeAdvantage(
                            monCollections[challengerMons[index].monIndex]
                                .monType,
                            monCollections[opponentMons[index].monIndex].monType
                        )) +
                    users[challenger].level +
                    exponential(users[challenger].lossStreak) -
                    exponential(users[challenger].winStreak)
            );
            int256 opponentAdvantagePts = int256(
                (opponentMons[index].monLevel) *
                    (1 +
                        getTypeAdvantage(
                            monCollections[opponentMons[index].monIndex]
                                .monType,
                            monCollections[challengerMons[index].monIndex]
                                .monType
                        )) +
                    users[opponent].level +
                    exponential(users[opponent].lossStreak) -
                    exponential(users[opponent].winStreak)
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
                emit AnnounceRoundWinner(_challengeHash, _winner, _xpGained);
            } else {
                increaseXP(
                    battleMons.opponentMons[index],
                    calculateMonWinXPIncrease(opponentMons[index])
                );
            }
        }
    }
}
