 # ICO
 - An ICO task/project for Quillhash internship task.
 - Task details are given in the document **Smart Contract Developer Task 1.**
 - Feel free to reach out to me if there is any issue with the implementation. 
 - I have done a basic barebones testing of the smart contracts. If you feel you found any bugs, reach out to me. It most probably is a feature and not a bug.

 ## Developer Notes
 ---
 I had to make some assumptions which may not conform to the given task. These were necessary due to an ambiguous/undetailed task document. Below given points point out the assumptions and the reason behind them.

 - **Whitelist is controlled by the admin** who deployed the contracts. The admin can choose to transfer ownership to the client if and when necessary. Addresses can be added to the whitelist whenever the client/admin chooses to.

 - **ICO runs for a duration of 62 days** as the difference between the dates mentioned in the task document correspond to 62 days.
 
 - **2 days of ICO inactive period** has been set purposefully. The reason behind that being , those 2 days can be used by the admin/client (whoever controls the whitelist) to add investors to the whitelist.

 - **An investor can buy the tokens however many times he/she wants to** with a minimum investment amount being $500 each time.

 - **The client has to rebase the ETH/USD rate manually.** The task document mentions that 

    > The conversion of ETH to USD shall be dynamic (Use oracles) based on weekly price-fixing by the client.

    So if the client chooses to fix the rate of ETH/USD every week, he/she can do so. This doesn't mean that a client can only fix the rate once per week. He/she can do this any number of times during the ICO period given that ICO is not paused/stopped. The function to do this fetches the rate using **Chainlink pricefeed oracles** and hence, no arbitrary values for the rate can be set by the client.

 - **The ETH sent to the contract is transferred to only one wallet of the client at any given time.** The task document mentions that
    
    > All ETH raised in the ICO must be immediately made available in each respective crypto wallet as specified by the client without any delays, and the contract shall not hold any funds.

    But it is unclear as to how the client wants to distribute the ETH to the wallets (Should the distribution be done equally or should some percentage of the total amount go to a particular wallet ?). Due to this, I chose to transfer the ETH amount deposited per investment to just one wallet of the client. I have also provided a function to change this wallet address if the client wishes to do so. 

    **Note:** If multiple wallet addresses are given, it isn't efficient, in terms of gas cost, to calculate the amount for each address and distribute the ETH as this would require a loop to be executed. A better way to do this is by using a ***Merkle Tree Distributor.*** 

 - **Admin controls the function to pause or stop the ICO.** This ability can be transferred to the client if and when necessary.

 - **End time of the ICO isn't ***explicity*** mentioned in the ICO smart contract.** The contract will execute as per the task given in the document. I decided not to include a special variable for the end time since it is not used anywhere in the contract and it will consume unnecessary gas to just declare a state variable for it.

 - **Softcap is not mentioned in the ICO smart contract.** This is because it isn't clear how a softcap will be used in the ICO smart contract according to the task given in the document. If all you want to do is to get the amount of ETH deposited in the ICO smart contract in USD, it is better to use the events emitted and index it using **The Graph Protocol** or some other similar service. A variable for softcap will only consume unnecessary gas.

 - **Anyone can participate in the crowdsale phase of the ICO.** This condition can be changed by removing if condition (mentioned in comments in the smart contract file)in the ICO smart contract.

 - **The last phase/stage of the crowdsale runs for 9 days.** Since the task document mentions that a crowdsale should run for 30 days, the bonus structure which is applicable for the 4th week is used in these 2 extra days.

 ## Steps to run the code
 ---
 1. Install all the dependencies mentioned in the **package.json**.
 2. The tests must be run in mainnet fork mode using **ganache-cli**. To do this, you will require an API key from [Alchemy](https://www.alchemy.com/).
 3. Use this key in place of the placeholder **{ALCHEMY_URL} in package.json scripts**.
 4. Make sure you installed the package `npm-run-all`
 5. Run the code: `run-p fork test`
 6. If there is an error while running the above mentioned code then run the codes separately as `npm run fork` in one terminal and `npm run test` in another terminal.

