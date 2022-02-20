// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AuctionMons.sol";

contract Auction is AuctionMons {
    mapping(address => mapping(uint256 => uint256)) public monCoinBid;

    event NewBid(uint256 _cardIndex, address _bidder, uint256 _bidAmount);

    function bid(uint256 _cardIndex, uint256 monCoins) public beforeEndTime {
        require(
            monCoinBid[msg.sender][_cardIndex] + monCoins >
                auctionCards[_cardIndex].highestBid &&
                users[msg.sender].monCoinBalance >= monCoins &&
                cryptomons[auctionCards[_cardIndex].monId].owner != msg.sender
        );
        auctionCards[_cardIndex].highestBidder = msg.sender;
        monCoinBid[msg.sender][_cardIndex] += monCoins;
        auctionCards[_cardIndex].highestBid = monCoinBid[msg.sender][
            _cardIndex
        ];
        users[msg.sender].monCoinBalance -= monCoins;

        emit NewBid(_cardIndex, msg.sender, monCoins);
    }

    function settleAuction(uint256 _cardIndex, address[] memory userAddresses)
        public
        onlyOwner
    {
        AuctionCard memory auctionCard = auctionCards[_cardIndex];
        if (
            auctionCard.highestBidder == address(0) ||
            auctionCard.highestBid == 0
        ) {
            return;
        }
        users[cryptomons[auctionCard.monId].owner].monCoinBalance =
            users[cryptomons[auctionCard.monId].owner].monCoinBalance +
            auctionCard.highestBid;
        cryptomons[auctionCard.monId].owner = auctionCard.highestBidder;
        auctionCards[_cardIndex].isSold = true;

        for (uint256 i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] != auctionCard.highestBidder) {
                users[userAddresses[i]].monCoinBalance =
                    users[userAddresses[i]].monCoinBalance +
                    monCoinBid[userAddresses[i]][_cardIndex];
            }
        }
    }
}
