const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const VotingManagerModule = buildModule("VotingManagerModule", (m) => {
    const VotingManager = m.contract("VotingManager", ["0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000"]);
    return {
        VotingManager
    };
});

module.exports = VotingManagerModule;
