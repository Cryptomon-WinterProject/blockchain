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
                auctionCards[_cardIndex].highestBid
        );
        auctionCards[_cardIndex].highestBidder = msg.sender;
        auctionCards[_cardIndex].highestBid =
            monCoinBid[msg.sender] +
            msg.value;
        monCoinBid[msg.sender] += msg.value;

        emit NewBid(_cardIndex, msg.sender, msg.value);
    }

    function getBidAmount(uint256 amount) public payable {
        require(msg.value == amount);
    }

    function storeBidAmount() public payable {
        address payable add1 = payable(msg.sender);
        add1.transfer(address(this).balance);
    }
}
