// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Lottery {

    address public manager;
    address[] public players;

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0.005 ether);

        players.push(msg.sender);
    }

    function playersData() public view returns(address[] memory){
        return players;
    }

    function random() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner() public restricted {
        uint index = random() % players.length;
        payable(players[index]).transfer(address(this).balance);

        players = new address[](0);
    }


}