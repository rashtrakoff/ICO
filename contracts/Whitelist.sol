// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable
{
    /**
     * @dev Whitelist of investor addresses
     */
    mapping(address => bool) public whitelisted;


    event AddedToWhitelist(address indexed _recipient, uint256 timestamp);

    event RemovedFromWhitelist(address indexed _recipient, uint256 timestamp);

    /**
     * @dev Function for adding an investor's address to the whitelist
     * Can only be called by the owner which is initially the admin/deployer of the contract
     * @param _recipient Address of the investor
     */
    function addAddress(address _recipient) external onlyOwner
    {
        require(!whitelisted[_recipient], "Address already whitelisted");

        whitelisted[_recipient] = true;

        emit AddedToWhitelist(_recipient, block.timestamp);
    }

    /**
     * @dev Function for removing an investor's address from the whitelist
     * Can only be called by the owner which is initially the admin/deployer of the contract
     * @param _recipient Address of the investor
     */
    function removeAddress(address _recipient) external onlyOwner
    {
        require(whitelisted[_recipient], "Address already not in the whitelist");

        whitelisted[_recipient] = false;

        emit RemovedFromWhitelist(_recipient, block.timestamp);
    }
}