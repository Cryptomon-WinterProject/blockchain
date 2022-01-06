const auction_mons = artifacts.require("AuctionMons");

contract("auction_mons", function ([owner, alice, bob]) {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await auction_mons.new({ from: owner });
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
});
