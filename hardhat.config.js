require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY
const INFURA_API_KEY = process.env.INFURA_API_KEY

require("@nomicfoundation/hardhat-toolbox");
module.exports = {
  solidity: "0.8.27",
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: ["0xC700d23B2e4F9663D971c47c3E513EC8884060b4"] // Replace with private keys from Ganache
    },
    sepolia: {
        url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
        accounts: [PRIVATE_KEY],
      },
  }
};