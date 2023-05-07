var bank = artifacts.require("bank");
module.exports = function(deployer) {
    deployer.deploy(bank)
}