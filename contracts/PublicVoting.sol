pragma solidity ^0.8.27;

import "./VotingCore.sol";

contract PublicVoting is VotingCore {
    
    mapping(address => bool) public hasVoted;
    address[] public voters;

    constructor(
    ) VotingCore() {}

    function newVoting() public {
        require(msg.sender == owner, "Only the owner can create a new voting instance.");

        for (uint256 i = 0; i < voters.length; i++) {
            hasVoted[voters[i]] = false;
        }
        delete voters;
    }

    function vote(uint optionIndex) public payable override {
        require(isVotingActive, "The voting session is not active.");
        require(optionIndex < options.length, "Invalid option.");
        require(msg.value == 0.01 ether, "Please pay exactly 0.01 ethers");
        require(block.timestamp < votingEndTime, "The voting session has ended.");
        require(!hasVoted[msg.sender], "You have already voted.");

        options[optionIndex].voteCount += 1;
        hasVoted[msg.sender] = true;
        voters.push(msg.sender);

        emit VotedCast(optionIndex);
    }

    function getVotingType() public pure returns (string memory) {
        return "Public";
    }
}
