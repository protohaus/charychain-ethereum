const { assert } = require("console");
const { it } = require("ethers/wordlists");

const charytoken = artifacts.require("CharyToken"); 

contract("CharyToken test", accounts => {
    it("should have total supply", () =>
        charytoken.deployed()
            .then(instance => instance.totalSupply.call())
            .then(balance => {
                assert.equal(
                    balance.valueOf(),
                    10000000000000000000000,
                    "not enogh supply"
                );  
            })); 
}); 