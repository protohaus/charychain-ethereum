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

    //call with donationspool in constructor 
    constructor(){
        managerpool = msg.sender; 
        seedSet = false;
        donationsClosed = false; 
    }


    function enterLottery(address[] memory _donators, bytes32 _sealedSeed) external returns (bool){
        donors = _donators; 
        setSealedSeed(_sealedSeed); 
        return true; 
    }

    function getWinner(bytes32 _seed) external returns(address){
        uint random = reveal(_seed); 
        return msg.sender; //mit rando  aus donors array den gewinner bestimmen
    }

    function setSealedSeed(bytes32 _sealedSeed) public {
        require (!seedSet, "seed is already set");
        require (msg.sender == managerpool, "only managerpool can call this function");
        donationsClosed = true; 
        sealedSeed = _sealedSeed; 
        storedBlockNumber = block.number + 1; 
        seedSet = true; 
    }

    function reveal(bytes32 _seed) public returns (uint){
        require(seedSet, "seed is not yet set"); 
        require(donationsClosed, "donations are not closed yet"); 
        require(storedBlockNumber < block.number); 
        require(keccak256(abi.encode(msg.sender, _seed))== sealedSeed); 
        uint random = uint(keccak256(abi.encode(_seed, blockhash(storedBlockNumber))));
        //require(keccak256(msg.sender, _seed) == sealedSeed); 
        return random; 
    }
    function test(bytes32 _test) public returns(bool) {
        //sealedSeed = abi.encodePacked(_test); 
        return true; 
    }

}