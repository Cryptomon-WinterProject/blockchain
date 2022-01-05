const CryptomonCard = artifacts.require("CryptomonCard");

contract("CryptomonCard", ([owner, alice]) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptomonCard.new({ from: alice });
  });

  it("should create a cryptomon card", async () => {
    const { logs } = await contractInstance.createCryptomonCard(0, {
      from: alice,
    });
    assert.equal(logs[0].args.owner, alice);
    assert.equal(logs[0].args.monIndex, 0);

    const getMonCardById = await contractInstance.getCryptomonCard(0);
    assert.equal(getMonCardById.owner, alice);
    assert.equal(getMonCardById.monIndex, 0);
  });
});
