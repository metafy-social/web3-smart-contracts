// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract SharedWallet {
    address private _owner;

    mapping(address => bool) private _owners;

    // required owner of the contract
    modifier isOwner() {
        require(msg.sender == _owner, "Not a contract owner");
        _;
    }

    // checks if a user is contract owner or one of owners of a shared wallet
    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender], "Not contract owner or part of owners of shared wallet");
        _;
    }

    event DepositFunds(address from, uint256 amount);
    event WithdrawFunds(address from, uint256 amount);
    event TransferFunds(address from, address to, uint256 amount);

    constructor() {
        _owner = msg.sender;
    }

    // add an owner of shared wallet
    function addOwner(address owner) public isOwner {
        _owners[owner] = true;
    }

    // remove an owner of shared wallet
    function removeOwner(address owner) public isOwner {
        _owners[owner] = false;
    }

    // Add the deposit into shared wallet
    receive() external payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    // withdraw fund from the shared wallet into the signer of transaction
    function withdraw(uint256 amount) public validOwner {
        require(address(this).balance >= amount);
        payable(msg.sender).transfer(amount);
        emit WithdrawFunds(msg.sender, amount);
    }

    // transfer fund from the shared wallet into another address
    function transferTo(address payable to, uint256 amount) public validOwner {
        require(address(this).balance >= amount);
        payable(to).transfer(amount);
        emit TransferFunds(msg.sender, to, amount);
    }
}
