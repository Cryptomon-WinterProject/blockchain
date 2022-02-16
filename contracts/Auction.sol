// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AuctionMons.sol";

contract Auction is AuctionMons {
    mapping(address => uint256) public monCoinBid;
    address CardOwner;

    event NewBid(uint256 _cardIndex, address _bidder, uint256 _bidAmount);

    function bid(uint256 _cardIndex, uint256 monCoins) public beforeEndTime {
        require(
            monCoinBid[msg.sender] + monCoins >
                auctionCards[_cardIndex].highestBid &&
                users[msg.sender].monCoinBalance >= monCoins
        );
        auctionCards[_cardIndex].highestBidder = msg.sender;
        auctionCards[_cardIndex].highestBid = monCoinBid[msg.sender] + monCoins;
        monCoinBid[msg.sender] += monCoins;

        emit NewBid(_cardIndex, msg.sender, monCoins);
    }

    function transferAuctionAmount(address _to, address _from) public {
        require(
            monCoinBid[_from] <= users[_from].monCoinBalance &&
                monCoinBid[_from] > 0
        );
        users[_to].monCoinBalance += monCoinBid[_from];
        users[_from].monCoinBalance -= monCoinBid[_from];
        monCoinBid[_from] = 0;
    }
}
