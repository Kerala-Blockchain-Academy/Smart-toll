pragma solidity ^0.5.0;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions.
 */
contract Ownable {
  address payable public owner;
  uint tollAmount;
  uint256 contractStart;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   * The toll amount is set as 50 tokens, and the contract start time is set as time of deployment.
   */
   constructor() public {
    owner = msg.sender;
    tollAmount = 50;
    contractStart = now;
    
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can access this function!");
    _;
  }
}
