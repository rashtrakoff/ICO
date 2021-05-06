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
    event Paused(uint256 timestamp);

    event Unpaused(uint256 timestamp);

    event Stopped(uint256 timestamp);


    bool private _paused;

    bool private _stopped;
    
    address private pauser; /// @dev Address of the beneficiary
    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        require(!_stopped, "Pausable: stopped");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        require(!_stopped, "Pausable: stopped");
        _;
    }

    modifier onlyPauser() {
        require(msg.sender == pauser, "Unauthorised access: Not the beneficiary");
        _;
    }
    
    /**
     * @dev Initializes the contract in unpaused state. 
     * Assigns the Pauser role to the deployer in this case, the ICO contract.
     */
    constructor (address _pauser) internal {
        _paused = false;
        pauser = _pauser;
    }

    /**
     * @notice Returns true if the ICO has been stopped
     */
    function stopped() public view returns (bool) {
        return _stopped;
    }

    /**
     * @notice Returns true if the ICO is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @notice Called by a client to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(block.timestamp);
    }

    /**
     * @notice Called by a client to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(block.timestamp);
    }

    /**
     * @notice Can only be called by the client to stop the ICO
     */
    function stop() public onlyPauser {
        _stopped = true;
        emit Stopped(block.timestamp);
    }
}