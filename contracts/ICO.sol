// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./QuillToken.sol";
import "./Whitelist.sol";
import "./Pausable.sol";

contract ICO is Pausable
{
    using SafeMath for uint256;

    address private beneficiary; // Address of the client's wallet
    uint256 constant START_TIME = 1626287400; // 15th July 2021 00:00:00 hrs (+5:30 GMT)
    uint256 constant END_TIME = 1631730599; // 15th September 2021 23:59:59 hrs (+5:30 GMT)
    uint256 constant TOKEN_PRICE = 10e15; // Price of ERC20 token in USD represented with 18 decimals
    uint256 public ethUSDRate; // ETH-USD Rate

    Whitelist private whitelistContract;
    QuillToken private tokenContract;


    event ICOInitialized(address beneficiary, uint256 timestamp);


    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Unauthorised access: Not the beneficiary");
        _;
    }
    

    constructor(
        address _tokenContract, 
        address _whitelistContract,
        address _beneficiary,
        uint256 _baseEthUSDRate // Remove this when deploying to the testnet and set the rate using oracle
    ) public
    {
        whitelistContract = Whitelist(_whitelistContract);
        tokenContract = QuillToken(_tokenContract);
        beneficiary = _beneficiary;
        ethUSDRate = _baseEthUSDRate;

        emit ICOInitialized(_beneficiary, block.timestamp);
    }
}