/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Vesting{

    /// token not included
    uint public cliff; // delay from start to iniate vesting
    uint public start;  // green signal from owner
    uint public vesting_duration; // time period between 2 vestings usually 1 month
    uint public vesting_cycles; // no of cycles of vesting 
    uint public totalTokens;
    uint public tokensClaimed;
    address public owner; // the contract owner
    address public receiver;


    constructor(
    uint _cliff,
    uint _vesting_duration, 
    address _owner,
    uint _vesting_cycles){
        _owner = msg.sender;
        owner = _owner;
        vesting_duration = _vesting_duration;
        cliff = _cliff;
        start = block.timestamp;
        vesting_cycles = _vesting_cycles;

    }

    // this function will be used to fund the contract
    function fundContract(uint _tokens) public {
        require(msg.sender == owner, "only owner can fund it.");
        totalTokens = _tokens;

        // send tokens from owner to contract using openzeplin

    }
    
    // this claimTokens function will send the tokens to the required user
    function claimTokens()  public {
        require(msg.sender != owner,"owner cannot claim tokens");
        require(block.timestamp > start+cliff, "Vesting hasnt started");
        require(totalTokens > 0, "Contract has not been funded");

        uint time_now = ((block.timestamp)-(start+cliff)); 

        uint token_pending = ((totalTokens/vesting_cycles)*(time_now/vesting_cycles)-tokensClaimed);

        //sending token with openzepplin
        tokensClaimed = tokensClaimed + token_pending;
        
    }

    // this function will change the receiver in the vesting contract    
    function changeReceiver(address newReceiver)  public{
        require(msg.sender == owner, "This can be called by owner only");
        newReceiver = msg.sender;
        totalTokens = 0;
        tokensClaimed = 0;
    }

}
