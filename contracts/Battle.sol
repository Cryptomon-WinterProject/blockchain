// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./User.sol";

contract Battle is User {
    // constructor() public {}

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

    function settleChallenge(bytes32 _challengeHash, uint8 _randomNumber)
        public
        onlyOwner
    {}
}
