// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract ListCrowdFunding{
    CrowdFunding[] public crowdfund;
    function create() public{
     crowdfund.push(new CrowdFunding());
    }
}

contract CrowdFunding{
    string public victimName;
    string public description;
    uint public deadLine;
    uint public target;
    address public owner;
    uint public amountRaised;
    uint public minContribution;

    address payable public victimAddress;
    mapping(address=>uint) MoneyPoll;
    
    
    constructor(){
        owner = msg.sender;
    }
    /**
     * registration for crowdfunding with name, descrition, victimaddress, target amount and mininum contribution
       deadline is unix time stand 
    */
    function register(string calldata _victimName ,string calldata _description,address  _victimAddress, uint _target,uint _minContribution,uint _deadLine) public {
        victimName = _victimName;
        description = _description;
        victimAddress = payable(_victimAddress);
        minContribution = _minContribution;
        target = _target;
        deadLine = _deadLine;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"you don't have permission of owner");
        _;
    }
    
    function contribute() payable public {
        require(msg.value>0 && msg.value > minContribution,"Min contribution set");
        require(block.timestamp < deadLine,"Deadline is completed please contact with owner to extend the timeperiod");
        MoneyPoll[msg.sender] = msg.value;
        amountRaised+=msg.value;
    }


    /**
     * When target amount is raised then any one can excute 
      transferring funds to victim address onlyif (victim address!= owner address)
    */
    function TransferMoneyToVictim() public payable  {
        require(owner!=victimAddress,"Owner can't send money this his account");
        require(deadLine < block.timestamp,"Deadline is not completed");
        victimAddress.transfer(address(this).balance);
    }

    function currentTime() public view  returns (uint){
        return block.timestamp;
    }

    /**
     * Only owner can extend deadline only if
      - deadline is completed and raised amount is insufficient 
    */
    function ExtendDeadline(uint newDeadline) public onlyOwner{
        require(amountRaised<target,"Goal is completed there no need for extending for deadline");
        require(deadLine<newDeadline,"You can't set the deadline in past time ");
        deadLine = newDeadline;
    }
    
    function isgoalCompleted() public  view returns(bool){
        if (amountRaised>=target) return true;
        else return false;
    }

    function personContribution(address person)  public view  returns(uint){
        return MoneyPoll[person];

    }
    function getBalance()  public view  returns(uint){
        return amountRaised;
    }
    
}

//1139483- without currtime func
//1183635- with currtime func
//1137305- 1st gas opt
//1106534- currtime not only owner
//1104204- removed amountRaised=0 in constructor

