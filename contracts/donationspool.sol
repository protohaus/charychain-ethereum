// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./IVoting.sol"; 
import "./ILottery.sol"; 
//Main contract to handle other contracts for all donations-service functions 
contract Spendenpool{
    //variables 
    address public charyteam; 
    address[] public donators;
    address[] public voters; //temporary to chekc if working
    address payable[] public projects; 
    address public votingcontract; 
    address public lotterycontract; 
    address public ctcontract; 
    address payable public lotterywinner; 
    uint donations; 
    bool donationsopen = true; 
    uint public startTime = block.timestamp;
    uint public lotterymoney; 

    

    //constructor 
    //deployer of contract = charyteam
    //give relevant projects for this timeintervall with constructor 
    constructor () public {
        charyteam = msg.sender; 
    }

    //modifier
    //1. donations are being collected = it can be voted, when not -> Lottery starts
    modifier donationsclosed(){
        require(donationsopen == false, "Spenden werden nicht mehr gesammelt"); 
        _; 
    }

    //only charyteam can do something
    modifier onlyCharyteam(){
        require(msg.sender == charyteam, "only CharyTeam can call this function"); 
        _;
    }

    //events to the frontend, not included in this implementation
    //event Donator donated (adrdess, uint amount); 


    //functions 
    //initiate Voting, should be immediatley because voting runs parallel to donations 
    function initiateVoting(address _votingAddress) external {
        //initiate voting with this address
        votingcontract = _votingAddress; 
    }
    //set lottery contract to access its functions
    function initiateLottery(address _lotteryContract) external {
        lotterycontract = _lotteryContract; 
    }
    //set CT contract to access its functions
    function setCTaddress(address _CTContract) external {
        ctcontract = _CTContract; 
    }
    
    function setVotingProjectIds(uint[] memory _projectids) external returns(bool){
        IVoting v = IVoting(votingcontract); 
        return v.setProjectIds(_projectids);
    }


    //donations of donators 
    function donate() external payable {
        //minimum value? 
        require(msg.value >= 0.00000001 ether, "Invest minimum of 0.1 ether");
        //keeping track of the Donators 
        donators.push(msg.sender); 
        sendCT(msg.sender); 
        IERC20(ctcontract).approve(address(this), 1); 
    }


    function updateVoting() public returns(bool){
        //update number of donators (or off-chain)? 
        IVoting v = IVoting(votingcontract); 
        voters = v.getVoters(); //wo speichern 
        return true;  
    }

    //getbalance 
    function getBalance() public view returns(uint) {
        // everyone can see balance 
        return address(this).balance; 
    }

    
    //getbalance of CT in this contract, careful contract address changes when deploying!! 
    function getCTBalance() public view onlyCharyteam returns(uint) {
        return IERC20(ctcontract).balanceOf(address(this));
    }
    

    //send charity token to donator after donation 
    function sendCT(address _donor) payable public {
        //require balance CT = 0 
        uint tempCT = IERC20(ctcontract).balanceOf(_donor);
        require(tempCT == 0, "sender already has a CT"); 
        IERC20(ctcontract).transfer(_donor, 1); 
    }

    //do a Vote for a Project id
    function doVoting(uint _idProject) public returns(bool) {
        IVoting v = IVoting(votingcontract);
        uint tempCTbalance = IERC20(ctcontract).balanceOf(msg.sender); 
        require (tempCTbalance == 1, "donator has no CT, no voting possible");
        v.doVote(_idProject, msg.sender); 
        retreiveCT(msg.sender);
        return true; 
    }

    function retreiveCT(address _voter) payable public {
        uint tempCT = IERC20(ctcontract).balanceOf(_voter);
        require (tempCT == 1, "sender has no CT, no retreiving"); 
        IERC20(ctcontract).transferFrom(_voter, address(this), 1); 
    }

    function getcurrentVote(uint _idProject) public returns(uint) {
        IVoting v = IVoting(votingcontract); //kann ich auch einmalig im constructor Voting mahcne? 
        return v.showcurrentVotes(_idProject); 
    }

    //after 3month close donations  
    function closeDonations() public {
        //if (donationsopen == true && block.timestamp >= startTime + 30 days) donationsopen = false; 
        donationsopen = false; 
    }

    //get result of voting //after donations are closed
    function votingresult() public returns (uint) {
        IVoting v = IVoting(votingcontract); 
        v.returnVotingWinner(); 
        return v.getVotingWinner(); 
    }

    function startLottery() public {
        ILottery l = ILottery(lotterycontract); 
        l.enterLottery(donators);
    }

    //gives donors in array to lottery contract and returns the random winner of the donors 
    function doLottery() payable public donationsclosed returns(address) {
        ILottery l = ILottery(lotterycontract); 
        //l.enterLottery(donators);
        lotterywinner = payable(l.getWinner()); 
        return lotterywinner; 
        //initialize lottery contract 
        //send 10% of balance to lottery contract 
    }

    function sendWinn() payable public donationsclosed onlyCharyteam  {
        uint thisamount = address(this).balance; 
        lotterymoney = thisamount / 100 * 10; 
        lotterywinner.transfer(lotterymoney); 
    }
    function sendDonations() payable public donationsclosed onlyCharyteam {
        uint thisamount = address(this).balance; 
        //get winner project address and send 
    }
    fallback() external payable{
    }

}
