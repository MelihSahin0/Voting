const UseSepoliaNetwork = false;
const votingManagerAddress = "0x85D78B05B168D062efDB2dd49b1B7151e15eE08B"; // Replace with your contract address of the VotingManager

let isCurrentlyAnonymous;
let contractVotingManager;
let contractPublicVoting;
let contractAnonymousVoting;
let signer;

window.onload = async (event) => {

    if (UseSepoliaNetwork) {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
    } else {
        const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:7545");
        signer = provider.getSigner();
    }

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
        contractVotingManager = new ethers.Contract(votingManagerAddress, abiVotingManager, signer);

        contractVotingManager.on("VotingCreated", (votingContractAddress, isAnonymous) => {
            isAnonymous ? setupAnonymousVoting(votingContractAddress) : setupPublicVoting(votingContractAddress);
        });
    }

    async function setupPublicVoting(address) {
        const abiPublicVoting = await fetchABI('./contracts/PublicVoting.sol/PublicVoting.json');
        contractPublicVoting = new ethers.Contract(address, abiPublicVoting, signer);
        isCurrentlyAnonymous = false;

        setupVotingEvents(contractPublicVoting);
    }

    async function setupAnonymousVoting(address) {
        const abiAnonymousVoting = await fetchABI('./contracts/AnonymousVoting.sol/AnonymousVoting.json');
        contractAnonymousVoting = new ethers.Contract(address, abiAnonymousVoting, signer);
        isCurrentlyAnonymous = true;

        setupVotingEvents(contractAnonymousVoting);
    }

    async function setupVotingEvents(contract) {
        updateEverything(contract);

        contract.on("VotedCast", async (optionIndex) => {
            updateEverything(contract);
        });

        contract.on("VotingEnded", () => resetVoteDisplay());
    }

    async function updateEverything(contract) {
        try {
            const isActive = await contract.isVotingActive();
            if (isActive){
                const voteTypeText = await contract.getVotingType();
                document.getElementById("VotingType").innerHTML = "VotingType: Vote is " + voteTypeText;
            } 
            else {
                resetVoteDisplay();
            }        
        }
        catch (error)
        {
            document.getElementById("VotingType").innerHTML =  "VotingType: Error fetching votingType";
        }

        updateVoteQuestion(contract);
        updateVoteResults(contract);
    }

    async function updateVoteQuestion(contract) {
        try {
            const question = await contract.question();
            document.getElementById("VoteQuestion").innerHTML = "VoteQuestion: " + question;
        } catch (error) {
            console.error(error);
            document.getElementById("VoteQuestion").innerHTML = "VoteQuestion: Error fetching question";
        }
    }

    async function updateVoteResults(contract) {
        try {
            const [options, results] = await contract.getResults();
            document.getElementById("VoteResult").innerHTML = "VoteResult: " + "Options: " + options.join(", ") + " with Results: " + results.join(", ");
        } catch (error) {
            console.error(error);
            document.getElementById("VoteResult").innerHTML = "VoteResult: Error fetching results";
        }
    }

    function resetVoteDisplay() {
        document.getElementById("VotingType").innerHTML = "VotingType: The Vote is closed.";
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
        resetCreateInput();
        document.getElementById("createVoteResult").innerText = "Vote created successfully!";
        sleep(2000).then(() => { document.getElementById("createVoteResult").innerText = ""; });
    } catch (error) {
        console.error(error);
        document.getElementById("createVoteResult").innerText = "Error creating vote";
        sleep(2000).then(() => { document.getElementById("createVoteResult").innerText = ""; });
    }
};

function resetCreateInput() {
    document.getElementById("isAnonymous").checked = false;
    document.getElementById("question").value = "";
    document.getElementById("option1").value = "";
    document.getElementById("option2").value = "";
    document.getElementById("option3").value = "";
    document.getElementById("option4").value = "";
    document.getElementById("option5").value = "";
    document.getElementById("duration").value = "";
}


document.getElementById("VoteForm").onsubmit = async (event) => {
    event.preventDefault();
    const index = document.getElementById("voteIndex").value;
    try {
        const tx = isCurrentlyAnonymous 
            ? await contractAnonymousVoting.vote(index, { value: ethers.utils.parseEther("0.01") })
            : await contractPublicVoting.vote(index, { value: ethers.utils.parseEther("0.01") });
        await tx.wait();
        document.getElementById("voteIndex").value = "";
        document.getElementById("votingResult").innerText = "Voted successfully!";
        sleep(2000).then(() => { document.getElementById("votingResult").innerText = ""; });
    } catch (error) {
        console.error(error);
        document.getElementById("votingResult").innerText = "Error casting vote";
        sleep(2000).then(() => { document.getElementById("votingResult").innerText = ""; });
    }
};

document.getElementById("WithdrawFundsForm").onsubmit = async (event) => {
    event.preventDefault();
    try {
        const tx = isCurrentlyAnonymous 
            ? await contractAnonymousVoting.withdraw()
            : await contractPublicVoting.withdraw();
        await tx.wait();
        document.getElementById("wResult").innerText = "Withdrawn successfully!";
        sleep(2000).then(() => { document.getElementById("wResult").innerText = ""; });
    } catch (error) {
        console.error(error);
        document.getElementById("wResult").innerText = "Error withdrawing funds";
        sleep(2000).then(() => { document.getElementById("wResult").innerText = ""; });
    }
};

document.getElementById("EndActiveVotingForm").onsubmit = async (event) => {
    event.preventDefault();
    try {
        const tx = await contractVotingManager.endActiveVoting();
        await tx.wait();
        document.getElementById("eResult").innerText = "Voting ended successfully!";
        sleep(2000).then(() => { document.getElementById("eResult").innerText = ""; });
    } catch (error) {
        console.error(error);
        document.getElementById("eResult").innerText = "Error ending voting";
        sleep(2000).then(() => { document.getElementById("eResult").innerText = ""; });
    }
};

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }