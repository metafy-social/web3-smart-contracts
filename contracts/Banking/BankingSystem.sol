// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingSystem {

    mapping(address => uint256) public balanceOf;   // balanceOf, indexed by addresses

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public {
        require (balanceOf[msg.sender] >= _amount, "Insufficent Funds");
        balanceOf[msg.sender] -= _amount;
        (bool sent,) = msg.sender.call{value: _amount}("Sent");
        require(sent, "Failed to Complete");
    }

    // transferAmt function transfers ether from one account to another
    function transferAmt(address payable _address, uint _amount) public {
        require (balanceOf[msg.sender] >= _amount, "Insufficent Funds");
        _address.transfer(_amount);
    }

}
