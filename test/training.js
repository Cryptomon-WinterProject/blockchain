const Training = artifacts.require("Training");

contract("Training", ([owner, alice, bob, ash]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await Training.new({ from: alice });
  });

  it("XP will increase on training", async () => {
    const names = ["pichu", "pikachu", "raichu"];
    const types = "hello";
    const photos = ["pichu", "pikachu", "raichu"];
    const trainingRate = 20;
    await contractInstance.createMonCollection(names, photos, types, 30, {
      from: alice,
    });

    await contractInstance.createCryptomonCard(0, {
      from: alice,
    });

    let getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.XP, 0);

    await contractInstance.trainCryptomon(0, 109, 29, { from: alice });

    getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.XP, 97);
    assert.equal(getMonCardById.readyTime > Date.now() / 1000 + 6600, false);
  });
});
