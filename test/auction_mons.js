const AuctionMons = artifacts.require("AuctionMons");

contract("AuctionMons", function ([owner, alice, bob]) {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await AuctionMons.new({ from: alice });
  });

  it("should add cards in auctions", async () => {
    await contractInstance.createCryptomonCard(0, { from: alice });
    const { logs } = await contractInstance.addToAuction(0, 1, { from: alice });
    assert.equal(logs[0].args._cardIndex, 0);
    assert.equal(logs[0].args._minAmount, 1);
  });
  it("should list items", async () => {
    await contractInstance.createCryptomonCard(0, { from: alice });
    await contractInstance.createCryptomonCard(1, { from: bob });
    await contractInstance.addToAuction(0, 1, { from: alice });
    await contractInstance.addToAuction(1, 2, { from: bob });

    const items = await contractInstance.auctionCart({ from: alice });
    assert.equal(items.length, 2);
  });
  xit("should not bid justn after purchasing", async () => {
    await contractInstance.createCryptomonCard(0, { from: alice });
    await contractInstance.createCryptomonCard(1, { from: bob });
    await contractInstance.addToAuction(0, 1, { from: alice });
    await contractInstance.addToAuction(1, 2, { from: bob });

    // await contractInstance.purchase(0, { from: alice, value: 1 });
    await shouldThrow(contractInstance.bid(0, { from: bob, value: 2 }));
  });
});
