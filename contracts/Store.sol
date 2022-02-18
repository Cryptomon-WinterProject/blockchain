// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Auction.sol";

contract Store is Auction {
    function buyCryptomons(uint256 _id, uint256 _price) public {
        require(users[msg.sender].monCoinBalance >= _price);
        createCryptomonCard(_id);
        users[msg.sender].monCoinBalance -= _price;
    }
}
