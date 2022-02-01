// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AuctionMons.sol";

contract Auction is AuctionMons {
    mapping(address => uint256) monCoinBid;
    address CardOwner;

    event NewBid(uint256 _cardIndex, address _bidder, uint256 _bidAmount);

    function bid(uint256 _cardIndex) public payable beforeEndTime {
        require(
            monCoinBid[msg.sender] + msg.value >
                auctionCards[_cardIndex].highestBid &&
                users[msg.sender].monCoinBalance >= msg.value
        );
        auctionCards[_cardIndex].highestBidder = msg.sender;
        auctionCards[_cardIndex].highestBid =
            monCoinBid[msg.sender] +
            msg.value;
        monCoinBid[msg.sender] += msg.value;

        emit NewBid(_cardIndex, msg.sender, msg.value);
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
