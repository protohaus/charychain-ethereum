// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

import "./ILottery.sol"; 
//all lotteryfunctions to execute donations-service
contract Lottery is ILottery{
    address public managerpool; 
    address[] public donors;
    bytes32 sealedSeed; 
    bool seedSet; 
    bool donationsClosed; 
    uint storedBlockNumber; 
    uint public numberwinner; 

    //call with donationspool in constructor 
    constructor(){
        managerpool = msg.sender; 
        seedSet = false;
        donationsClosed = false;  
    }

    function enterLottery(address[] memory _donators) external returns (bool){
        donors = _donators; 
        return true; 
    }
    // Implement later with seeds: function getWinner(bytes32 _seed) external returns(address){
    function getWinner() external returns(address){
        //uint random = reveal(_seed); 
        numberwinner = random(); 
        address winner = donors[numberwinner]; 
        return winner; 
    }

    function getSize() public returns(uint){
        return donors.length; 
    }

    //pseudo random number for testing
    function random() public view returns (uint){
        uint thisrandom; 
        thisrandom = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, donors)));
        uint winner = thisrandom%donors.length; 
        return winner; 
    }

}
