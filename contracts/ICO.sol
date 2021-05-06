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
    
    Whitelist private whitelist;
    QuillToken private token;
    enum Phase { Inactive, Private, Pre, Crowd1, Crowd2, Crowd3, Crowd4, Finish }

    address payable public beneficiary; // Address of the client's wallet
    // address public ethUSDPricefeedAddress; // Address of the pricefeed contract from Chainlink
    uint256 constant START_TIME = 1626287400; // 15th July 2021 00:00:00 hrs (IST)
    // uint256 constant END_TIME = 1631644200; // 15th September 2021 00:00:00 hrs (IST)
    uint256 constant TOKEN_RATE = 1e15; // Price of QUILL token in USD ($0.001)
    uint256 public ethUSDRate; // ETH-USD Rate
    uint256[7] public Bonus = [uint256(2500), uint256(2000), uint256(1500), uint256(1000), uint256(500), uint256(0)];
    Phase public phase;


    event ICOInitialized(address beneficiary, uint256 timestamp);
    event PhaseChange(Phase phase, uint256 timestamp);
    event Rebase(uint256 rate, Phase phase, uint256 timestamp);
    event Buy(address indexed investor, uint256 amount, uint256 bonus, uint256 timestamp);
    event EthReturned(address indexed investor, uint256 amount, uint256 timestamp);
    

    constructor(
        address _tokenAddress, 
        address _whitelistAddress,
        address payable _beneficiary,
        // address _pricefeed, // Enable this during deployment to testnet
        uint256 _baseEthUSDRate // Remove this when deploying to the testnet and set the rate using oracle
    ) public Pausable(_beneficiary)
    {
        whitelist = Whitelist(_whitelistAddress);
        token = QuillToken(_tokenAddress);
        beneficiary = _beneficiary;
        // ethUSDPricefeedAddress = _pricefeed; //Enable this during deployment to testnet
        ethUSDRate = _baseEthUSDRate;
        phase = Phase.Inactive;

        emit ICOInitialized(_beneficiary, block.timestamp);
    }

    receive() external payable
    {
        buy();
    }

    function buy() public payable whenNotPaused
    {
        changePhase();
        require(phase != Phase.Finish && phase != Phase.Inactive, "ICO event ended/inactive");

        // uint256 ethUSDRate = priceFeedData(ethUSDPricefeedAddress); // Enable this during deployment to testnet

        require((uint(500)) <= msg.value.mul(ethUSDRate).div(1e26), "Amount less than minimum investment amount");
        require(whitelist.whitelisted(msg.sender), "Account address not whitelisted");

        // To calculate token amount we need the ethUSDRate, the ether sent and the bonus rate
        uint256 tokenAmount = (msg.value).mul(ethUSDRate).mul(1e10).div(TOKEN_RATE);
        uint256 bonusAmount = tokenAmount.mul(Bonus[uint256(phase) - 1]).div(1e4);
        tokenAmount = tokenAmount.add(bonusAmount);

        if(tokenAmount <= token.balanceOf(address(this)))
        {
            require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");
            beneficiary.transfer(msg.value);
        }

        else
        {
            tokenAmount = token.balanceOf(address(this));
            uint256 ethAmountLeft = (msg.value).sub(tokenAmount.mul(TOKEN_RATE).div(1e10).div(ethUSDRate));
            beneficiary.transfer(msg.value.sub(ethAmountLeft));
            msg.sender.transfer(ethAmountLeft);

            require(token.transfer(msg.sender, token.balanceOf(address(this))), "Token transfer failed");
            emit EthReturned(msg.sender, ethAmountLeft, block.timestamp);
        }   

        emit Buy(msg.sender, tokenAmount, Bonus[uint256(phase) - 1], block.timestamp);
    }

    // function rebaseEthUSDRate() external
    // {
    //     require(msg.sender == beneficiary, "Unauthorized access: Not the beneficiary");

    //     ethUSDRate = priceFeedData(ethUSDPricefeedAddress);
    // }

    function changePhase() internal
    {
        int256 day = int256(block.timestamp.sub(START_TIME).div(1 days));

        if(day >= 0 && day <= 14)
            phase = Phase.Private;
        else if(day >= 16 && day <= 30)
            phase = Phase.Pre;
        else if(day >= 32 && day <= 38)
            phase = Phase.Crowd1;
        else if(day >= 39 && day <= 45)
            phase = Phase.Crowd2;
        else if(day >= 46 && day <= 52)
            phase = Phase.Crowd3;
        else if(day >= 53 && day <= 61)
            phase = Phase.Crowd4;
        else if(day >= 62)
            phase = Phase.Finish;
        else
            phase = Phase.Inactive;
    }

    // Enable the following function when deploying to testnet
    // function priceFeedData(address _aggregatorAddress)
    //     internal
    //     view
    //     returns (uint256)
    // {
    //     (, int256 price, , , ) = AggregatorV3Interface(_aggregatorAddress).latestRoundData();

    //     return uint256(price);
    // }

    // Functions for testing
    function rebase(uint256 _value) external onlyOwner
    {
        ethUSDRate = _value;
    }
}