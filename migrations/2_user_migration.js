const Store = artifacts.require("Store");

module.exports = function (deployer) {
  deployer.deploy(Store, "0xC48E03A9e023b0b12173dAeE8E61e058062BC327");
};
