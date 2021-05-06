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

contract("ICO Unhappy Path", (accounts) => {
    beforeEach(async() => {
        await advanceTimeToThis("07/15/2021 00:00:00");
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
            "0x9326BFA02ADD2366b30bacB125260Af641031331",
            { from: accounts[0] }
        );

        await newTokenInstance.distToICO(newICOInstance.address, { from: accounts[0] });
        await newWhitelistInstance.addAddress(accounts[7], { from: accounts[0] });

        BN = web3.utils.BN;
    });

    it("Shouldn't be able to buy tokens if not whitelisted", async() => {
        await newWhitelistInstance.removeAddress(accounts[7], { from: accounts[0] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "Account address not whitelisted"
        );
    });

    it("Shouldn't be able to buy tokens with an investment of under $500", async() => {
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(0.001)}),
            "Amount less than minimum investment amount"
        );
    });

    it("User shouldn't be able to buy tokens on 30th July", async() => {
        await advanceTimeToThis("07/30/2021 00:00:00");
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        );
    });

    it("User shouldn't be able to buy tokens on 15th August", async() => {
        await advanceTimeToThis("08/15/2021 00:00:00");
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        );
    });

    it("User shouldn't be able to buy tokens after ICO is paused", async() => {
        await advanceTimeToThis("08/16/2021 00:00:00");
        await newICOInstance.pause({ from: accounts[1] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "Pausable: paused"
        );
    });

    it("User shouldn't be able to buy tokens after ICO is stopped", async() => {
        await advanceTimeToThis("08/16/2021 00:00:00");
        await newICOInstance.stop({ from: accounts[1] });
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "Pausable: stopped"
        );
    });

    it("User shouldn't be able to buy tokens after ICO has ended", async() => {
        await advanceTimeToThis("09/15/2021 00:00:00");
        await truffleAssert.reverts(
            newICOInstance.buy({ from: accounts[7], value: toWei(1)}),
            "ICO event ended/inactive"
        ); 
    });
});