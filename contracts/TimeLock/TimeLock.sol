// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//0xd9145CCE52D386f254917e481eB44e9943F39138

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract TimeLock{
    
    uint public immutable endTime; //end time
    address payable public immutable owner; 

    constructor(address payable _owner, uint duration_in_seconds){
        endTime = block.timestamp + duration_in_seconds;
        owner = _owner;
    }

    function deposit(address token, uint amount) external {
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    receive() external payable {}

    function withdraw(address token, uint amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp >= endTime, "Cannot withdraw before endTime");

        //number of tokens = 0, so we are just withdrawing ETH
        if(token == address(0)){
            owner.transfer(amount);
        }
        else {
            IERC20(token).transfer(owner, amount);
        }

    }

}