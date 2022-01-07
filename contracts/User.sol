// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./CryptomonCard.sol";

contract User is CryptomonCard {
    // Temporary structure for player
    struct Player {
        string name;
        bool verified;
        bool online;
        uint256 winCount;
        uint256 lossCount;
        uint256 level;
        uint256 xp;
    }

    address[] public userAddresses;
    mapping(address => Player) public users;

    // constructor() public {}

    //Temporary function to create a user
    function createTestReadyUser(string memory _name) public {
        Player memory user = Player({
            name: _name,
            verified: true,
            online: false,
            winCount: 0,
            lossCount: 0,
            level: 1,
            xp: 0
        });
        userAddresses.push(msg.sender);
        users[msg.sender] = user;
        for (uint256 i = 0; i < 5; i++) {
            createCryptomonCard(i);
        }
    }

    function updateUserConnectivityStatus(address _userAddress, bool _online)
        external
        onlyOwner
    {
        Player memory user = users[_userAddress];
        user.online = _online;
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
                users[userAddresses[index]].online
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
                users[userAddresses[index]].online
            ) {
                challengeReadyPlayers[index] = userAddresses[index];
            }
        }

        return challengeReadyPlayers;
    }
}
