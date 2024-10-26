pragma solidity ^0.8.27;

import "./Utils.sol";
import "./VotingCore.sol";

contract PublicVoting is VotingCore {
    using Utils for uint;

    mapping(address => bool) public hasVoted;

    constructor(
        string memory question, 
        string[] memory optionNames, 
        uint durationInMinutes, 
        address owner,
        uint voteFee
    ) VotingCore(owner, question, optionNames, durationInMinutes, voteFee) {}

    function vote(uint optionIndex) public payable override {
        require(isVotingActive, "The voting session is not active.");
        require(optionIndex < options.length, "Invalid option.");
        require(msg.value == voteFee, string(abi.encodePacked("Please pay exactly ", voteFee.uint2str() , " wei.")));
        require(block.timestamp < votingEndTime, "The voting session has ended.");
        require(!hasVoted[msg.sender], "You have already voted.");

        options[optionIndex].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit VotedCast(optionIndex);
    }

    function getVotingType() public pure returns (string memory) {
        return "Public";
    }
}
