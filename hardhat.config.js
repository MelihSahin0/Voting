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
      accounts: ["0x5c109aad06748b6e6aa0611259de1aec9597cfb2c51024ba1fcce7a40cf3e287"] // Replace with private keys from Ganache
    },
    sepolia: {
        url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
        accounts: [PRIVATE_KEY],
      },
  }
};