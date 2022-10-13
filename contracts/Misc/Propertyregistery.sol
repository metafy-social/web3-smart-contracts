// SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <0.9.0;

contract PropertyRegistry{

struct paper{
    address owner;
    string propAddress;
    uint area;
}

mapping (address => paper)public PropertyDB;

function registraiton(string memory _Address,uint _area)public{
PropertyDB[msg.sender].owner=msg.sender;
PropertyDB[msg.sender].propAddress=_Address;
PropertyDB[msg.sender].area=_area;
}



}
