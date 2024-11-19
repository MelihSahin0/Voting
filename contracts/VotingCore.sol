pragma solidity ^0.8.27;

abstract contract VotingCore {

    struct Option {
        string name;
        uint voteCount;
    }

    address public owner;
    address public creator;
    string public question;
    Option[5] public options;
    uint public votingEndTime;
    bool public isVotingActive;
    bool public withdrawn;

    event VotedCast(uint optionIndex);
    event VotingEnded();

    constructor(address _creator) {
        owner = msg.sender;
        creator = _creator;
        withdrawn = false;
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
        require(msg.sender == creator, "Only the owner can withdraw funds.");
        require(isVotingActive, "No active voting session.");
        require(withdrawn == false, "Funds already withdrawn.");

        uint balance = address(this).balance;
        if (balance > 0){
            payable(msg.sender).transfer(balance);
        }   
        withdrawn = true;
    }

    function endVoting() public {
        require(msg.sender == owner, "Only the owner can end the voting.");
        require(isVotingActive, "No active voting session.");
        require(withdrawn == true, "Funds needs to be withdrawn.");

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
