// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

//interface of voting so that voting functions can be used in spendenpool 
interface IVoting{
    function getVoters() external returns(address[] memory);
    function showcurrentVotes(uint _idProject) external returns(uint);
    function getVotingWinner() external returns(uint); 
    function setProjectIds(uint[] memory _projectids) external returns(bool); 
}