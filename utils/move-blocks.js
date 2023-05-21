const {network} = require("hardhat")

async function moveBlocks(amount) {
    console.log("Moving blocks...")
    for (let i = 0; i < amount; i++) {
        await network.provider.request({method: "evm_mine", params: []})
    }
}

module.exports = {moveBlocks}
