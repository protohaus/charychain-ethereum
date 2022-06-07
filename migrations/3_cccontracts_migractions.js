const Donationspool = artifacts.require("Spendenpool");
const Lottery = artifacts.require("Lottery");
const Voting = artifacts.require("Voting");

module.exports = function (deployer) {
  
  deployer.deploy(Donationspool); 
  deployer.deploy(Lottery); 
  deployer.deploy(Voting); 
};