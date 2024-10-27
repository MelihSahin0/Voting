pragma solidity ^0.8.27;

import "./AnonymousVoting.sol";
import "./PublicVoting.sol";

contract VotingManager{
    address public owner;
    address public publicVoting;
    address public anonymousVoting;
    address public activeVoting;
    bool private fundsWithdrawn;

    event VotingCreated(address votingContractAddress, bool isAnonymous);

    constructor(address _publicVoting, address _anonymousVoting) {
        owner = msg.sender;
        fundsWithdrawn = true;
        activeVoting = address(0);

        if (_publicVoting == address(0)) {
            publicVoting = address(new PublicVoting());
        } 
        else {
            publicVoting = _publicVoting;
        }

        if (_anonymousVoting == address(0)) {
            anonymousVoting = address(new AnonymousVoting());
        } 
        else {
            anonymousVoting = _anonymousVoting;
        }
    }

    function createVoting(
        bool isAnonymous, 
        string memory question, 
        string[] memory optionNames, 
        uint durationInMinutes
    ) public {
        require(msg.sender == owner, "Only the owner can create a new voting instance.");
        require(activeVoting == address(0), "A voting session is currently active.");
        require(fundsWithdrawn, "Funds from the last voting session must be withdrawn.");
    
        if (!isAnonymous){
            VotingCore(publicVoting).newVote(question, optionNames, durationInMinutes); 
            PublicVoting(publicVoting).newVoting();
            activeVoting = publicVoting;

            fundsWithdrawn = false;
            emit VotingCreated(publicVoting, false);
        }
        else {
            VotingCore(anonymousVoting).newVote(question, optionNames, durationInMinutes); 
            AnonymousVoting(anonymousVoting).newVoting();
            activeVoting = anonymousVoting;

            fundsWithdrawn = false;
            emit VotingCreated(anonymousVoting, false);
        }
    }

    function endActiveVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting session.");
        require(activeVoting != address(0), "No active voting session");

        VotingCore(activeVoting).endVoting(); 
        activeVoting = address(0);
    }

    function withdrawFunds() public {
        /* For some reason this never works and i couldn't found out why.

        require(msg.sender == owner, "Only the owner can withdraw funds.");
        require(activeVoting == address(0), "Close the active voting session.");

        VotingCore(activeVoting).withdraw();
        */
        fundsWithdrawn = true;
    }
}
