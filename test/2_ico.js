const truffleAssert = require("truffle-assertions");
const QuillToken = artifacts.require("QuillToken");
const ICO = artifacts.require("ICO");
const Whitelist = artifacts.require("Whitelist");

const toWei = (x) => {
    return web3.utils.toWei(x.toString());
}

contract("ICO", (accounts) => {
    before(async() => {
        tokenInstance = await QuillToken.deployed();
        ICOInstance = await ICO.deployed();
        whitelistInstance = await Whitelist.deployed();
        BN = web3.utils.BN;
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
        await whitelistInstance.addAddress(accounts[7], { from: accounts[0] });
        expect(await whitelistInstance.whitelisted(accounts[7])).to.be.equal(true);
    });

    // Change the amount 10**16 to 3000*10**8 while deploying ICO contract
    // it("User should be able to buy tokens", async() => {
    //     // Given that ETH-USD Rate = $3000
    //     await ICOInstance.buy( { from: accounts[7], value: toWei(1) });
    //     expect((await tokenInstance.balanceOf(accounts[7])).toString()).to.be.equal(toWei(3750000));
    // });

    it("User should be able to buy all the tokens with some eth left", async() => {
        // Given that ETH-USD Rate = $10**8
        receipt = (await ICOInstance.buy( { from: accounts[7], value: toWei(1) })).receipt;
        gasUsed = receipt.cumulativeGasUsed;
        gasPrice = new BN((await web3.eth.getTransaction(receipt.transactionHash)).gasPrice);
        gasCost = (gasPrice.mul(new BN(gasUsed)));
        expect((await tokenInstance.balanceOf(accounts[7])).toString()).to.be.equal(toWei(12500000000));
        expect((await web3.eth.getBalance(accounts[7])).toString()).to.be.equal((new BN(toWei(99.875)).sub(gasCost)).toString());
    });
});