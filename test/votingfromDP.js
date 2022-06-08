const donationspool = artifacts.require("Spendenpool");
const charytoken = artifacts.require("CharyToken"); 
const voting = artifacts.require("Voting"); 
const lottery = artifacts.require("Lottery"); 

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
        
        await DPinstance.donate({
            from: accounts[3],
            to: DPinstance.address, 
            value: etheramount}); 
    
        await DPinstance.donate({
            from: accounts[4],
            to: DPinstance.address, 
            value: etheramount}); 
       
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
    it("lottery from DP", async () => {
        const CTcontract = await charytoken.deployed(); 
        const DPinstance = await donationspool.deployed();
        const Vinstance = await voting.deployed();
        const Linstance = await lottery.deployed(); 

        const donor1 = await DPinstance.donators.call(0); 
        assert.equal(donor1.toString(), accounts[2]); 
        await DPinstance.initiateLottery(Linstance.address); 
        await DPinstance.startLottery();
        await DPinstance.closeDonations(); 
        await DPinstance.doLottery(); 

        //check balance 
        const contractbalance = await web3.eth.getBalance(DPinstance.address); 
        const contractbalanceineth = web3.utils.fromWei(contractbalance, 'ether');  
        assert.equal(contractbalanceineth.toString(), "0.6", "right balance"); 

        //get winner
        const lotterywinner = await DPinstance.lotterywinner.call(); 
        await DPinstance.sendWinn(); 

        //test if random number is within array length
        const arraylength = await Linstance.getSize.call();
        const winnerint = await Linstance.numberwinner.call(); 
        if (winnerint > arraylength){
            throw new Error("random in is too big for donors array"); 
        }; 
        if (winnerint < 0){
            throw new Error("random can not be negative"); 
        };
    })
});