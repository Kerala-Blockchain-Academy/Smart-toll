**# SmartToll**

A blockchain-based Tollbooth Management System

The Indian Govt. permits the contractor who has won the contract for building highways to setup toll booths on the highway once construction is completed, and collect toll from vehicles using the particular stretch of highway, for a designated period of time. There is currently no check in place to enforce this time limit, and often, there are contractors who keep illegally collecting toll many years after their contract has expired. The proposed solution is a blockchain network created with the time period set by the Govt., there will be no further transactions permitted on the network once the contract expires. The users (vehicle owners\drivers) who frequent the highway are able to purchase tokens in advance (prepaid) and the toll amount is deducted from their balance when they pass through the toll booths. The contractor is allowed to withdraw limited amounts from the toll collected, and once the contract expires, they can withdraw the entire remaining amount.

**System requirements:**

1. Operating system: Ubuntu 16.04
2. System RAM: 4 GB or above (recommended 8 GB)
3. Free System storage: 4 GB on /home

**Installation prequisites:**

1. Ensure that NodeJS is installed in the system. For more information about NodeJS, go to https://nodejs.org. To check if installed, open a terminal window:
   $ node -v
2. If NodeJS is not installed, go to https://nodejs.org and download the compatible version based on system OS, or in a terminal window:
   $ sudo apt-get install -y nodejs
3. Ensure that Truffle is installed. Truffle Suite helps to develop Dapps easily. For more information, go to https://truffleframework.com/. To check if installed, in terminal window:
   $ truffle version
4. If Truffle is not installed, in terminal window:
   $ npm install -g truffle
5. Ensure that ganache-cli is installed. Ganache CLI is the latest version of TestRPC: a fast and customizable blockchain emulator.
   $ npm install -g ganache-cli
6. Ensure that geth is installed. Geth is the official Golang implementation of the Ethereum protocol. To check, in a terminal window:
   $ geth version
7. To install geth, in a terminal window:
   $ sudo apt-get install software-properties-common
   $ sudo add-apt-repository -y ppa:ethereum/ethereum
   $ sudo apt-get update
   $ sudo apt-get install ethereum
8. Ensure that Go and C compilers are installed. In a terminal window:
   $ sudo apt-get install -y build-essential

**Installation/Set-up instructions (ganache):**

1. Open the Dapp project folder in VS Code.
2. Open a terminal window in the project folder.
   $ npm rebuild //(to resolve node version incompatibility issues)
3. Open another terminal window. Run ganache-cli.
   $ ganache-cli
4. Back in original terminal window, run truffle migrate.
   $ truffle migrate --reset
5. Copy deployed contract address (of Buy) from truffle migrate window and replace in index.js file (line 22). Save file.
6. In original terminal window, start server.
   $ npm start
7. Open a browser window. Go to https://localhost:3000
8. Copy individual addresses from ganache terminal and use the Dapp features.
9. For testing, open a terminal window, run test.
   $ npm test
10. The contract is set to expire in 6 minutes, if more time is needed to test the functionalities, change this in payToll function (line 60) and withdrawToken function (line 97).
11. Use CTRL+C to exit the project from respective terminal windows.

**Installation/Set-up instructions (geth):**

1. Open the Dapp project folder in VS Code. Comment ganache deployment details in truffle-config.js and uncomment geth deployment details. Save file.
2. Open a terminal window in the project folder.
   $ npm rebuild //(to resolve node version incompatibility issues)
3. Open another terminal window inside geth folder (BlockchainData).
   $ geth --identity "miner" --networkid 4002 --datadir ownerAccount --nodiscover --mine --rpc --rpcport "8545" --port "8191" --unlock 0 --password password.txt --ipcpath "~/.ethereum/geth.ipc" --rpccorsdomain "*" --rpcapi "db,eth,net,web3,personal"
4. Open another terminal window inside geth folder (BlockchainData). Open geth console.
   $ geth attach
5. Start mining in geth console.
   $ miner.start()
6. Back in original terminal window, run truffle migrate.
   $ truffle migrate --reset
7. Copy deployed contract address (of Buy) from truffle migrate window and replace in index.js file (line 22). Save file.
8. In original terminal window, start server.
   $ npm start
9. Open a browser window. Go to https://localhost:3000
10. Copy individual addresses from 'Geth Account Details.txt' file and use the Dapp features.
11. Unlock respective accounts (giving the account details like in below example) in geth console window using passwords given in the text file, when using 'Buy Tokens', 'Pay Toll', 'Withdraw Tokens' functions.
   $ personal.unlockAccount(eth.accounts[1])
12. To exit the project, stop the mining process in geth console window. Then give CTRL+C in other terminal windows to exit.
   $ miner.stop()
13. The contract is set to expire in 6 minutes, if more time is needed to test the functionalities, change this in payToll function (line 60) and withdrawToken function (line 97).

**Contract conditions:**

* Contractor needs to be registered first before registering users. Owner (account[0]) cannot be registered as contractor.
* Owner or contractor cannot be registered as User.
* User needs to buy tokens paying ether. Owner or contractor cannot buy tokens.
* Once the user has paid toll, they need to wait 1 minute before paying toll again.
* Contractor can withdraw tokens only if contract balance is greater than withdrawal limit (80 tokens), so at least two users need to pay toll (toll amount is 50 tokens). Contractor cannot withdraw greater than 80 tokens while contract is live. Once contract has expired, they can withdraw the whole contract balance.
* The contract terminates in 6 minutes, after which, toll payments are not possible. Contractor can still withdraw tokens if contract balance is greater than 0.
* Only contractor or owner can view Toll History (toll receipts of all payments made).
