// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./CryptomonCard.sol";

contract AuctionMons is CryptomonCard {
    uint256 public endTime = block.timestamp + 1 days;

    struct AuctionCard {
        uint256 cryptomonCardIndex;
        uint256 minAmount;
        uint256 highestBid;
        address highestBidder;
    }
    AuctionCard[] public auctionCards;

    modifier beforeEndTime() {
        require(block.timestamp < endTime);
        _;
    }
    mapping(address => uint256) public ownerCardIndex;
    mapping(uint256 => address) public cardToOwner;

    //  Cryptomon public card1 = cryptomons[auctionCards[0].cryptomonCardIndex];
    event AuctionCreated(uint256 _cardIndex, uint256 _minAmount);

    function addToAuction(uint256 _cryptomonCardIndex, uint256 _minAmount)
        public
        beforeEndTime
    {
        auctionCards.push(
            AuctionCard(_cryptomonCardIndex, _minAmount, 0, address(0))
        );
        ownerCardIndex[msg.sender] = _cryptomonCardIndex;
        cardToOwner[_cryptomonCardIndex] = msg.sender;
        emit AuctionCreated(_cryptomonCardIndex, _minAmount);
    }
}
