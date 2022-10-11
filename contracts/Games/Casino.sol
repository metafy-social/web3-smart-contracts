// SPDX-License-Identifier: MIT
// Number Guessing Game in Casino
// Here the player has to give a number between 1 to 10, and the amount he will bet. 
// we will generate a random number between 1 to 10 and if the number matches with player's number then we will return 10X of the amount he bets and if it's not the same number then he gets 10% of his bet.


pragma solidity ^0.8.0;

contract Casino{
    uint public numberInput;
    uint public amountInput;


    function setValues(uint  Number, uint  Amount) public {
        numberInput=Number;
        amountInput=Amount;

    }


    function play() public view returns (uint){
        if(numberInput == uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % 10 +1){
            return amountInput*10;
        }
        else{
            return amountInput/10;
        }

    }
}
