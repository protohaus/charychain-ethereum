const donationspool = artifacts.require("Spendenpool");
const charytoken = artifacts.require("CharyToken"); 
const voting = artifacts.require("Voting"); 

contract("function donate() test", (accounts) => {
    it("account donates ether", async () => {
        const CTcontract = await charytoken.deployed(); 
        const instance = await donationspool.deployed(); 
        const amount = 200; 
        const etheramount = web3.utils.toWei("0.2", "ether");
        await instance.setCTaddress(CTcontract.address); 
        await CTcontract.transfer(instance.address, "200"); 
        //const sender = await accounts[3].address; 
        await instance.donate({
            from: accounts[1], 
            to: instance.address,
            value: etheramount}); //menge ether? 
        const donor = await instance.donators.call(0);
        assert.equal(accounts[1].toString(), donor.toString(), "account equals donor"); 
        
        const CTbalance = await CTcontract.balanceOf.call(accounts[1]); 
        assert.equal(CTbalance.toString(), "1", "CT was succesfully transferred"); 

        const contractbalanceether = await instance.getBalance.call(); 
        assert.equal(contractbalanceether.toString(), etheramount.toString(), "ether balance right"); 

        const contractbalanceCT = await instance.getCTBalance.call(); 
        assert.equal(contractbalanceCT.toString(), "199", "CT subtracted from contractbalance"); 
    });
    it("initiate Voting and set Voting IDs", async() => {
        const Vinstance = await voting.deployed(); 
        const setprojects = await Vinstance.setProjectIds([2,4,6,8]); 

        const projectid = await Vinstance.projectids.call(0); 
        assert.equal(projectid.toString(), "2", "got the right id"); 

        const projectid2 = await Vinstance.projectids.call(1); 
        assert.equal(projectid2.toString(), "4"); 

        const projectidvalue = await Vinstance.votesofprojects.call("2"); 
        assert.equal(projectidvalue.toString(), "0", "votes is zero"); 

    });
    it("initiate & update Voting", async () => {
        const CTcontract = await charytoken.deployed();
        const DPinstance = await donationspool.deployed();
        const Vinstance = await voting.deployed(); 
        await Vinstance.setProjectIds([2,4,6,8]); 

        const etheramount = web3.utils.toWei("0.2", "ether");
        await DPinstance.setCTaddress(CTcontract.address); 
        await CTcontract.transfer(DPinstance.address, "200");

        await DPinstance.donate({
            from: accounts[2], 
            to: DPinstance.address,
            value: etheramount}); //menge ether? 

        await DPinstance.initiateVoting(Vinstance.address); 
        await Vinstance.emptyBallot.call(); 
        await Vinstance.setCTaddress(CTcontract.address); 

        await Vinstance.receiveVote(2, {
            from: accounts[2],
        }); 

        const updatedvoting = await Vinstance.votesofprojects.call("2"); 
        assert.equal(updatedvoting.toString(), "1", "vote was updated"); 

        const voter = await Vinstance.donators.call(0); 
        assert.equal(voter.toString(), accounts[2].toString(), "voter was registered"); 

    }); 
    it("get voters from array, show current votes and return Voting winner", async () => {
        const CTcontract2 = await charytoken.deployed();
        const DPinstance = await donationspool.deployed();
        const Vinstance = await voting.deployed(); 
        await Vinstance.setProjectIds([2,4,6,8]); 

        const etheramount = web3.utils.toWei("0.2", "ether");
        await DPinstance.setCTaddress(CTcontract2.address); 
        await CTcontract2.transfer(DPinstance.address, "200");

        await DPinstance.donate({
            from: accounts[5], 
            to: DPinstance.address,
            value: etheramount});
        
        await DPinstance.donate({
            from: accounts[3],
            to: DPinstance.address, 
            value: etheramount}); 
        
        await DPinstance.donate({
            from: accounts[4],
            to: DPinstance.address, 
            value: etheramount}); 
        
        await DPinstance.initiateVoting(Vinstance.address); 
        await Vinstance.emptyBallot.call(); 
        await Vinstance.setCTaddress(CTcontract2.address); 

        await Vinstance.receiveVote(2, {
            from: accounts[5],
        }); 

        await Vinstance.receiveVote(2, {
            from: accounts[3],
        }); 

        await Vinstance.receiveVote(4, {
            from: accounts[4],
        }); 

        const donors = await Vinstance.getVoters.call(); 
        assert.equal(donors[0].toString(), accounts[2].toString(), "dondor 1 right");

        assert.equal(donors[1].toString(), accounts[5].toString(), "dondor 2 right");

        assert.equal(donors[2].toString(), accounts[3].toString(), "dondor 3 right");

        const currentvoting = await Vinstance.showcurrentVotes.call(2); 
        assert.equal(currentvoting.toString(), "2", "Voting updated successfully"); 
        
        const currentvoting2 = await Vinstance.showcurrentVotes.call(4); 
        assert.equal(currentvoting2.toString(), "1", "Voting updated successfully"); 
 
        const winnerproject = await Vinstance.returnVotingWinner.call();  
        assert.equal(winnerproject.toString(), "2", "Winnerid is right"); 
    }); 
    
});