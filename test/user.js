const User = artifacts.require("User");

contract("Battle", function ([owner, alice, bob]) {
  const monCollections = Array(5)
    .fill({})
    .map((_, i) => {
      return {
        names: [`Cryptomon${i}`, `Cryptomon${i}`, `Cryptomon${i}`],
        images: [`photo${i}`, `photo${i}`, `photo${i}`],
        monType: i,
      };
    });

  beforeEach(async () => {
    contractInstance = await User.new({ from: owner });
    for (let i = 0; i < monCollections.length; i++) {
      await contractInstance.createMonCollection(
        monCollections[i].names,
        monCollections[i].images,
        monCollections[i].monType,
        {
          from: owner,
        }
      );
    }

    await contractInstance.createTestReadyUser("alice", {
      from: alice,
    });
  });
  it("owner should be able update connectivity status of users ", async () => {
    const aliceObj = await contractInstance.users(alice);
    console.log(aliceObj.online);
    assert.equal(aliceObj.online, false);

    await contractInstance.updateUserConnectivityStatus(alice, true, {
      from: owner,
    });

    const updatedAliceObj = await contractInstance.users(alice);
    console.log(updatedAliceObj.online);
    assert.equal(updatedAliceObj.online, true);
  });

  it("should be able to get the online users data", async () => {
    await contractInstance.updateUserConnectivityStatus(alice, true, {
      from: owner,
    });
    const onlinePlayers = await contractInstance.getOnlinePlayers();
    console.log(onlinePlayers);
    assert.equal(onlinePlayers.length, 1);
    assert.equal(onlinePlayers[0], alice);
  });
});
