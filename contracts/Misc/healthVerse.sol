// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BlockHealth {

    // Declaring the public variables to store basic info about the contract
    string public aboutUs = "Secure decentralized electronic health records sharing system based on blockchains";
    address public owner;
    mapping(address => bool) public managers;
    
    // Declaring the private variables storing the data of the patients mapped with the doctors
    mapping(address => address[]) patientList;
    mapping(address => string[]) medicalRecords;

    // Modifier to give access only to the owner of the contract
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner has access to this");
        _;
    }

    // Modifier to only give access to Managers and the Owner of the contract
    modifier restricted(){
        require(managers[msg.sender] || owner == msg.sender, "Only allowed managers or the owner can perform this operation");
        _;
    }

    // Modifier that only allows patients assigned doctor to see reports
    modifier onlyDoctor(address patient){
        bool allowed = false;
        for(uint i; i < patientList[msg.sender].length; i++){
            if(patientList[msg.sender][i] == patient){
                allowed = true;
                break;
            }
        }
        require(allowed || owner == msg.sender, "You cannot access someone's private information");
        _;
    }

    constructor(){
        // Setting the owner of the contract as who deploys it
        owner = msg.sender;
    }

    // Function to add a Medical Report to the database
    function addRecord(address patient, address doctor, string memory url) public restricted {
        bool isThere = false;
        for(uint i; i < patientList[doctor].length; i++){
            if(patientList[doctor][i] == patient){
                isThere = true;
                break;
            }
        }
        if(isThere == false){
            patientList[doctor].push(patient);
        }

        medicalRecords[patient].push(url);

    }

    // Function to get the list of patients of a doctor
    function getPatients(address doctor) public view restricted returns(address[] memory){
        return patientList[doctor];
    }

    // Function to get the list of my patients ( function which can be called from the doctors account )
    function getMyPatients() public view returns(address[] memory){
        return patientList[msg.sender];
    }

    // Function to get all the medical reports for the doctor to see
    function getRecords(address patient) public view onlyDoctor(patient) returns(string[] memory){
        return medicalRecords[patient];
    }

    // Function to get all the medical reports for the patients use
    function getMyRecords() public view returns(string[] memory) {
        return medicalRecords[msg.sender];
    }

    // Function to assign a new manager
    function addManager(address newManager) public onlyOwner {
        managers[newManager] = true;
    }

    // Function to transfer the ownership of this contract 
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // Function to revoke manager access from anyone
    function deleteManager(address oldManager) public onlyOwner {
        managers[oldManager] = false;
    }

}