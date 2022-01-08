const AuctionMons = artifacts.require("AuctionMons");

contract("AuctionMons", function ([owner, alice, bob]) {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await AuctionMons.new({ from: owner });
  });

  it("should add cards in auctions", async () => {
    const { logs } = await contractInstance.addToAuction(0, 1, { from: alice });
    assert.equal(logs[0].args._cardIndex, 0);
    assert.equal(logs[0].args._minAmount, 1);
    // const auctionCards = await contractInstance.auctionCards(0);
    // assert.equal(auctionCards._cryptomonCardIndex, 0);
    // assert.equal(auctionCards_minAmount, 1);

    const owner = await contractInstance.cardToOwner(0);
    assert.equal(owner, alice);
  });
  it("should list items", async () => {
    await contractInstance.addToAuction(0, 1, { from: alice });
    await contractInstance.addToAuction(1, 2, { from: bob });

    const items = await contractInstance.auctionCart({ from: alice });
    assert.equal(items.length, 2);
  });
});
