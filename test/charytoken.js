const { assert } = require("console");
const { it } = require("ethers/wordlists");

const charytoken = artifacts.require("CharyToken"); 

contract("CharyToken test", (accounts) => {
    it("should get the Balance of CT of this contract", async () => {
        const instance = await charytoken.deployed(); 
        const ctbalance = await instance.totalSupply.call(); 
        assert.equal(ctbalance.valueOf(), 10000000000000000000000);
    }); 
}); 