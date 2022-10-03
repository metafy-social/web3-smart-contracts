// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PasswordManager {

    struct Password {
        uint id;
        string service;
        string login;
        string password;
    }

    mapping(address => mapping(uint => Password)) passwords;
    mapping(address => uint[]) ids;

    event passwordAdded(string service, string login, string password, uint id);
    event passwordUpdated(string service, string login, string password, uint id);
    event passwordDeleted(uint id);

    modifier entryExists(uint id) {
        require(passwords[msg.sender][id].id != 0, "The requested entry was not found!");
        _;
    }

    modifier isNotEmpty(string memory service, string memory login, string memory password) {
        require(bytes(service).length != 0, "The service name can't be empty.");
        require(bytes(login).length != 0, "The login can't be empty.");
        require(bytes(password).length != 0, "The password can't be empty.");
        _;
    }

    function addPassword(string memory service, string memory login, string memory password) isNotEmpty(service, login, password) public {
        uint id = block.timestamp;
        ids[msg.sender].push(id);
        passwords[msg.sender][id] = Password(id, service, login, password);
        emit passwordAdded(service, login, password, id);
    }

    function getAllPasswordIds() external view returns(uint[] memory) {
        return ids[msg.sender];
    }

    function getPasswordById(uint id) entryExists(id) external view returns(Password memory) {
        Password memory p = passwords[msg.sender][id];
        return p;
    }

    function updatePassword(string memory service, string memory login, string memory password, uint id) entryExists(id) isNotEmpty(service, login, password) public {
        Password memory p = passwords[msg.sender][id];
        p.login = login;
        p.service = service;
        p.password = password;
        passwords[msg.sender][id] = p;
        emit passwordUpdated(service, login, password, id);
    }

    function deletePassword(uint id) entryExists(id) public {
        delete passwords[msg.sender][id];
        for (uint x=0; x<ids[msg.sender].length; x++) {
            if (ids[msg.sender][x] == id)
                delete ids[msg.sender][x];
        }
        emit passwordDeleted(id);
    }

}