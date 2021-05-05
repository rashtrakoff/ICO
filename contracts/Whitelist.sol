// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable
{
    mapping(address => bool) public whitelisted;


    event AddedToWhitelist(address indexed _recipient);
    event RemovedFromWhitelist(address indexed _recipient);


    function addAddress(address _recipient) external onlyOwner
    {
        require(!whitelisted[_recipient], "Address already whitelisted");

        whitelisted[_recipient] = true;

        emit AddedToWhitelist(_recipient);
    }

    function removeAddress(address _recipient) external onlyOwner
    {
        require(whitelisted[_recipient], "Address already not in the whitelist");

        whitelisted[_recipient] = false;

        emit RemovedFromWhitelist(_recipient);
    }
}