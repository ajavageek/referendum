var referendum = artifacts.require("ReferendumContract");
var token = artifacts.require("VotingToken");

module.exports = (deployer) => {
  deployer.deploy(token, "DUMMY", 5).then(() => {
    deployer.deploy(referendum, "Are you ok?", 6, token.address);
  });
};
