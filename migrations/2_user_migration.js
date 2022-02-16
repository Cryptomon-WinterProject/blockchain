const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
  deployer.deploy(Auction, "0xB46233500f2eDEaba24674e0714D344C08916ec2");
};
