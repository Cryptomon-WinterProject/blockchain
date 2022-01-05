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

    const { logs } = await contractInstance.createMonCollection(
      names,
      photos,
      types,
      {
        from: ash,
      }
    );
    const getMonById = await contractInstance.getMonCollection(0);
    assert.equal(logs[0].args.names.length, names.length);
    assert.equal(logs[0].args.images.length, photos.length);
    assert.equal(logs[0].args.monType, types);
    assert.equal(getMonById.names.length, names.length);
    assert.equal(getMonById.images.length, photos.length);
    assert.equal(getMonById.monType, types);
  });
});
