// const ganache = require("ganache-cli");
// const Web3 = require("web3");
// const provider = ganache.provider();
// const web3 = new Web3(provider);

const toWei = (x) => web3.utils.toWei(x.toString());
const fromWei = (x) => web3.utils.fromWei(x.toString());
const toUnix = (strDate) => Date.parse(strDate) / 1000;
const fromUnix = (UNIX_timestamp) => {
    var a = new Date(UNIX_timestamp * 1000);
    var year = a.getFullYear();
    var month = make2(a.getMonth() + 1);
    var date = make2(a.getDate());
    var hour = make2(a.getHours());
    var min = make2(a.getMinutes());
    var sec = make2(a.getSeconds());
    var time =
        month + "/" + date + "/" + year + " " + hour + ":" + min + ":" + sec;
    return time;
};

function make2(str) {
    str = str.toString();
    return str.length == 1 ? "0".concat(str) : str;
};

async function advanceTimeAndBlock(time) {
    await advanceTime(time);
    await advanceBlock();
    return Promise.resolve(await web3.eth.getBlock("latest"));
};

function advanceBlock() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({ jsonrpc: '2.0', method: 'evm_mine', id: new Date().getTime() },
            (err, result) => { if (err) { return reject(err) } const newBlockHash = web3.eth.getBlock('latest').hash; return resolve(newBlockHash) })
    })
}

function advanceTime(time) {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({ jsonrpc: '2.0', method: 'evm_increaseTime', params: [time], id: new Date().getTime() },
            (err, result) => { if (err) { return reject(err) } return resolve(result) })
    })
}

async function advanceTimeToThis(futureTime) {
    try {
        const blockNumber = await web3.eth.getBlockNumber();
        const block = await web3.eth.getBlock(blockNumber);
        currentTime = block.timestamp;

        futureTime = toUnix(futureTime);
        diff = futureTime - currentTime;
        await advanceTimeAndBlock(diff);
    } catch (error) {
        console.log(error);
    }
}

module.exports = {
    advanceTimeToThis, advanceTimeAndBlock,
    advanceTime, advanceBlock,
    toUnix, fromUnix, make2,
    fromWei, toWei
}