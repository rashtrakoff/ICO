// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Ownable 
{
    /**
     * @dev Emitted when the pause is triggered by ICO contract.
     */
    event Paused(uint256 timestamp);

    /**
     * @dev Emitted when the pause is lifted by a ICO contract.
     */
    event Unpaused(uint256 timestamp);

    bool private _paused;

    address private pauser; // Address of the beneficiary
    
    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer in this case, the ICO contract.
     */
    constructor (address _pauser) internal {
        _paused = false;
        pauser = _pauser;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    // Checks if the caller of a function is the beneficiary or not
    modifier onlyPauser() {
        require(msg.sender == pauser, "Unauthorised access: Not the beneficiary");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(block.timestamp);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(block.timestamp);
    }
}