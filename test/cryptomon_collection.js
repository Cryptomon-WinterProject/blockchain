const CryptomonCollection = artifacts.require("CryptomonCollection");

contract("CryptomonCollection", ([owner, alice, bob]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCollection.new({ from: owner });
  });

  it("should create a cryptomon collection", async () => {
    const names = ["Cryptomon1", "Cryptomon2", "Cryptomon3"];
    const types = "hello";
    const photos = ["photo1", "photo2", "photo3"];

    const results = await contractInstance.createMonCollection(types, {
      from: alice,
    });

    let mon = await contractInstance.monCollections(0);

    assert.equal(mon.names, "Cryptomon1");
    assert.equal(mon.images, "photo1");
    assert.equal(mon.monType, "hello");
  });
});
