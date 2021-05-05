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
    enum Phase { Private, Pre, Crowd1, Crowd2, Crowd3, Crowd4, Finish }

    address payable public beneficiary; // Address of the client's wallet
    uint256 constant START_TIME = 1626287400; // 15th July 2021 00:00:00 hrs (+5:30 GMT)
    uint256 constant END_TIME = 1631730599; // 15th September 2021 23:59:59 hrs (+5:30 GMT)
    uint256 constant TOKEN_RATE = 1e15; // Price of QUILL token in USD ($0.001) represented in bp format ()
    uint256 public ethUSDRate; // ETH-USD Rate
    uint256[7] public Bonus = [uint256(2500), uint256(2000), uint256(1500), uint256(1000), uint256(500), uint256(0)];
    Phase public phase = Phase.Private;


    event ICOInitialized(address beneficiary, uint256 timestamp);
    event PhaseChange(Phase phase, uint256 timestamp);
    event Buy(address indexed investor, uint256 amount, uint256 timestamp);
    event EthReturned(address indexed investor, uint256 amount, uint256 timestamp);

    // Redundant ?
    modifier onlyBeneficiary() 
    {
        require(msg.sender == beneficiary, "Unauthorised access: Not the beneficiary");
        _;
    }
    
    modifier changePhase() {
        if(phase == Phase.Private && block.timestamp >= START_TIME.add(15 days))
            phase = Phase.Pre;
        if(phase == Phase.Pre && block.timestamp >= START_TIME.add(30 days))
            phase = Phase.Crowd1;
        if(phase == Phase.Crowd1 && block.timestamp >= START_TIME.add(30 days + 1 weeks))
            phase == Phase.Crowd2;
        if(phase == Phase.Crowd2 && block.timestamp >= START_TIME.add(30 days + 2 weeks))
            phase == Phase.Crowd3;
        if(phase == Phase.Crowd3 && block.timestamp >= START_TIME.add(30 days + 3 weeks))
            phase = Phase.Crowd4;
        if(phase == Phase.Crowd4 && block.timestamp >= END_TIME)
            phase = Phase.Finish;
        _;
    }

    constructor(
        address _tokenAddress, 
        address _whitelistAddress,
        address payable _beneficiary,
        uint256 _baseEthUSDRate // Remove this when deploying to the testnet and set the rate using oracle
    ) public Pausable(_beneficiary)
    {
        whitelist = Whitelist(_whitelistAddress);
        token = QuillToken(_tokenAddress);
        beneficiary = _beneficiary;
        ethUSDRate = _baseEthUSDRate;
        phase = Phase.Private;

        emit ICOInitialized(_beneficiary, block.timestamp);
    }

    receive() external payable
    {
        buy();
    }

    function buy() public payable whenNotPaused changePhase
    {
        require(phase != Phase.Finish, "ICO has ended");
        require((uint(500)) <= msg.value.mul(ethUSDRate).div(1e26), "Amount less than minimum investment amount");
        require(whitelist.whitelisted(msg.sender), "Account address not whitelisted");

        // To calculate token amount we need the ethUSDRate, the ether sent and the bonus rate
        uint256 tokenAmount = (msg.value).mul(ethUSDRate).mul(1e10).div(TOKEN_RATE);
        uint256 bonusAmount = tokenAmount.mul(Bonus[uint(phase)]).div(1e4);
        tokenAmount = tokenAmount.add(bonusAmount);

        // (tokenAmount.add(bonusAmount) < token.balanceOf(address(this)))? 
        // tokenAmount = tokenAmount.add(bonusAmount): 
        // tokenAmount = token.balanceOf(address(this));

        // require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");

        if(tokenAmount <= token.balanceOf(address(this)))
        {
            require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");
            beneficiary.transfer(msg.value);
        }

        else
        {
            // uint256 ethAmountLeft = msg.value.sub(token.balanceOf(address(this)).div(TOKEN_RATE));
            tokenAmount = token.balanceOf(address(this));
            uint256 ethAmountLeft = (msg.value).sub(tokenAmount.mul(TOKEN_RATE).div(1e10).div(ethUSDRate));
            beneficiary.transfer(msg.value.sub(ethAmountLeft));
            msg.sender.transfer(ethAmountLeft);

            require(token.transfer(msg.sender, token.balanceOf(address(this))), "Token transfer failed");
            emit EthReturned(msg.sender, ethAmountLeft, block.timestamp);
        }   

        emit Buy(msg.sender, tokenAmount, block.timestamp);
    }

    // function rebase() external onlyBeneficiary
    // {
    //     // TODO write a function using the oracle contract
    // }

    // // Redundant functions ?
    // function pauseICO() external 
    // {
    //     pause();
    // }

    // function unpauseICO() external
    // {
    //     unpause();
    // }
}