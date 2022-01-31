// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Battle.sol";

contract AuctionMons is Battle {
    uint256 public endTime = block.timestamp + 1 days;

    struct AuctionCard {
        uint256 minAmount;
        uint256 highestBid;
        address highestBidder;
    }

    mapping(uint256 => AuctionCard) public auctionCards;

    modifier beforeEndTime() {
        require(block.timestamp < endTime);
        _;
    }

    //  Cryptomon public card1 = cryptomons[auctionCards[0].cryptomonCardIndex];
    event AuctionCreated(uint256 _cardIndex, uint256 _minAmount);

    function addToAuction(uint256 _cryptomonCardIndex, uint256 _minAmount)
        public
        beforeEndTime
    {
        AuctionCard memory auctionCard = AuctionCard(_minAmount, 0, address(0));
        auctionCards[_cryptomonCardIndex] = auctionCard;
        emit AuctionCreated(_cryptomonCardIndex, _minAmount);
    }
}
