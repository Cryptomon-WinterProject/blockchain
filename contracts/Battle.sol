// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./User.sol";

contract Battle is User {
    // constructor() public {}

    struct BattlingMons {
        uint256[] challengerMons;
        uint256[] opponentMons;
    }

    mapping(bytes32 => bool) public ongoingChallenges;
    mapping(bytes32 => BattlingMons) internal monsInBattle;

    event ChallengeReady(address _player);
    event NewChallenge(
        address _challenger,
        address indexed _opponent,
        uint256[] _monIds
    );
    event AcceptChallenge(
        bytes32 _challengeHash,
        uint256 _challengerMon,
        uint256 _opponentMon
    );
    event AnnounceWinner(bytes32 _challengeHash, uint256 _winnerMon);

    modifier onlyVerifiedUser(address _player) {
        require(users[_player].verified, "Player not verified!");
        _;
    }

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
                cryptomons[i].owner == msg.sender,
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
        public
        onlyOnlinePlayer(msg.sender)
        onlyOnlinePlayer(_opponent)
        onlyAvailableMons(_monIds)
    {
        bytes32 challengeHash = keccak256(
            abi.encodePacked(msg.sender, _opponent)
        );

        ongoingChallenges[challengeHash] = true;

        BattlingMons memory mons = BattlingMons({
            challengerMons: _monIds,
            opponentMons: new uint256[](3)
        });

        monsInBattle[challengeHash] = mons;

        users[msg.sender].availableForChallenge = false;

        emit NewChallenge(msg.sender, _opponent, _monIds);
    }

    function accept(address _challenger, uint256 _monId) public {}

    function settleChallenge(bytes32 _challengeHash, uint8 _randomNumber)
        public
        onlyOwner
    {}
}
