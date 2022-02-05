const Battle = artifacts.require("Battle");
const { soliditySha3 } = require("web3-utils");
const utils = require("./helpers/utils");

contract("Battle", function ([owner, alice, bob, joe]) {
  const monCollections = Array(5)
    .fill({})
    .map((_, i) => {
      return {
        names: [`Cryptomon${i}`, `Cryptomon${i}`, `Cryptomon${i}`],
        images: [`photo${i}`, `photo${i}`, `photo${i}`],
        prices: [i, i + 1, i + 2],
        monType: i,
        trainingRate: i * 20,
      };
    });

  beforeEach(async () => {
    contractInstance = await Battle.new({ from: owner });
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

    await contractInstance.updateUserConnectivityStatus(alice, true, {
      from: owner,
    });

    await contractInstance.createTestReadyUser("bob", {
      from: bob,
    });
    await contractInstance.updateUserConnectivityStatus(bob, true, {
      from: owner,
    });
  });

  context("challenge players", async () => {
    it("allows players to challenge ready players", async () => {
      const { logs } = await contractInstance.challenge(bob, [0, 1, 2], {
        from: alice,
      });

      console.log(logs[0].args);
      console.log(logs[0].args._monIds);

      assert.equal(logs[0].args._challenger, alice);
      assert.equal(logs[0].args._opponent, bob);
      // assert.equal(logs[0].args._monIds, [0, 1, 2]);

      const aliceObject = await contractInstance.users(alice);
      console.log(aliceObject);
      assert.equal(aliceObject.availableForChallenge, false);

      const challengeHash = soliditySha3(alice, bob);
      console.log(challengeHash);

      const challenge = await contractInstance.ongoingChallenges(challengeHash);
      console.log(challenge);
      assert.equal(challenge, true);

      const monsInBattle = await contractInstance.getMonsInBattle(
        challengeHash
      );
      console.log(monsInBattle);
      // assert.equal(monsInBattle.challengerMons, [0, 1, 2]);
    });

    it("does not allow challenging unverified or non-challengeReady players", async () => {
      await contractInstance.updateUserConnectivityStatus(alice, false, {
        from: owner,
      });

      await utils.shouldThrow(
        contractInstance.challenge(bob, [0, 1, 2], { from: alice })
      );

      await utils.shouldThrow(
        contractInstance.challenge(alice, [5, 6, 7], { from: bob })
      );

      await utils.shouldThrow(
        contractInstance.challenge(joe, [5, 6, 7], { from: bob })
      );

      await utils.shouldThrow(
        contractInstance.challenge(bob, [5, 6, 7], { from: joe })
      );
    });

    it("does not allow players to challenge with cryptoMons they don't own", async () => {
      await utils.shouldThrow(
        contractInstance.challenge(bob, [9, 8, 7], {
          from: alice,
        })
      );
    });
  });
});
