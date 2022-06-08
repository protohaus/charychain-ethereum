// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

import "./ILottery.sol"; 

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

    //implement later 
    /*function enterLottery(address[] memory _donators, bytes32 _sealedSeed) external returns (bool){
        donors = _donators; 
        setSealedSeed(_sealedSeed); 
        return true; 
    }*/

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

    function setSealedSeed(bytes32 _sealedSeed) public {
        require (!seedSet, "seed is already set");
        require (msg.sender == managerpool, "only managerpool can call this function");
        donationsClosed = true; 
        sealedSeed = _sealedSeed; 
        storedBlockNumber = block.number + 1; 
        seedSet = true; 
    }

    /*function reveal(bytes32 _seed) public returns (uint){
        require(seedSet, "seed is not yet set"); 
        require(donationsClosed, "donations are not closed yet"); 
        require(storedBlockNumber < block.number); 
        require(keccak256(abi.encode(msg.sender, _seed))== sealedSeed); 
        uint random = uint(keccak256(abi.encode(_seed, blockhash(storedBlockNumber))));
        //require(keccak256(msg.sender, _seed) == sealedSeed); 
        return random; 
    }*/
    //works with 66bytes 
    function test(bytes32 _test) public returns(bool) {
        //sealedSeed = abi.encodePacked(_test); 
        return true; 
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