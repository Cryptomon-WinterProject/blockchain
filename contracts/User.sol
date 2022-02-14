// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./CryptomonCard.sol";

contract User is CryptomonCard {
    // Temporary structure for player
    struct Player {
        string name;
        string profilePictureURL;
        bool verified;
        bool availableForChallenge;
        uint256 winCount;
        uint256 lossCount;
        uint256 level;
        uint256 xp;
        uint256 monCoinBalance;
        uint256 winStreak;
        uint256 lossStreak;
    }

    address[] public userAddresses;
    mapping(address => Player) public users;

    modifier onlyVerifiedUser(address _player) {
        require(users[_player].verified, "Player not verified!");
        _;
    }

    // function createTestReadyUser(string memory _name) public {
    //     Player memory user = Player({
    //         name: _name,
    //         profilePictureURL: "",
    //         verified: true,
    //         availableForChallenge: false,
    //         winCount: 0,
    //         lossCount: 0,
    //         level: 1,
    //         xp: 0,
    //         monCoinBalance: 0,
    //         winStreak: 0,
    //         lossStreak: 0
    //     });
    //     userAddresses.push(msg.sender);
    //     users[msg.sender] = user;
    //     for (uint256 i = 0; i < 5; i++) {
    //         // Random number to allot cryptomon card
    //         createCryptomonCard(i);
    //     }
    // }

    function createUser(
        string memory _name,
        string memory _profilePictureUrl,
        uint256[5] memory randArr
    ) public {
        Player memory user = Player({
            name: _name,
            profilePictureURL: _profilePictureUrl,
            verified: true,
            availableForChallenge: false,
            winCount: 0,
            lossCount: 0,
            level: 1,
            xp: 0,
            monCoinBalance: 0,
            winStreak: 0,
            lossStreak: 0
        });
        userAddresses.push(msg.sender);
        users[msg.sender] = user;
        for (uint256 i = 0; i < 5; i++) {
            // Random number to allot cryptomon card
            createCryptomonCard(randArr[i]);
        }
    }

    function getUserCards() public view returns (uint256[] memory) {
        uint256 numCards = 0;
        for (uint256 i = 0; i < cryptomons.length; i++) {
            if (cryptomons[i].owner == msg.sender) {
                numCards++;
            }
        }
        uint256[] memory cards = new uint256[](numCards);
        uint8 index = 0;
        for (uint256 i = 0; i < cryptomons.length; i++) {
            if (cryptomons[i].owner == msg.sender) {
                cards[index] = i;
                index++;
            }
        }
        return cards;
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

    // function buyMonCoins() public payable {
    //     require(msg.value % 1000 == 0, "Amount must be in multiples of 1000");
    //     users[msg.sender].monCoinBalance += msg.value / 1000;
    // }

    function updateWinCount(address _userAddress) public onlyOwner {
        Player memory user = users[_userAddress];
        user.winCount++;
        user.level = ((user.winCount * 100) / (100 + user.winCount)) + 1;
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
