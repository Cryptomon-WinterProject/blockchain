const CryptomonCollection = artifacts.require("CryptomonCollection");

contract("CryptomonCollection", ([owner, alice, bob, ash]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCollection.new({ from: bob });
  });

  it("should create a cryptomon collection", async () => {
    const names = ["Cryptomon1", "Cryptomon2", "Cryptomon3"];
    const types = "hello";
    const photos = ["photo1", "photo2", "photo3"];

    const results = await contractInstance.createMonCollection(
      names,
      photos,
      types,
      {
        from: ash,
      }
    );

    let mon = await contractInstance.monCollections(0);
    const results2 = await contractInstance.getMonCollection(0);
    console.log(results2);
    // console.log(results.logs[0].args);
    // assert.equal(mon.names, "Cryptomon1");
    // assert.equal(mon.images, "photo1");
    // assert.equal(mon.monType, "hello");
  });
});
