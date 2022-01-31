const Auction = artifacts.require("Auction");
const { shouldThrow, advanceTime } = require("./helpers/utils");

contract("Auction", function ([winnerAddress, alice, bob]) {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await Auction.new({ from: winnerAddress });
    await contractInstance.addToAuction(1, 1, { from: alice });
  });

  it("should allow bid", async () => {
    const { logs } = await contractInstance.bid(1, { from: bob, value: 2 });
    // console.log(logs[0].args);
    assert.equal(logs[0].args._cardIndex, 1);
    assert.equal(logs[0].args._bidder, bob);
    assert.equal(logs[0].args._bidAmount, 2);

    const auctionCard = await contractInstance.auctionCards(1);
    assert.equal(auctionCard.highestBid, 2);
    assert.equal(auctionCard.highestBidder, bob);
  });

  xit("shouldn't allow bidding for lower than current highest bid", async () => {
    await shouldThrow(contractInstance.bid(1, { from: bob, value: 0.5 }));
  });

  xit("shouldn't allow bidding after end time", async () => {
    await advanceTime(2 * 24 * 60 * 60);
    await shouldThrow(contractInstance.bid(0, { from: bob, value: 2 }));
  });
});
