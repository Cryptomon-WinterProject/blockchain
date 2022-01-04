const CryptomonCollection = artifacts.require("CryptomonCollection");

contract("CryptomonCollection", ([owner, alice, bob]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCollection.new({ from: owner });
  });

  it("should create a cryptomon collection", async () => {
    const names = ["alice", "bob", "charlie"];
    const types = "fire";
    const photos = ["photo1", "photo2", "photo3"];

    const results = await contractInstance.createMonCollection(
      names,
      photos,
      types,
      { from: alice }
    );

    // assert.equal(results.name.length, 3);
  });
});
