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


contract("ICO Happy Path", (accounts) => {
    beforeEach(async() => {
        newTokenInstance = await QuillToken.new(
            accounts[2], 
            accounts[3],
            accounts[4],
            accounts[5],
            accounts[6],
            { from: accounts[0] }
        );
        
        newWhitelistInstance = await Whitelist.new({ from: accounts[0] });

        newICOInstance = await ICO.new( 
            newTokenInstance.address, 
            newWhitelistInstance.address, 
            accounts[1], 
            (3*Math.pow(10, 11)).toString(), 
            { from: accounts[0] }
        );

        await newTokenInstance.distToICO(newICOInstance.address, { from: accounts[0] });

        BN = web3.utils.BN;
    });

    it("User should be able to buy tokens without calling the buy function directly", async() => {
        advanceTimeToThis("07/15/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[7], { from: accounts[0] });
        await newICOInstance.send(toWei(1), { from: accounts[7] });
        expect((await newTokenInstance.balanceOf(accounts[7])).toString()).to.be.equal(toWei(3750000));    
    });

    it("User should be able to buy all the tokens with some eth left", async() => {
        // Given that ETH-USD Rate == $10**8, ETH spent == 0.125
        advanceTimeToThis("07/15/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[8], { from: accounts[0] });
        await newICOInstance.rebase(Math.pow(10, 16).toString(), { from: accounts[0] });
        receipt = (await newICOInstance.buy( { from: accounts[8], value: toWei(1) })).receipt;
        gasUsed = receipt.cumulativeGasUsed;
        gasPrice = new BN((await web3.eth.getTransaction(receipt.transactionHash)).gasPrice);
        gasCost = (gasPrice.mul(new BN(gasUsed)));

        expect((await newTokenInstance.balanceOf(accounts[8])).toString()).to.be.equal(toWei(12500000000));
        expect((await web3.eth.getBalance(accounts[8])).toString()).to.be.equal((new BN(toWei(99.875)).sub(gasCost)).toString());
    });

    it("User should be able to buy tokens in private phase", async() => {
        advanceTimeToThis("07/15/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[9], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[9], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[9])).toString()).to.be.equal(toWei(3750000));
    });

    it("User should be able to buy tokens in pre-sale phase", async() => {
        advanceTimeToThis("07/31/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[10], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[10], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[10])).toString()).to.be.equal(toWei(3600000));
    });

    it("User should be able to buy tokens in Crowd sale week 1", async() => {
        advanceTimeToThis("08/16/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[11], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[11], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[11])).toString()).to.be.equal(toWei(3450000));
    });

    it("User should be able to buy tokens in Crowd sale week 2", async() => {
        advanceTimeToThis("08/23/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[12], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[12], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[12])).toString()).to.be.equal(toWei(3300000));
    });

    it("User should be able to buy tokens in Crowd sale week 3", async() => {
        advanceTimeToThis("08/30/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[13], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[13], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[13])).toString()).to.be.equal(toWei(3150000));
    });
    
    it("User should be able to buy tokens in Crowd sale week 4", async() => {
        advanceTimeToThis("09/6/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[14], { from: accounts[0] });
        await newICOInstance.buy( { from: accounts[14], value: toWei(1) });
        expect((await newTokenInstance.balanceOf(accounts[14])).toString()).to.be.equal(toWei(3000000));
    });
});

