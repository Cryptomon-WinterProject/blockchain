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
        uint256 monId;
        bool isSold;
    }

    AuctionCard[] public auctionCards;

    modifier beforeEndTime() {
        require(block.timestamp < endTime);
        _;
    }

    function getAuctionCard() public view returns (AuctionCard[] memory) {
        return auctionCards;
    }

    event AuctionCreated(uint256 _cardIndex, uint256 _minAmount);

    function addToAuction(uint256 _cryptomonCardIndex, uint256 _minAmount)
        public
    {
        AuctionCard memory auctionCard = AuctionCard(
            _minAmount,
            0,
            address(0),
            _cryptomonCardIndex,
            false
        );
        auctionCards.push(auctionCard);
        cryptomons[_cryptomonCardIndex].readyTime = uint32(
            block.timestamp + (60 * 60 * 24)
        );
        emit AuctionCreated(_cryptomonCardIndex, _minAmount);
    }
}
