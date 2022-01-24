// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Training.sol";

contract User is Training {
    // Temporary structure for player
    struct Player {
        string name;
        bool verified;
        bool availableForChallenge;
        uint256 winCount;
        uint256 lossCount;
        uint256 level;
        uint256 xp;
        uint256 monCoinBalance;
    }

    address[] public userAddresses;
    mapping(address => Player) public users;
    mapping(address => uint256[]) public cardOwnedByUser;

    modifier onlyVerifiedUser(address _player) {
        require(users[_player].verified, "Player not verified!");
        _;
    }

    function createTestReadyUser(string memory _name) public {
        Player memory user = Player({
            name: _name,
            verified: true,
            availableForChallenge: false,
            winCount: 0,
            lossCount: 0,
            level: 1,
            xp: 0,
            monCoinBalance: 0
        });
        userAddresses.push(msg.sender);
        users[msg.sender] = user;
        for (uint256 i = 0; i < 5; i++) {
            // Random number to allot cryptomon card
            createCryptomonCard(i);
            cardOwnedByUser[msg.sender].push(cryptomons.length + i);
        }
    }

    function updateUserConnectivityStatus(address _userAddress, bool _online)
        external
        onlyOwner
        onlyVerifiedUser(_userAddress)
    {
        Player memory user = users[_userAddress];
        user.availableForChallenge = _online;
        users[_userAddress] = user;
    }

    function getOnlinePlayers()
        public
        view
        returns (address[] memory _players)
    {
        uint256 noOfReadyPlayers = 0;
        for (uint256 index = 0; index < userAddresses.length; index++) {
            if (
                users[userAddresses[index]].verified &&
                users[userAddresses[index]].availableForChallenge
            ) {
                noOfReadyPlayers++;
            }
        }

        address[] memory challengeReadyPlayers = new address[](
            noOfReadyPlayers
        );
        for (uint256 index = 0; index < userAddresses.length; index++) {
            if (
                users[userAddresses[index]].verified &&
                users[userAddresses[index]].availableForChallenge
            ) {
                challengeReadyPlayers[index] = userAddresses[index];
            }
        }

        return challengeReadyPlayers;
    }
}
