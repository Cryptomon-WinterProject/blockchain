const User = artifacts.require("User");

contract("Battle", function ([owner, alice, bob]) {
  let contractInstance;
  const monCollections = Array(5)
    .fill({})
    .map((_, i) => {
      return {
        names: [`Cryptomon${i}`, `Cryptomon${i}`, `Cryptomon${i}`],
        images: [`photo${i}`, `photo${i}`, `photo${i}`],
        monType: i,
        prices: [i, i + 1, i + 2],
        trainingRate: i * 20,
      };
    });

  beforeEach(async () => {
    contractInstance = await User.new({ from: owner });
    for (let i = 0; i < monCollections.length; i++) {
      await contractInstance.createMonCollection(
        monCollections[i].names,
        monCollections[i].images,
        monCollections[i].prices,
        monCollections[i].monType,
        monCollections[i].trainingRate,
        {
          from: owner,
        }
      );
    }

    await contractInstance.createTestReadyUser("alice", {
      from: alice,
    });
  });
  xit("owner should be able update connectivity status of users ", async () => {
    const aliceObj = await contractInstance.users(alice);
    console.log(aliceObj.availableForChallenge);
    assert.equal(aliceObj.availableForChallenge, false);

    await contractInstance.updateUserConnectivityStatus(alice, true, {
      from: owner,
    });

    const updatedAliceObj = await contractInstance.users(alice);
    console.log(updatedAliceObj.availableForChallenge);
    assert.equal(updatedAliceObj.availableForChallenge, true);
  });

  xit("should be able to get the available users for challenge", async () => {
    await contractInstance.updateUserConnectivityStatus(alice, true, {
      from: owner,
    });
    const onlinePlayers = await contractInstance.getOnlinePlayers();
    console.log(onlinePlayers);
    assert.equal(onlinePlayers.length, 1);
    assert.equal(onlinePlayers[0], alice);
  });

  it("should be able to fetch his cards", async () => {
    const userCards = await contractInstance.getUserCards({
      from: alice,
    });
    console.log(userCards);
  });
});
