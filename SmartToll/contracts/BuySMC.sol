pragma solidity ^0.5.0;

import "./Erc20Token.sol";

/**
* @title Buy
* @dev Contract defining functionalities of the Toll Management System.
*/

contract Buy is Token {

    struct users {
        string vehicleNum;
        uint256 userBalance;
        uint256 tollReset;
        bool userExists;
    }
    
    uint256[] tollReceipts; //array to store all the Toll Receipts
    mapping (address => users) public UserReg; //mapping to store all registered Users in a struct
    uint public withdrawAllowance = 80; //limiting amount contractor can withdraw at a time
    bool public contractorExists = false; //flag to check if a contractor hsa been registered already

    /**
    * @dev Public function to register Contractor, restricted access to owner using modifier
    * @param _contractor  pass the address of contractor to be registered
    * @return A bool value to show function execution status
    */
    function registerContractor (address _contractor) public onlyOwner returns (bool) {
        require(owner != _contractor, "Owner cannot register as Contractor!");
        require(contractorExists == false, "Contractor already registered!");
        contractorGlobal = _contractor;
        contractorExists = true;
        return true;  
    }
    
    /**
    * @dev Public function to register new User, restricted access using modifier
    * @param _user pass the address of user to be registered
    * @param _vehicleNum pass the vehicle number to be registered
    * @return A bool value to show function execution status
    */
    function registerUser (address _user, string memory _vehicleNum) public onlyOwner returns (bool) {
        require(_user!= owner, "Owner cannot be registered as User!");
        require(contractorGlobal != address(0), "Contractor has not been registered yet");
        require(_user!= contractorGlobal, "Contractor cannot be registered as User!"); 
        require(UserReg[_user].userExists == false, "User already exists!");
        UserReg[_user] = users(_vehicleNum, 0, now.sub(1 minutes), true);
        return true;
    }

    /**
    * @dev Public function to pay tolls
    * @param _user pass the user address to pay tolls
    * @return A bool value to show function execution status
    */
    function payToll (address _user) public returns (bool){
        //Contract termination is set as 6 minutes for testing. In live project, deployer will define
        //this value at the time of contract deployment.
        require((contractStart.add(6 minutes)) >= now, "Contract has ended, toll collection is not possible!");
        require(contractorGlobal!=address(0), "Contractor not registered yet!");
        require(msg.sender == _user, "Only users can pay toll!");
        require(msg.sender != owner, "Owner cannot call Pay toll");
        require(_user!= owner, "Owner cannot pay toll!");
        require(msg.sender != contractorGlobal, "Contractor cannot call Pay toll");
        require(_user!= contractorGlobal, "Contractor cannot pay toll!"); 
        require(UserReg[_user].userBalance >= tollAmount, "Insufficient balance or unregistered user!");
        // below condition is meant to be 24 hours in live project, as user needs to pay toll only once in 
        //24 hours, but put as 1 minute for testing purposes.
        require((UserReg[_user].tollReset).add(1 minutes) <= (now), "Please wait 1 minute, already paid toll!");
        transfer(address(this), tollAmount);
        UserReg[_user].userBalance = balances[_user];
        uint256 _tollReceipt = uint256(keccak256(abi.encodePacked(_user, now))) % 100000000000;
        tollReceipts.push(_tollReceipt);
        UserReg[_user].tollReset = now;
        return true;
    }
    
    /**
    * @dev Throws if called by any account other than the contractor.
    */
    modifier onlyContractor{
        require(contractorGlobal!=address(0), "Contractor not registered yet!");
        require(msg.sender != owner, "Owner cannot access this function!");
        require(msg.sender == contractorGlobal, "Only Contractor can access this function!");
        _;
    }
    
    /**
    * @dev Public function to withdraw tokens, access restricted using modifier
    * @param _value Number of tokens requested by contractor
    * @return A bool value to check function execution status
    * Withdrawal is restricted to 80 while the contract is live. Once it terminates, the contractor can withdraw
    * the whole amount without limitations.
    */
    function withdrawToken (uint256 _value ) public onlyContractor returns (bool) {
        require(_value <= withdrawAllowance || (contractStart.add(6 minutes) <= now), "Withdrawal limit is 80 tokens!");
        require(balances[address(this)] >= _value, "Contract balance is less than requested amount!");
        contractorGlobal = msg.sender;
        transfer(msg.sender,_value);
        return true;  
    }

    /**
    * @dev Public function to view registered user details
    * @param _user pass user address to view details
    * @return An address, string, and uint256 representing registered user details
    */
    function viewUsers (address _user) public view returns (address, string memory, uint256){
        require(_user != address(0), "Invalid address!");
        require(UserReg[_user].userExists == true, "User has not been registered yet!");
        return (_user, UserReg[_user].vehicleNum, UserReg[_user].userBalance);
    }

    /**
    * @dev Public function to buy tokens 
    * @param _user pass user address who wants to purchase tokens
    * @param _tokens number of tokens the user wishes to purchase
    * If the user requests more tokens than is available in the contract, the mint function is called to mint new
    * tokens to satisfy the user request, and have an additional 10000 tokens in the total supply.
    */
    function buyTokens (address _user, uint _tokens) public payable {
        require(msg.sender != owner, "Owner cannot call Buy Tokens");
        require(_user != owner, "Owner cannot purchase Tokens!");
        require(msg.sender != contractorGlobal, "Contractor cannot call Buy Tokens");
        require(_user!= contractorGlobal, "Contractor cannot purchase Tokens!"); 
        require(UserReg[_user].userExists == true, "User doesn't exist!");
        require(_user.balance > (_tokens.mul(0.01 ether)), "User doesn't have sufficient Ether balance!");
        if(balances[owner] <= _tokens) {
            _mint(owner, _tokens.add(10000));
        }
        owner.transfer(_tokens.mul(0.01 ether));
        transfer(_user, _tokens);
        UserReg[_user].userBalance = UserReg[_user].userBalance.add(_tokens);
    }
    /**
    * @dev Public function to view Toll Payment history
    * @param _user pass owner or contractor address to view complete toll payment history
    * @return An array of uint256 to return the toll receipts
    */
    function viewHistory (address _user) public view returns (uint256[] memory){
        require(_user == owner || _user == contractorGlobal, "Only Owner or Contractor can view history!");
        return tollReceipts;
    }
    /**
    * @dev Public function to check if contractor has been registered
    * @return A bool value to check if contractor exists
    */
    function existContractor () public view returns (bool) {
        return contractorExists;
    }
    
}

