const CryptomonCard = artifacts.require("CryptomonCard");

contract("CryptomonCard", ([owner, alice]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCard.new({ from: alice });
  });

  xit("should create a cryptomon card", async () => {
    const { logs } = await contractInstance.createCryptomonCard(0, {
      from: alice,
    });
    assert.equal(logs[0].args.owner, alice);
    assert.equal(logs[0].args.monIndex, 0);

    const getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.owner, alice);
    assert.equal(getMonCardById.monIndex, 0);
  });

  it("should increase XP, monLevel and evolve a cryptomon card", async () => {
    const names = ["pichu", "pikachu", "raichu"];
    const types = "hello";
    const photos = ["pichu", "pikachu", "raichu"];
    const prices = 23;
    const trainingRate = 20;
    await contractInstance.createMonCollection(
      names,
      photos,
      prices,
      types,
      trainingRate,
      {
        from: alice,
      }
    );

    await contractInstance.createCryptomonCard(0, {
      from: alice,
    });

    // For 3 evolutions cryptomon, 9th level will be on 1st evolution and 10th level will be on 2nd evolution

    let getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.evolution, 1);
    assert.equal(getMonCardById.monLevel, 1);
    assert.equal(getMonCardById.XP, 0);

    await contractInstance.increaseXP(0, 433, {
      from: alice,
    });

    getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.evolution, 1);
    assert.equal(getMonCardById.monLevel, 4);
    assert.equal(getMonCardById.XP, 73);
  });
});
