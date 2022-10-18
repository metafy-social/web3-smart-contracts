// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 contract SalaryPaymentSystem{

     struct Employee{
         address employeeAdd;
         uint salary;
    }


    uint id;
    address owner;
    uint public finaltime;
    

    constructor(){
        owner=msg.sender;
        finaltime = block.timestamp + 30.42 days;
    }

    mapping(uint=>Employee) company_Wallet;
    mapping(address=>uint) salaryInfo; 


    modifier onlyOwner{
        require(msg.sender==owner,"your are not owner");
        _;
    }
    

    function depositMoney() payable public onlyOwner {
        require(msg.value>0,"check balance once");
    }

    function registerEmployee(address _employeeAdd,uint _salary) public onlyOwner{
        require(_salary>0,"Enter the salary of employee");
        require (salaryInfo[_employeeAdd] == 0,"You can't Register employee twice");
        company_Wallet[id] = Employee(_employeeAdd,_salary);
        salaryInfo[_employeeAdd] = _salary;
        ++id;
    }
    
    function SendSalary() public payable {
        require(block.timestamp > finaltime ,"You Can't get Salary Before Payday");
        require(block.timestamp - finaltime < 3 days ,"Your company is doesn't send money on payday you will receive additional funds! use click Latepayment function");
        uint limit = id+1;   
        for (uint i=0 ; i < limit ; i++){
            address  add = (company_Wallet[i].employeeAdd);
            uint SalaryPerPerson = company_Wallet[i].salary * 1 ether; // units are in ether converting 
            payable(add).transfer(SalaryPerPerson);
        }
        finaltime = block.timestamp + 30.42 days;
    }


     
    uint constant public compensation = 0.001 ether;

    function Latepayment() public payable { 
        require(block.timestamp - finaltime > 1 days,"No late Payment option");
        uint LateDays  = (block.timestamp - finaltime) / 1 days ;
        uint compensationTotal = LateDays * compensation; // for each day compensation
        uint limit = id+1;
        for (uint i=0 ; i < limit ; i++){
            address  add = (company_Wallet[i].employeeAdd);
            uint SalaryPerPerson = company_Wallet[i].salary * 1 ether + compensationTotal; // units are in ether converting 
            payable(add).transfer(SalaryPerPerson);
        }
        finaltime = block.timestamp + 100 seconds;

    }

    function CompanyWalletBalance() public view returns(uint){
        return address(this).balance;
    }

    function ChangeSalaryofEmployee(address _empadd, uint _newsalary) public  onlyOwner{
        require(salaryInfo[_empadd]>0,"Register for a employee");
        require(_newsalary>0,"Please check newsalary balance");
        salaryInfo[_empadd] = _newsalary;
    }
 }
