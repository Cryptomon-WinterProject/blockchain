// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AuctionMons.sol";

contract Auction is AuctionMons {
    mapping(address => uint256) MonCoins;
    address cardOwner;

    event NewBid(uint256 _cardIndex, address _bidder, uint256 _bidAmount);

    function bid(uint256 _cardIndex) public payable beforeEndTime {
        require(
            MonCoins[msg.sender] + msg.value >
                auctionCards[_cardIndex].highestBid
        );
        auctionCards[_cardIndex].highestBidder = msg.sender;
        auctionCards[_cardIndex].highestBid = MonCoins[msg.sender] + msg.value;
        MonCoins[msg.sender] += msg.value;

        emit NewBid(_cardIndex, msg.sender, msg.value);
    }
}
