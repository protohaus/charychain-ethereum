// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "./IVoting.sol"; 

contract Spendenpool{
    //variables 
    address public charyteam; 
    address[] public donators; //payable not neccessary within address? 
    address[] public voters; //temporary to chekc if working
    address payable[] public projects; //struct projects with address and id? 
    address public votingcontract; 
    uint donations; 
    bool donationsopen = true; 
    uint public startTime = block.timestamp;
    

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

    //events to the frontend 
    //event Donator donated (adrdess, uint amount); 


    //functions 
    //initiate Voting, should be immediatley because voting runs parallel to donations 
    function initiateVoting(address _votingAddress) external {
        //initiate voting with this address
        votingcontract = _votingAddress; 
    }
    //donations of donators 
    function donate() payable public {
        //minimum value? 
        require(msg.value >= 0.1 ether, "Invest minimum of 0.1 ether");
        //keeping track of the Donators 
        donators.push(msg.sender); 
        sendCT(); 
        //emit event here 
    }


    function updateVoting() public returns(address[] memory){
        //update number of donators (or off-chain)? 
        IVoting v = IVoting(votingcontract); 
        voters = v.getVoters(); //wo speichern 
        return voters; 
    }

    //getbalance 
    function getBalance() public view returns(uint) {
        // everyone can see balance 
        return address(this).balance; 
    }

    
    //getbalance of CT in this contract, careful contract address changes when deploying!! 
    function getCTBalance() public view onlyCharyteam returns(uint) {
        return IERC20(0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee).balanceOf(address(this));
    }

    //send charity token to donator after donation 
    function sendCT() payable public {
        //require balance CT = 0 
        uint tempCT = IERC20(0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee).balanceOf(msg.sender);
        require(tempCT == 0, "sender already has a CT"); 
        IERC20(0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee).transfer(msg.sender, 1); 
    }


    //after 3month close donations  
    function closeDonations() public {
        if (donationsopen == true && block.timestamp >= startTime + 30 days) donationsopen = false; 
    }

    //get result of voting //after donations are closed
    function votingresult() public returns (uint) {
        IVoting v = IVoting(votingcontract); 
        return v.getVotingWinner(); 
    }

    function activateLottery() payable public donationsclosed {
        //initialize lottery contract 
        //send 10% of balance to lottery contract 
    }

    function sendDonations() payable public donationsclosed onlyCharyteam {
        //implement 
    }



}