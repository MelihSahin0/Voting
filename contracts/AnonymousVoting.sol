pragma solidity ^0.8.27;

import "./VotingCore.sol";

contract AnonymousVoting is VotingCore {

    mapping(bytes32 => bool) private hasVotedHash;
    bytes32[] public voters;

   constructor(address _creator) VotingCore(_creator) {}

    function newVoting() public {
        require(msg.sender == owner, "Only the owner can create a new voting instance.");

        for (uint256 i = 0; i < voters.length; i++) {
            hasVotedHash[voters[i]] = false;
        }
        delete voters;
    }

    function vote(uint optionIndex) public payable override {
        require(isVotingActive, "The voting session is not active.");
        require(optionIndex < options.length, "Invalid option.");
        require(msg.value == 0.01 ether, "Please pay exactly 0.01 ethers");
        require(block.timestamp < votingEndTime, "The voting session has ended.");

        bytes32 voterHash = keccak256(abi.encodePacked(msg.sender));
        require(!hasVotedHash[voterHash], "You have already voted.");

        options[optionIndex].voteCount += 1;
        hasVotedHash[voterHash] = true;
        voters.push(voterHash);
        emit VotedCast(optionIndex);
    }

    function getVotingType() public pure returns (string memory) {
        return "Anonymous";
    }
}
