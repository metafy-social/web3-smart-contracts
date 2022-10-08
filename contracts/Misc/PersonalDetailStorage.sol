// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PersonalDetailStorage {

    struct DetailStore {
        string name;
        string email;
        mapping(string => string) data;
        string[] keys;
    }

    mapping(address => DetailStore) details;

    event DataAdded(string key, string value);
    event DataUpdated(string oldKey, string newKey);
    event DataDeleted(string key);
    event BasicDataUpdateSuccessful();

    modifier isKVNonEmpty(string memory key, string memory value) {
        require(bytes(key).length != 0, "The key can't be empty");
        require(bytes(value).length != 0, "The value can't be empty");
        _;
    }

    modifier isKNonEmpty(string memory key) {
        require(bytes(key).length != 0, "The key can't be empty");
        _;
    }

    modifier isKeyUnique(string memory key) {
        require(getIndexOfKey(key) == -1, "A similar key already exists!");
        _;
    }

    function getIndexOfKey(string memory key) private view returns(int) {
        for (uint a = 0; a < details[msg.sender].keys.length; a++) 
            if (keccak256(abi.encodePacked(details[msg.sender].keys[a])) == keccak256(abi.encodePacked(key)))
                return int(a);
        return -1;
    }

    function saveData(string memory key, string memory value) isKVNonEmpty(key, value) isKeyUnique(key) public {
        details[msg.sender].data[key] = value;
        details[msg.sender].keys.push(key);
        emit DataAdded(key, value);
    }

    function deleteData(string memory key) isKNonEmpty(key) public {
        int index = getIndexOfKey(key);
        assert(index != -1);
        delete details[msg.sender].data[key];
        delete details[msg.sender].keys[uint(index)];
        emit DataDeleted(key);
    } 

    function updateData(string memory existingKey, string memory newKey, string memory value) isKVNonEmpty(existingKey, newKey) external {
        deleteData(existingKey);
        saveData(newKey, value);
        emit DataUpdated(existingKey, newKey);
    }

    function getKeys() external view returns(string[] memory) {
        return details[msg.sender].keys;
    }

    function getValue(string memory key) isKNonEmpty(key) external view returns(string memory) {
        return details[msg.sender].data[key];
    }

    function getBasicData() external view returns(string memory, string memory) {
        return (details[msg.sender].name, details[msg.sender].email);
    }

    function setBasicData(string memory name, string memory email) external {
        details[msg.sender].name = name;
        details[msg.sender].email = email;
        emit BasicDataUpdateSuccessful();
    }

}
