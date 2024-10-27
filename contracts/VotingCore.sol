pragma solidity ^0.8.27;

abstract contract VotingCore {

    struct Option {
        string name;
        uint voteCount;
    }

    address public owner;
    string public question;
    Option[5] public options;
    uint public votingEndTime;
    bool public isVotingActive;

    event VotedCast(uint optionIndex);
    event VotingEnded();

    constructor() {
        owner = msg.sender;
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

        uint balance = address(this).balance;
        if (balance > 0){
            payable(msg.sender).transfer(balance);
        }   
    }

    function endVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting.");
        require(isVotingActive, "No active voting session.");

        isVotingActive = false;
        emit VotingEnded();
    }

    function newVote(string memory _question, string[] memory optionNames, uint durationInMinutes) public {
        require(msg.sender == owner, "Only the owner can start voting session.");
        require(!isVotingActive, "The Session is still active");

        question = _question;
        votingEndTime = block.timestamp + (durationInMinutes * 1 minutes);

        for (uint i = 0; i < optionNames.length; i++) {
            options[i] = Option({ name: optionNames[i], voteCount: 0 });
        }

        isVotingActive = true;
    }

    function vote(uint optionIndex) public payable virtual;
}
