pragma solidity ^0.8.27;

import "./AnonymousVoting.sol";
import "./PublicVoting.sol";

contract VotingManager{
    address public owner;
    address public publicVoting;
    address public anonymousVoting;
    address public activeVoting;
    bool private isAnonymousVoting;

    event VotingCreated(address votingContractAddress, bool isAnonymous);

    constructor(address _publicVoting, address _anonymousVoting) {
        owner = msg.sender;
        activeVoting = address(0);

        if (_publicVoting == address(0)) {
            publicVoting = address(new PublicVoting(msg.sender));
        } 
        else {
            publicVoting = _publicVoting;
        }

        if (_anonymousVoting == address(0)) {
            anonymousVoting = address(new AnonymousVoting(msg.sender));
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
        isAnonymousVoting = isAnonymous;

        if (!isAnonymous){
            PublicVoting(publicVoting).newVote(question, optionNames, durationInMinutes); 
            PublicVoting(publicVoting).newVoting();
            activeVoting = publicVoting;

            emit VotingCreated(publicVoting, false);
        }
        else {
            AnonymousVoting(anonymousVoting).newVote(question, optionNames, durationInMinutes); 
            AnonymousVoting(anonymousVoting).newVoting();
            activeVoting = anonymousVoting;

            emit VotingCreated(anonymousVoting, true);
        }
    }

    function endActiveVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting session.");
        require(activeVoting != address(0), "No active voting session");

        if (isAnonymousVoting){
            AnonymousVoting(activeVoting).endVoting(); 
        }
        else {
            PublicVoting(activeVoting).endVoting();
        }
        
        activeVoting = address(0);
    }
}
