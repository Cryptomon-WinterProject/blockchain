const CryptomonCollection = artifacts.require("CryptomonCollection");

contract("CryptomonCollection", ([owner, alice, bob, ash]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCollection.new({ from: ash });
  });

  xit("should create a cryptomon collection", async () => {
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

  xit("should edit a cryptomon collection", async () => {
    let names = ["Cryptomon1", "Cryptomon2", "Cryptomon3"];
    const types = "hello";
    let photos = ["photo1", "photo2", "photo3"];

    await contractInstance.createMonCollection(names, photos, types, {
      from: ash,
    });

    names[0] = "Cryptomon4";
    photos[0] = "photo4";

    const getMonById = await contractInstance.getMonCollection(0);
    assert.equal(getMonById.names[0], "Cryptomon1");
    assert.equal(getMonById.images[0], "photo1");
    assert.equal(getMonById.monType, types);

    await contractInstance.editMonCollection(names, photos, types, 0, {
      from: ash,
    });

    const getUpdatedMonById = await contractInstance.getMonCollection(0);
    assert.equal(getUpdatedMonById.names[0], "Cryptomon4");
    assert.equal(getUpdatedMonById.images[0], "photo4");
    assert.equal(getUpdatedMonById.monType, types);
  });

  it("should delete a cryptomon collection", async () => {
    let names = ["Cryptomon1", "Cryptomon2", "Cryptomon3"];
    const types = "hello";
    let photos = ["photo1", "photo2", "photo3"];

    for (let i = 0; i < 2; i++) {
      await contractInstance.createMonCollection(names, photos, `${i}`, {
        from: ash,
      });
    }

    let monCollectionsLength = await contractInstance.getMonCollectionCount();
    assert.equal(monCollectionsLength, 2);

    await contractInstance.deleteMonCollection(1, {
      from: ash,
    });

    monCollectionsLength = await contractInstance.getMonCollectionCount();
    assert.equal(monCollectionsLength, 1);
  });
});
