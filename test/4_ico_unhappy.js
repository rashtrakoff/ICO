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

contract("ICO Unhappy Path", async(accounts) => {
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

    it("User shouldn't be able to buy tokens on 30th July", async() => {
        advanceTimeToThis("07/30/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[7], { from: accounts[0] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        );
    });

    it("User shouldn't be able to buy tokens on 15th August", async() => {
        advanceTimeToThis("08/15/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[7], { from: accounts[0] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        );
    });

    it("User shouldn't be able to buy tokens after ICO has ended", async() => {
        advanceTimeToThis("09/15/2021 00:00:00");
        await newWhitelistInstance.addAddress(accounts[7], { from: accounts[0] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        );
    });
});