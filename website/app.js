const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:7545"); // Ganache RPC URL
const votingManagerAddress = "0x423784178f4060c8eB071e8b2166b38D29433e0A"; // Replace with your contract address of the VotingManager

let isCurrentlyAnonymous;
let contractVotingManager;
let contractPublicVoting;
let contractAnonymousVoting;

// I wanted to display the Voting Result and Question in the ui, but javascript wasnt able to get the dom element. They were always null.
window.onload = async (event) => {
    await init();
    
    async function fetchABI(path) {
        try {
            const response = await fetch(path);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            const data = await response.json();
            return data.abi;
        } catch (error) {
            console.error("Error fetching ABI:", error);
            throw error;
        }
    }

    async function init() {
        const abiVotingManager = await fetchABI('./contracts/VotingManager.sol/VotingManager.json');
        contractVotingManager = new ethers.Contract(votingManagerAddress, abiVotingManager, provider.getSigner());

        contractVotingManager.on("VotingCreated", (votingContractAddress, isAnonymous) => {
            isAnonymous ? setupAnonymousVoting(votingContractAddress) : setupPublicVoting(votingContractAddress);
        });
    }

    async function setupPublicVoting(address) {
        const abiPublicVoting = await fetchABI('./contracts/PublicVoting.sol/PublicVoting.json');
        contractPublicVoting = new ethers.Contract(address, abiPublicVoting, provider.getSigner());
        isCurrentlyAnonymous = false;

        setupVotingEvents(contractPublicVoting, "public");
    }

    async function setupAnonymousVoting(address) {
        const abiAnonymousVoting = await fetchABI('./contracts/AnonymousVoting.sol/AnonymousVoting.json');
        contractAnonymousVoting = new ethers.Contract(address, abiAnonymousVoting, provider.getSigner());
        isCurrentlyAnonymous = true;

        setupVotingEvents(contractAnonymousVoting, "anonymous");
    }

    function setupVotingEvents(contract, type) {
        const voteTypeText = type === "public" ? "Vote is public" : "Vote is anonymous";

        contract.on("VotedCast", async (optionIndex) => {
            console.log("VotingType: " + voteTypeText);
            updateVoteQuestion(contract);
            updateVoteResults(contract);
        });

        contract.on("VotingEnded", () => resetVoteDisplay());
    }

    async function updateVoteQuestion(contract) {
        try {
            const question = await contract.question();
            console.log("VoteQuestion: " + question);
        } catch (error) {
            console.error(error);
            console.log("VoteQuestion: " + "Error fetching question");
        }
    }

    async function updateVoteResults(contract) {
        try {
            const [options, results] = await contract.getResults();
            console.log("VoteResult: " + "Options: " + options.join(", ") + " with Results: " + results.join(", "));
        } catch (error) {
            console.error(error);
            console.log("VoteResult: " + "Error fetching results");
        }
    }

    function resetVoteDisplay() {
        console.log("VoteType: " + "There is no Vote")
        console.log("VoteQuestion: " + "There is no Question")
        console.log("VoteResult: " + "There is no Result Vote")
    }
};

document.getElementById("createForm").onsubmit = async (event) => {
    event.preventDefault();
    const isAnonymous = document.getElementById("isAnonymous").checked;
    const question = document.getElementById("question").value;
    const options = [
        document.getElementById("option1").value,
        document.getElementById("option2").value,
        document.getElementById("option3").value,
        document.getElementById("option4").value,
        document.getElementById("option5").value
    ];
    const duration = document.getElementById("duration").value;

    try {
        const tx = await contractVotingManager.createVoting(isAnonymous, question, options, duration);
        await tx.wait();
        document.getElementById("createVoteResult").innerText = "Vote created successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("createVoteResult").innerText = "Error creating vote";
    }
};

document.getElementById("VoteForm").onsubmit = async (event) => {
    event.preventDefault();
    const index = document.getElementById("voteIndex").value;
    try {
        const tx = isCurrentlyAnonymous 
            ? await contractAnonymousVoting.vote(index, { value: ethers.utils.parseEther("0.01") })
            : await contractPublicVoting.vote(index, { value: ethers.utils.parseEther("0.01") });
        await tx.wait();
        document.getElementById("votingResult").innerText = "Voted successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("votingResult").innerText = "Error casting vote";
    }
};

document.getElementById("WithdrawFundsForm").onsubmit = async (event) => {
    event.preventDefault();
    try {
        const tx = await contractVotingManager.withdrawFunds();
        await tx.wait();
        document.getElementById("wResult").innerText = "Withdrawn successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("wResult").innerText = "Error withdrawing funds";
    }
};

document.getElementById("EndActiveVotingForm").onsubmit = async (event) => {
    event.preventDefault();
    try {
        const tx = await contractVotingManager.endActiveVoting();
        await tx.wait();
        document.getElementById("eResult").innerText = "Voting ended successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("eResult").innerText = "Error ending voting";
    }
};