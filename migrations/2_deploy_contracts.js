const QuillToken = artifacts.require("QuillToken");
const Whitelist = artifacts.require("Whitelist");
const ICO = artifacts.require("ICO");

module.exports = async function(deployer, network, accounts) {
    /**
     * @dev Account roles
     * account[0] = admin
     * account[1] = beneficiary/client
     * account[2] = reserveWallet
     * account[3] = interestPayoutWallet
     * account[4] = HRWallet
     * account[5] = generalFundWallet
     * account[6] = bountiesWallet
     */

    // TODO: Write the Addresses of all the wallets
    await deployer.deploy(
        QuillToken, 
        accounts[2], 
        accounts[3],
        accounts[4],
        accounts[5],
        accounts[6],
        { from: accounts[0] }
    );
    tokenInstance = await QuillToken.deployed();

    await deployer.deploy(Whitelist, { from: accounts[0] });
    whitelistInstance = await Whitelist.deployed();

    await deployer.deploy(
        ICO, 
        tokenInstance.address, 
        whitelistInstance.address, 
        accounts[1], 
        "0x9326BFA02ADD2366b30bacB125260Af641031331",
        { from: accounts[0] }
    );

    ICOInstance= await ICO.deployed();
    await tokenInstance.distToICO(ICO.address, { from: accounts[0] });

    console.log("Migrations complete.");
}