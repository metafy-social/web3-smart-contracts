// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title CommitReveal Pattern
/// @author supernovahs.eth <supernovhs@proton.me>
/// @dev Commit a random secret , and reveal it to prove it .
contract CommitReveal{
/// Storage ///
    mapping (address => bytes32) public commits;
/// Events ///
    event Revealed(address indexed revealer,address indexed commiter , bytes32 data);

/// Commit data in bytes32 

    function commit (bytes32 _data ) external {
/// @dev Update mapping to store
        commits[msg.sender] = _data;
    }

/// Get the hash of data 
    function gethash(bytes32 _data) public view returns (bytes32){
       return  keccak256(abi.encodePacked(address(this),_data));
    }

/// Prove you know the decoded value of the hash
/// @param _commiter address of the commiter 
/// @param _data secret data
    function Reveal(address _commiter,bytes32 _data) external {
        require(commits[_commiter] != 0);/// Should exist 
        bytes32 _commit = commits[_commiter];
        require(_commit == gethash(_data));/// Checks if the sender actually knew the secret
        emit Revealed(msg.sender,_commiter,_data); /// emit it 
    }

}
