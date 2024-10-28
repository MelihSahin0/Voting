This is a simple Voting Project made with soditium and has a simple UI in the website folder.
This application was tested on Ganache. 

About this Project. The owner can create two Types of Voting. The first one is a public voting, where you can see, 
which address voted for wich option. The second type is an anonymous voting. In this voting the addresses are beeing hashed. 

HOW TO INTERACT WITH IT VIA TERMINAL:

With this command you deploy the VotingManager:
* npx hardhat ignition deploy ./ignition/modules/VotingManager.js --network ganache

After deploying it on the terminal you will receive the address of the block. With that you should make a contract like this:
* const abiVotingManager = await fetchABI('./contracts/VotingManager.sol/VotingManager.json');
* contractVotingManager = new ethers.Contract(votingManagerAddress, abiVotingManager, provider.getSigner());

So now you are able to create Votings. Please not that you can have only one Voting active at the time. 

There are 4 parameters to create a voting. As seen below:
* tx = await contractVotingManager.createVoting(isAnonymous, question, options, duration);
-> isAnonymous: true or false,
-> questoin: a string
-> options: a string array of a lenght of 5.
-> duration: how long the voting is valid in minutes.

After creating the vote you can get the address of the active voting with:
* tx = await contractVotingManager.activeVoting();

Now like the VotingManager you need to make an contract (with 'TYPE' i mean if its an public or anonymous Voting): 
* const abiTYPE = await fetchABI('./contracts/TYPE.sol/TYPE.json');
* contractTYPE = new ethers.Contract(TYPEAddress, abiTYPE, provider.getSigner());

After you have the contract you can vote one time in this vote:
* tx = await contractTYPE.vote(index, { value: ethers.utils.parseEther("0.01") })
-> index: references which array index you want to vote (0 - 4) are valid

You can get the result to:
* await contract.getResults();
-> you get two arrays. The first one shows what the options are and the second show how often it was voted.

As i said bevor there can only be one vote at the time. So to make a new vote the owner needs to close it and afterwards withdraw the money. These must be done in that sequence.
* tx = await contractVotingManager.endActiveVoting();
* tx = await contractVotingManager.withdrawFunds();

This should be the core of the application.

HOW TO USE THE WEBSITE:

If you don`t have a VotingManager deployed, you can do it with this:
* npx hardhat ignition deploy ./ignition/modules/VotingManager.js --network ganache

In the app.js file there is the const votingManagerAddress variable. You need to set that with the address of the Votingmanager block manuelly bevor starting the website. If you deployed it yourself the terminal will return the address.

To start the website you need to go into the website folder:
* cd website

If you have python installed you can write this to start the website:
* python -m http.server

Now you can use the website. If there is an error poping up when clicking on the buttons, you can open the console from the website and check to see the error, why it didn´t work. The error message is always after the require and it should explain. 
it didnt work.

The rules are the same:
Only the owner can start a voting.
Only one voting can be active at the time.
To start a new voting the owner needs to close and afterwards withdraw the money from the voting in that sequence. 
You can vote only one time.
