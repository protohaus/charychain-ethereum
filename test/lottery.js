const donationspool = artifacts.require("Spendenpool");
const charytoken = artifacts.require("CharyToken"); 
const lottery = artifacts.require("Lottery"); 

contract("test lottery function", (accounts) => {
    it("frovide donors and put into lottery", async () => {
        const CTcontract = await charytoken.deployed(); 
        const DPinstance = await donationspool.deployed(); 
        const Linstance = await lottery.deployed(); 
        const etheramount = web3.utils.toWei("0.2", "ether");
        await DPinstance.setCTaddress(CTcontract.address); 
        await CTcontract.transfer(DPinstance.address, "200"); 

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

        await DPinstance.initiateLottery(Linstance.address); 
        await DPinstance.startLottery(); 

        const Dpdonor = await DPinstance.donators.call(0); 
        const lotterydonors = await Linstance.donors.call(0); 
        assert.equal(Dpdonor.toString(), lotterydonors.toString(), "coppy successful"); 

        const Dpdonor3 = await DPinstance.donators.call(2); 
        const lotterydonors3 = await Linstance.donors.call(2); 
        assert.equal(Dpdonor3.toString(), lotterydonors3.toString(), "coppy successful"); 

    });
    it("get winner, send win and check 10%", async () => {
        const CTcontract = await charytoken.deployed(); 
        const DPinstance = await donationspool.deployed(); 
        const Linstance = await lottery.deployed(); 
        const etheramount = web3.utils.toWei("2", "ether");
        await DPinstance.setCTaddress(CTcontract.address); 
        await CTcontract.transfer(DPinstance.address, "200"); 

        await DPinstance.donate({
            from: accounts[1], 
            to: DPinstance.address,
            value: etheramount});
        
        await DPinstance.donate({
            from: accounts[2],
            to: DPinstance.address, 
            value: etheramount}); 
        
        await DPinstance.donate({
            from: accounts[6],
            to: DPinstance.address, 
            value: etheramount}); 

        //test if eth balance is right after donating and doing lottery
        await DPinstance.initiateLottery(Linstance.address); 
        await DPinstance.startLottery(); 
        await DPinstance.closeDonations(); 
        await DPinstance.doLottery(); 
        //const winner = await DPinstance.lotterywinner.call(); 
        //assert.equal(winner.toString(), accounts[6].toString(), "is account number"); 
        const contractbalance = await web3.eth.getBalance(DPinstance.address); 
        const contractbalanceineth = web3.utils.fromWei(contractbalance, 'ether');  
        assert.equal(contractbalanceineth.toString(), "6.6", "right balance"); 

        //get winner balance before transfer
        const lotterywinner = await DPinstance.lotterywinner.call(); 
        console.log("lotterywinner:" + lotterywinner); 
        const balance1 = await web3.eth.getBalance(lotterywinner);
        const balance1eth = web3.utils.fromWei(balance1, 'ether'); 
        console.log("balance1: " + balance1eth); 

        //test if amount is 10%
        await DPinstance.sendWinn(); 
        const lotterymoney = await DPinstance.lotterymoney.call(); 
        const lotterymoneyineth = web3.utils.fromWei(lotterymoney, 'ether'); 
        assert.equal(lotterymoneyineth.toString(), "0.66", "lottery is 10%"); 

        //test if balance changes to + lotterymoney
        const balance2 = await web3.eth.getBalance(lotterywinner); 
        const balance2eth = web3.utils.fromWei(balance2, 'ether'); 
        const addition = balance1 + lotterymoney; //addition does not work? 
        const additioneth = web3.utils.fromWei(addition, 'ether'); 
        console.log("balance2: " + balance2eth); 
        console.log("addition: " + additioneth); 
        assert.equal(addition.toString(), balance2.toString(), "transfer happened"); 
    }); 

}); 
