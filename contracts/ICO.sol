// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./QuillToken.sol";
import "./Whitelist.sol";
import "./Pausable.sol";

/**
 * @title ICO contract
 * @author Chinmay Sai Vemuri
 * @notice This contract will only run in testnet (kovan) fork mode 
 */
contract ICO is Pausable {
    using SafeMath for *;

    /**
     * @dev Dependent contract addresses
     */
    Whitelist private whitelist;
    QuillToken private token;


    /// @dev Different phases/rounds of the ICO can represented using this enum but that will consume gas
    /// hence decided to remove it and its related statements
    // enum Phase {Inactive, Private, Pre, Crowd1, Crowd2, Crowd3, Crowd4, Finish}

    /**
     * @dev Wallet address of the client
     */
    address payable public beneficiary;

    /**
     * @dev Oracle contract address of ETH/USD Chainlink Pricefeed
     */
    address public ethUSDPricefeedAddress;

    /**
     * @dev Start time of the ICO in Indian Standard Time (+5:30 GMT)
     */
    uint256 constant public START_TIME = 1626287400; // 15th July 2021 00:00:00 hrs (IST)

    /// @dev End time of the ICO is not really necessary since the duration has been mentioned in the task as 62 days
    // uint256 constant END_TIME = 1631644200; // 15th September 2021 00:00:00 hrs (IST)

    /**
     * @dev Rate of the ICO ERC20 token represented with 18 decimals which converts to $0.001
     */
    uint256 constant public TOKEN_RATE = 1e15;

    /**
     * @dev ETH/USD rate which can be manipulated by the client but only using the oracle pricefeed
     */
    uint256 public ethUSDRate; // ETH-USD Rate

    /**
     * @dev ICO bonus structure represented in basis point format for retaining the precision
     */
    uint256[6] public Bonus = [
        uint256(2500),
        uint256(2000),
        uint256(1500),
        uint256(1000),
        uint256(500),
        uint256(0)
    ];


    event ICOInitialized(address beneficiary, uint256 timestamp);

    event Rebase(uint256 rate, uint256 phase, uint256 timestamp);

    event Buy(
        address indexed investor,
        uint256 amount,
        uint256 bonus,
        uint256 timestamp
    );


    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Unauthorised access: Not the beneficiary");
        _;
    }


    /**
     * @dev Constructor of the ICO smart contract
     * @dev To deploy on testnet, comment _pricefeed and enable _baseEthUSDRate
     * @param _tokenAddress Address of the deployed ERC20 token
     * @param _whitelistAddress Address of the whitelist
     * @param _beneficiary Address of the client
     * @param _pricefeed Address of the ETH/USD oracle contract
     */
    constructor(
        address _tokenAddress,
        address _whitelistAddress,
        address payable _beneficiary,
        address _pricefeed
    ) public Pausable(_beneficiary) {
        whitelist = Whitelist(_whitelistAddress);
        token = QuillToken(_tokenAddress);
        beneficiary = _beneficiary;
        ethUSDPricefeedAddress = _pricefeed; 
        ethUSDRate = priceFeedData(_pricefeed);

        emit ICOInitialized(_beneficiary, block.timestamp);
    }

    /**
     * @dev If ether is directly sent to the contract, a buy order is initiated 
     */
    receive() external payable {
        buy();
    }

    /**
     * @dev The main function of ICO contract, open to whitelisted investors for buying the token
     * @dev Anyone can call this function during crowdsale if decided not to whitelist them
     */
    function buy() public payable whenNotPaused {
        uint256 phase = changePhase();
        
        require(
            phase != uint256(6),
            "ICO event ended/inactive"
        );

        ethUSDRate = priceFeedData(ethUSDPricefeedAddress); 

        require(
            (uint256(500)) <= msg.value.mul(ethUSDRate).div(1e26),
            "Amount less than minimum investment amount"
        );
        
        /// @dev Removing the if condition in case only whitelisted investors are allowed for the ICO 
        if(phase < uint256(2)) {
            require(
                whitelist.whitelisted(msg.sender),
                "Account address not whitelisted"
            );
        }
         
        uint256 tokenAmount = (msg.value).mul(ethUSDRate).mul(1e10).div(TOKEN_RATE);
        uint256 bonusAmount = tokenAmount.mul(Bonus[phase]).div(1e4);
        tokenAmount = tokenAmount.add(bonusAmount);

        if(tokenAmount <= token.balanceOf(address(this))) {
            beneficiary.transfer(msg.value);
        } else {
            tokenAmount = token.balanceOf(address(this));
            uint256 ethAmountLeft =
                (msg.value).sub(
                    tokenAmount.mul(TOKEN_RATE).div(1e10).div(ethUSDRate)
                );

            beneficiary.transfer(msg.value.sub(ethAmountLeft));
            msg.sender.transfer(ethAmountLeft);
        }

        require(
            token.transfer(msg.sender, tokenAmount),
            "Token transfer failed"
        );

        emit Buy(
            msg.sender,
            tokenAmount,
            Bonus[phase],
            block.timestamp
        );
    }

    /**
     * @dev Function for rebasing/fixing the ETH/USD rate. Can be called only be the client
     */
    function rebaseEthUSDRate() external onlyBeneficiary whenNotPaused
    {
        uint256 phase = changePhase();

        require(phase != uint256(6), "ICO event ended/inactive");

        ethUSDRate = priceFeedData(ethUSDPricefeedAddress);

        emit Rebase(ethUSDRate, phase, block.timestamp);
    }

    /**
     * @dev Function to change the wallet address of the beneficiary
     */
    function changeBeneficiaryAddress(address payable _beneficiary) external onlyBeneficiary {
        beneficiary = _beneficiary;
    }

    /**
     * @dev Function to change the phase/round of the ICO
     */
    function changePhase() internal returns(uint256) {
        int256 day = int256(block.timestamp.sub(START_TIME).div(1 days));

        if(day >= 0 && day <= 14) return uint256(0);
        else if(day >= 16 && day <= 30) return uint256(1);
        else if(day >= 32 && day <= 38) return uint256(2);
        else if(day >= 39 && day <= 45) return uint256(3);
        else if(day >= 46 && day <= 52) return uint256(4);
        else if(day >= 53 && day <= 61) return uint256(5);
        else {
            if(day >= 62) token.transfer(beneficiary, token.balanceOf(address(this)));
            return uint256(6);
        }
    }

    /**
     * @dev Function for fetching the rate of ETH/USD from the oracle. Disable this when testing locally
     */
    function priceFeedData(address _aggregatorAddress)
        internal
        view
        returns (uint256)
    {
        (, int256 price, , , ) = AggregatorV3Interface(_aggregatorAddress).latestRoundData();

        return uint256(price);
    }

    /// @dev Function only for testing purpose
    function rebase(uint256 _value) external onlyOwner {
        ethUSDRate = _value;
    }
}
