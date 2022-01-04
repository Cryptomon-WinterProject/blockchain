const CryptomonCollection = artifacts.require("CryptomonCollection");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CryptomonCollection", function (/* accounts */) {
  it("should assert true", async function () {
    await CryptomonCollection.deployed();
    return assert.isTrue(true);
  });
});
