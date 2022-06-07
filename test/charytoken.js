
const charytoken = artifacts.require("CharyToken"); 
const donationspool = artifacts.require("Spendenpool"); 

contract("CharyToken test", (accounts) => {
    it("should get the Balance of CT of this contract", async () => {
        const instance = await charytoken.deployed(); 
        const ctbalance = await instance.totalSupply.call(); 
        assert.equal(ctbalance.valueOf(), 10000000000000000000000);
    }); 
    it("should account0 should be admin of this contract", async () => {
        const instance = await charytoken.deployed();
        const admin = await instance.admin(); 
        assert.equal(admin, accounts[0], "admin of contract = first ganache account"); 
    });
    it("transfer 200 CT to donationspool contract", async () => {
        const instanceCT = await charytoken.deployed(); 
        const instanceDP = await donationspool.deployed(); 
        const amount = 200; 
        await instanceDP.setCTaddress(instanceCT.address); 
        await instanceCT.transfer(instanceDP.address, "200");
        /*const ctbalance = await instanceCT.balanceOf.call(instanceCT.address); 
        const tempbalance = 10000000000000000000000 - amount; 
        assert.equal(ctbalance.toString(), tempbalance.toString()); */
        const DPbalance = await instanceCT.balanceOf.call(instanceDP.address); 
        assert.equal(DPbalance.toString(), amount.toString(), "balance equal"); 
    }); 
    it("send CT to account and check balance", async () => {
        const instanceCT = await charytoken.deployed();  
        await instanceCT.transfer(accounts[1], 200); 
        const accountbalance = await instanceCT.balanceOf.call(accounts[1]); 
        assert.equal(accountbalance.toString(), "200", "transfer works with accounts"); 
    }); 
}); 