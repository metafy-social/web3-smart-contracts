// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dns{
    
    
    struct Domain{
        string domainName;
        string A_Record;
        string CNAME;
        string TXT;
        string NS_Record;
        string SOA_Record;
        bool exists;
    }
    
    mapping (string => Domain) public nameserver;
    
    
    
    function addDomain(string memory _domainName , string memory _A_Record , string memory _CNAME, string memory _TXT ,string memory _NS_Record, string memory _SOA_Record) public returns(bool) {
        require(nameserver[_domainName].exists == false,"IP mapping already exists");
        
        Domain memory new_domain = Domain(_domainName,_A_Record,_CNAME,_TXT,_NS_Record,_SOA_Record,true);
        nameserver[_domainName] = new_domain;
        
        return true;
    }
   
    
    function dnsLookup(string memory _domainName) public view returns (string memory,string memory,string memory,string memory, string memory){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        return ( nameserver[_domainName].A_Record, nameserver[_domainName].CNAME, nameserver[_domainName].TXT,nameserver[_domainName].NS_Record,nameserver[_domainName].SOA_Record);
    }
    
    function modifyARecord(string memory _domainName, string memory _A_Record) public returns (bool){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        nameserver[_domainName].A_Record = _A_Record;
        return true;
        
    }
    
    function modifyCNAMERecord(string memory _domainName, string memory _CNAME) public returns (bool){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        nameserver[_domainName].CNAME = _CNAME;
        return true;
        
    }
    
    function modifyTXTRecord(string memory _domainName,string memory _TXT) public returns (bool){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        nameserver[_domainName].TXT = _TXT;
        return true;
    }
    
    function modifyNSRecord(string memory _domainName,string memory _NS_Record) public returns (bool){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        nameserver[_domainName].NS_Record = _NS_Record;
        return true;
    }
    
    function modifySOARecord(string memory _domainName,string memory _SOA_Record) public returns (bool){
        require(nameserver[_domainName].exists == true,"DNS not configured yet for the domain");
        
        nameserver[_domainName].SOA_Record = _SOA_Record;
        return true;
    }
    
}
