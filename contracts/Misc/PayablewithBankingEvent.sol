pragma solidity ^0.4.4;
contract PayableWithEventContract{
     address client;
    bool _swich;
    event getDepositData(string _MSG, uint amount,address user);
    function PayableWithEventContract(){
        client= msg.sender;
    }
    function dipositFunds() payable{
        getDepositData("good news , you've got some money  ", msg.value, msg.sender);
    }
    function getFunds() view isAuth returns(uint){
        return this.balance;
    }
    function withdrow (uint amount)isAuth{
      client.send(amount)? _swich =true:_swich=false;
    }
    modifier isAuth(){
      if(  client!=msg.sender){ revert() ;}_;
    }
}
