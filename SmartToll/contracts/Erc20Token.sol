pragma solidity ^0.5.0;

import "./Ownable.sol";

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
* @title ERC20Interface
* @dev Contract Interface defining ERC20 protocols being used in the contract.
*/

contract ERC20Interface {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );
}

/**
* @title ERC20
* @dev Contract defining functions of the ERC20 token.
*/

contract ERC20 is Ownable, ERC20Interface {
    
  using SafeMath for uint256;
  mapping(address => uint256) balances; //to store token balances of all accounts.
  address public contractorGlobal; //saving contractor address globally to use throughout the contract.
  uint256 totalSupply_;
  
  /**
  * @dev Total number of tokens in existence.
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
  /**
  * @dev Public function that transfers tokens to a specified address.
  * @param _to The address to transfer tokens to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    //Checking if the to address is a valid address.
    require(_to != address(0), "Invalid Address, cannot call Transfer!");
    //Condition for transferring tokens to Contract Address (paying toll, called by user).
    if(_to == address(this)) {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[address(this)] = balances[address(this)].add(_value);
      emit Transfer(address(this), _to, _value);
    }
    //Condition for withdrawing Tokens (called by Contractor).
    else if (contractorGlobal == msg.sender) {
      balances[address(this)] = balances[address(this)].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(address(this), _to, _value);
    }
    //Condition for user buying tokens (called by user).
    else {
      require(msg.sender == _to, "User can purchase tokens only for themselves!");
      balances[owner] = balances[owner].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(owner, _to, _value);
      return true;
    }
  }
  
  /**
  * @dev Public function that returns the balance of the specified address.
  * @param _owner The account address of whose balance is being checked.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an owner. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _owner The account that will receive the created tokens (owner).
   * @param _amount The amount that will be created.
   */
  function _mint(address _owner, uint256 _amount) internal {
    require(_owner != address(0));
    totalSupply_ = totalSupply_.add(_amount);
    balances[_owner] = balances[_owner].add(_amount);
    emit Transfer(address(0), _owner, _amount);
  }

}

/**
* @title Token
* @dev Contract defining the token name, symbol, initial supply of tokens.
*/
contract Token is ERC20 {

  string public constant name = 'TollCoin';
  string public constant symbol = 'SMC';
  uint8 public constant decimals = 3;

  /**
   * @dev The Token constructor sets the Token parameters.
   */
  constructor() public payable { 
    uint premintAmount = 50*10**uint(decimals);
    totalSupply_ = totalSupply_.add(premintAmount);
    balances[msg.sender] = balances[msg.sender].add(premintAmount);
    emit Transfer(address(0), msg.sender, premintAmount);
  }
}


