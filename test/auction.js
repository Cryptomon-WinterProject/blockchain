const Auction = artifacts.require("Auction");
const { shouldThrow, advanceTime } = require("./helpers/utils");

contract("Auction", function ([ownerAddress, alice, bob]) {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await Auction.new({ from: ownerAddress });
    await contractInstance.addToAuction(1, 1, { from: alice });
  });

  it("should bid", async () => {
    const { logs } = await contractInstance.bid(1, { from: bob, value: 2 });

    assert.equal(logs[0].args._itemId, 1);
    assert.equal(logs[0].args._bidder, bob);
    assert.equal(logs[0].args._bid, 2);

    const item = await contractInstance.items(1);
    assert.equal(item.highestBid, 2);
    assert.equal(item.highestBidder, bob);
  });

  it("shouldn't allow bidding for lower than current highest bid", async () => {
    await shouldThrow(contractInstance.bid(1, { from: bob, value: 0.5 }));
  });

  it("shouldn't allow bidding after end time", async () => {
    await advanceTime(2 * 24 * 60 * 60);
    await shouldThrow(contractInstance.bid(0, { from: bob, value: 2 }));
  });
});
