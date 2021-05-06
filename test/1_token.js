const truffleAssert = require("truffle-assertions");
const QuillToken = artifacts.require("QuillToken");
const ICO = artifacts.require("ICO");
const ERC20 = artifacts.require("IERC20");

const {
    advanceTimeToThis, advanceTimeAndBlock,
    advanceTime, advanceBlock,
    toUnix, fromUnix, make2,
    fromWei, toWei
} = require("../helper/helper-functions");

contract("Token", (accounts) => {
    before( async() => {
        tokenInstance = await QuillToken.deployed();
        ICOInstance = await ICO.deployed();
    });

    it("Name of the token should be Quill.", async() => {
        expect(await tokenInstance.name()).to.equal("Quill");
    });

    it("Supply of the token should be 50 billion.", async() => {
        expect((await tokenInstance.totalSupply()).toString()).to.be.equal(toWei(50000000000));
    });

    it("ICO contract should get 12.5 billion tokens after deployment.", async() => {
        expect((await tokenInstance.balanceOf(ICOInstance.address)).toString()).to.equal(toWei(12500000000));
    });
});