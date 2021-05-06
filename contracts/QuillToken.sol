// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuillToken is ERC20, Ownable
{
    event TokenDeployed(address indexed admin, uint256 timestamp);

    event TokenGivenToICO(address indexed ICOContract, uint256 timestamp);

    /**
     * @dev Tokens are distributed to the respective wallets while deploying this contract
     * @param _reserveWallet Wallet for the reserve
     * @param _interestPayoutWallet Wallet for paying out interest
     * @param _HRWallet Wallet of HR and team
     * @param _generalFundWallet Wallet for general usage
     * @param _bountiesWallet Wallet for bounties and airdrops 
     */
    constructor(
        address _reserveWallet,
        address _interestPayoutWallet,
        address _HRWallet,
        address _generalFundWallet,
        address _bountiesWallet
    ) public ERC20("Quill", "QUILL") 
    {
        _mint(_reserveWallet, 15000000000 * 1e18);
        _mint(_interestPayoutWallet, 10000000000 * 1e18);
        _mint(_HRWallet, 5000000000 * 1e18);
        _mint(_generalFundWallet, 6500000000 * 1e18);
        _mint(_bountiesWallet, 1000000000 * 1e18);

        emit TokenDeployed(msg.sender, block.timestamp);
    }

    /**
     * @dev Tokens distributed to the ICO smart contract upon deployment of the ICO contract
     */
    function distToICO(address _ICOContract) external onlyOwner
    {
        _mint(_ICOContract, 12500000000 * 1e18);

        emit TokenGivenToICO(_ICOContract, block.timestamp);
    }
}
