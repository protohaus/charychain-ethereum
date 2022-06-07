const donationspool = artifacts.require("Spendenpool");
const charytoken = artifacts.require("CharyToken"); 
const voting = artifacts.require("Voting"); 

contract("test voting from DP", (accounts) => {
    it("donate and compare votes", async () => {
        //test vorbereitung
        const CTcontract = await charytoken.deployed(); 
        const DPinstance = await donationspool.deployed();
        const Vinstance = await voting.deployed();  
        await DPinstance.setCTaddress(CTcontract.address); 
        await CTcontract.transfer(DPinstance.address, "200");
        const etheramount = web3.utils.toWei("0.2", "ether");
        await DPinstance.initiateVoting(Vinstance.address); 
        await DPinstance.setVotingProjectIds([2,4,6,8]);
        //three accounts donate
        await DPinstance.donate({
            from: accounts[2], 
            to: DPinstance.address,
            value: etheramount});
        
        //set approvin for account of donor (how in contract??)
        await CTcontract.approve(DPinstance.address, 1, {
            from: accounts[2], 
        }); 
        
        await DPinstance.donate({
            from: accounts[3],
            to: DPinstance.address, 
            value: etheramount}); 
        
        await CTcontract.approve(DPinstance.address, 1, {
            from: accounts[3], 
        }); 
        
        await DPinstance.donate({
            from: accounts[4],
            to: DPinstance.address, 
            value: etheramount}); 
        
        await CTcontract.approve(DPinstance.address, 1, {
            from: accounts[4], 
        }); 
        //three accounts vote 
        await DPinstance.doVoting(4, {
            from: accounts[2],
        }); 
        await DPinstance.doVoting(4, {
            from: accounts[3],
        }); 
        await DPinstance.doVoting(2, {
            from: accounts[4],
        }); 

        //check votingupdated
        const vote2 = await DPinstance.getcurrentVote.call(2); 
        assert.equal(vote2.toString(), "1", "voting from Dp works"); 
        //check right winner
        const votingwinner = await DPinstance.votingresult.call(); 
        assert.equal(votingwinner.toString(), "4", "returned right winner");
        //check right voters
        await DPinstance.updateVoting(); 
        const voter1 = await DPinstance.voters.call(0); 
        assert.equal(voter1.toString(), accounts[2].toString(), "same address");
        const voter2 = await DPinstance.voters.call(1); 
        assert.equal(voter2.toString(), accounts[3].toString(), "same address");
        const voter3 = await DPinstance.voters.call(2); 
        assert.equal(voter3.toString(), accounts[4].toString(), "same address");

        //check if CTs are back to 0 for voters
        const ct1 = await CTcontract.balanceOf.call(voter1); 
        assert.equal(ct1.toString(), "0", "Ct was reverted to 0"); 

    });
});