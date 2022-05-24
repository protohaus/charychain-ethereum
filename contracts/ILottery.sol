// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

//interface of Lottery so that new lottery can be started once timing is ready
interface ILottery{
    function enterLottery(address[] memory _donators) external returns (bool); 
    function getWinner() external returns(address); 
}