const auction = artifacts.require("auction");

contract("auction", function (/* accounts */) {
  it("should assert true", async function () {
    await auction.deployed();
    return assert.isTrue(true);
  });
});
