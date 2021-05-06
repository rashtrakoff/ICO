const truffleAssert = require("truffle-assertions");
const QuillToken = artifacts.require("QuillToken");
const ICO = artifacts.require("ICO");
const Whitelist = artifacts.require("Whitelist");

const {
    advanceTimeToThis, advanceTimeAndBlock,
    advanceTime, advanceBlock,
    toUnix, fromUnix, make2,
    fromWei, toWei
} = require("../helper/helper-functions");

contract("Whitelist and Pausable", (accounts) => {
    before(async() => {
        tokenInstance = await QuillToken.deployed();
        ICOInstance = await ICO.deployed();
        whitelistInstance = await Whitelist.deployed();
    });

    it("Beneficiary should be correct", async() => {
        expect(await ICOInstance.beneficiary.call()).to.be.equal(accounts[1]);
    });

    it("Beneficiary should be able to pause the ICO without a special function", async() => {
        await ICOInstance.pause({ from: accounts[1] });
        expect(await ICOInstance.paused()).to.be.equal(true);
    });

    it("Beneficiary should be able to unpause the ICO without a special function", async() => {
        await ICOInstance.unpause({ from: accounts[1] });
        expect(await ICOInstance.paused()).to.be.equal(false);
    });

    it("Admin should be able to whitelist addresses", async() => {
        await whitelistInstance.addAddress(accounts[8], { from: accounts[0] });
        expect(await whitelistInstance.whitelisted(accounts[8])).to.be.equal(true);
    });

    it("Admin should be able to delist addresses from the whitelist", async() =>{
        await whitelistInstance.removeAddress(accounts[8], { from: accounts[0] });
        expect(await whitelistInstance.whitelisted(accounts[8])).to.be.equal(false);
    });

    it("Admin should be able to transfer ownership without a special function", async() => {
        await whitelistInstance.transferOwnership(accounts[1], { from: accounts[0] });
        expect(await whitelistInstance.owner()).to.be.equal(accounts[1]);
    });

});