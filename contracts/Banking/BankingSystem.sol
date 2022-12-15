// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingSystem {
    mapping(address => uint256) public balanceOf;   // balanceOf, indexed by addresses

    // This is the modifier that will check if the caller has sufficient funds
    modifier hasSufficientFunds(uint _amount) {
        require (balanceOf[msg.sender] >= _amount, "Insufficient Funds");
        _;
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public hasSufficientFunds(_amount) {
        balanceOf[msg.sender] -= _amount;
        (bool sent,) = msg.sender.call{value: _amount}("Sent");
        require(sent, "Failed to Complete");
    }

    // transferAmt function transfers ether from one account to another
    function transferAmt(address payable _address, uint _amount) public hasSufficientFunds(_amount) {
        _address.transfer(_amount);
    }
}
