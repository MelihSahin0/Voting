pragma solidity ^0.8.27;

import "./AnonymousVoting.sol";
import "./PublicVoting.sol";

contract VotingFactory {

    address public owner;
    address public activeVoting;
    bool private fundsWithdrawn;

    event VotingCreated(address votingContractAddress, bool isAnonymous);

    constructor() {
        owner = msg.sender;
        activeVoting = address(0);
        fundsWithdrawn = true;
    }

    function createVoting(
        bool isAnonymous, 
        string memory question, 
        string[] memory optionNames, 
        uint durationInMinutes,
        uint voteFee
    ) public {
        require(msg.sender == owner, "Only the owner can create a new voting instance.");
        require(activeVoting == address(0), "A voting session is currently active.");
        require(fundsWithdrawn, "Funds from the last voting session must be withdrawn.");
        require(voteFee > 0 ether, "VoteFee can not be smaller then 0");

        address votingContract;
        if (isAnonymous) {
            AnonymousVoting newVoting = new AnonymousVoting(question, optionNames, durationInMinutes, msg.sender, voteFee);
            votingContract = address(newVoting);
        } else {
            PublicVoting newVoting = new PublicVoting(question, optionNames, durationInMinutes, msg.sender, voteFee);
            votingContract = address(newVoting);
        }

        fundsWithdrawn = false;
        activeVoting = votingContract;
        emit VotingCreated(votingContract, isAnonymous);
    }

    function endActiveVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting session.");
        require(activeVoting != address(0), "No active voting session.");

        VotingCore(activeVoting).endVoting(); 
        activeVoting = address(0);
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds.");
        require(activeVoting != address(0), "No active voting session.");

        VotingCore(activeVoting).withdraw();
        fundsWithdrawn = true;
    }
}
