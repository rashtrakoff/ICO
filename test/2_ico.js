const truffleAssert = require("truffle-assertions");
const QuillToken = artifacts.require("QuillToken");
const ICO = artifacts.require("ICO");
const Whitelist = artifacts.require("Whitelist");

const toWei = (x) => {
    return web3.utils.toWei(x.toString());
}

contract("ICO contract testing", (accounts) => {
    before(async() => {
        tokenInstance = await QuillToken.deployed();
        ICOInstance = await ICO.deployed();
    });

    // TODO: Write tests for the ICO contract
    
});