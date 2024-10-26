pragma solidity ^0.8.27;

abstract contract VotingCore {

    struct Option {
        string name;
        uint voteCount;
    }

    address public owner;
    string public question;
    Option[] public options;
    uint public voteFee;
    uint public votingEndTime;
    bool public isVotingActive;

    event VotedCast(uint optionIndex);
    event VotingEnded();

    constructor(address _owner, string memory _question, string[] memory optionNames, uint durationInMinutes, uint _voteFee) {
        owner = _owner;
        question = _question;
        votingEndTime = block.timestamp + (durationInMinutes * 1 minutes);
        voteFee = _voteFee;

        for (uint i = 0; i < optionNames.length; i++) {
            options.push(Option({ name: optionNames[i], voteCount: 0 }));
        }

        isVotingActive = true;
    }

    function getResults() public view returns (string[] memory, uint[] memory) {
        string[] memory optionNames = new string[](options.length);
        uint[] memory voteCounts = new uint[](options.length);

        for (uint i = 0; i < options.length; i++) {
            optionNames[i] = options[i].name;
            voteCounts[i] = options[i].voteCount;
        }
        return (optionNames, voteCounts);
    }

    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw funds.");
        require(!isVotingActive, "Voting must be ended before withdrawing.");

        payable(owner).transfer(address(this).balance);
    }

    function endVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting.");
        require(isVotingActive, "No active voting session.");

        isVotingActive = false;
        emit VotingEnded();
    }

    function vote(uint optionIndex) public payable virtual;
}
