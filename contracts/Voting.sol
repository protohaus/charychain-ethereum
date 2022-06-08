// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IVoting.sol"; 


contract Voting is IVoting{
    //variables 
    uint[] public projectids; //could also be accounts? 
    uint numberofdonators; 
    uint countervoters; 
    address[] public donators;
    mapping(uint => uint) public votesofprojects; 
    uint currentCTBalance; 
    uint numberofprojects; 
    uint winnerproject; 

    //projectid for vote must be within projects 
    

    //constructor with donationspool
    constructor () { 
        currentCTBalance = 0; 
        numberofdonators = 0; 
        countervoters = 0; 
    }

   
    function setProjectIds(uint[] memory _projectids) external returns(bool){
        projectids = _projectids; 
        numberofprojects = _projectids.length; 
        emptyBallot();
        return true; 
    }
   
    //reminder: ask for key to get value! 
    //puts ids as keys with initial value into mapping 
    function emptyBallot() public {
        uint temprojectid; 
        for (uint i=0; i<projectids.length; i++){
            temprojectid = projectids[i]; 
            votesofprojects[temprojectid] = 0; 
        }
    }

    //function to call from other crontract and set right address as voter
    function doVote(uint _idProject, address voter) external returns(bool){
        require (idcorrect(_idProject) == true, "id not valid"); 
        uint tempVote = votesofprojects[_idProject]; 
        tempVote = tempVote + 1; 
        votesofprojects[_idProject] = tempVote;
        donators.push(voter); 
        return true; 
    }

    function receiveVote(uint _idProject) external returns(bool) { 
        require (idcorrect(_idProject) == true, "id not valid"); 
        uint tempVote = votesofprojects[_idProject]; 
        tempVote = tempVote + 1; 
        votesofprojects[_idProject] = tempVote;
        //burn CT of sender or transferFrom since its interface?
        //IERC20(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B).transferFrom(msg.sender, address(this),1);
        donators.push(msg.sender); 
        return true; 

        //send donators address to donations pool and transfer CT back to Spendenpool? 
        //currentCTBalance = IERC20(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B).balanceOf(address(this)); 
    }

    //function to get the updated voters? 
    function getVoters() external returns(address[] memory){
        return donators; 
    }

    function idcorrect(uint _idProject) public returns(bool) {
        for (uint i=0; i<projectids.length; i++){
            if (_idProject == projectids[i]) return true; 
        }
    }

    function showcurrentVotes(uint _idProject) external returns(uint) {
        uint currentVote; 
        currentVote = votesofprojects[_idProject]; 
        return currentVote; 
    }
    //cant iterate trough mapping -> first get votes in array, get highest vote with id, get project id 
    function returnVotingWinner() external returns (bool) {
        uint tempArraySize = projectids.length; 
        uint[] memory VotesArray = new uint[](tempArraySize);
        uint mostVotes = 0; 
        uint idofproject; 
        for (uint i=0; i<projectids.length; i++){
            uint tempKey = projectids[i]; 
            uint tempKeyVote = votesofprojects[tempKey]; 
            VotesArray[i] = tempKeyVote; 
        }
        for (uint i=0; i<projectids.length; i++){
            uint tempVote = VotesArray[i]; 
            if (mostVotes <= tempVote) mostVotes = tempVote; //what to do if same vote? 
        }
        for (uint i=0; i<projectids.length; i++){
            uint tempVote = VotesArray[i]; 
            if (mostVotes == tempVote) idofproject = i; 
        }
        winnerproject = projectids[idofproject]; 
        return true; 
    }

    function getVotingWinner() external returns(uint){
        return winnerproject; 
    }
    //give voting to donationspool? Callbackfuntion? 

}