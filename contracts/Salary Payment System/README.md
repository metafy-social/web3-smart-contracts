
# Bulk Salary Payment Smart Contract

Salary Payment Smart contract is Bulk transfer system where Employees get Monthly bases salary if Company failed to pay money and comnpany payes compensation for every day.


# Functions for the companies
- depositMoney  - Owner can send the funds to Contract
- registerEmployee - Owner can register new employee with their address and salary
- ChangeSalary - Owner can employee salary increase or decrease

# Functions for Employee
- SendSalary  - Any employee can execute these after 1 month then bulk transfer of funds  will added to every Employee Account 
- Latepayment - if employee doesn't get their salary after month they will get compensation as per days
- CompanyWalletBalance : both  can use this function, which returns the total balance of the contract

# Compensation Fund  
- **For Everyone 1 day compensation fund is 0.001 ether**
- On Calculating number of days late from actual day(pay day)
- compensionTotal = LateDays * compensation(0.001) ether;
- SalaryPerPerson =  compensationTotal + employee salary

```
    
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

```


## Feedback

If you have any feedback, please reach out to me twitter or linkedin
