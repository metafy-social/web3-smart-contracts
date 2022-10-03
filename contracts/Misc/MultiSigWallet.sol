// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSigWallet {

    // Events
    event Deposit(address indexed sender, uint amount);
    event Submit(uint);
    event Approve(address indexed owner, uint indexed transectionId);
    event Revoke(address indexed owner, uint indexed transectionId);
    event Execute(uint indexed transectionId);

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }


    // Modifiers 
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Owners required");
        _;
    }

    modifier transectionExists(uint _transactionId) {
        require(
            _transactionId < transactions.length,
            "Transection do not exists"
        );
        _;
    }

    modifier notApproved(uint _transactionId) {
        require(
            !approved[_transactionId][msg.sender],
            "Transection alreay approved"
        );
        _;
    }

    modifier notExecuted(uint _transactionId) {
        require(
            !transactions[_transactionId].executed,
            "Transection already executed"
        );
        _;
    }

    // State variables
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approved;

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "Invalid required number of owners"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );

        emit Submit(transactions.length - 1);
    }

    function approve(uint _transactionId)
        external
        onlyOwner
        transectionExists(_transactionId)
        notApproved(_transactionId)
        notExecuted(_transactionId)
    {
        approved[_transactionId][msg.sender] = true;
        emit Approve(msg.sender, _transactionId);
    }

    function _getApprovalCount(uint _transactionId)
        private
        view
        returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint _transactionId)
        external
        transectionExists(_transactionId)
        notExecuted(_transactionId)
    {
        require(
            _getApprovalCount(_transactionId) > required,
            "Not sufficient approvals for the transection"
        );
        Transaction storage transection = transactions[_transactionId];

        transection.executed = true;

        (bool success, ) = transection.to.call{value: transection.value}(
            transection.data
        );
        require(success, "Transection failed");

        emit Execute(_transactionId);
    }

    function revoke(uint _transactionId)
        external
        onlyOwner
        transectionExists(_transactionId)
        notExecuted(_transactionId)
    {
        require(
            approved[_transactionId][msg.sender],
            "Transection was not approved, hence cannot revoke."
        );
        approved[_transactionId][msg.sender] = false;
        emit Revoke(msg.sender, _transactionId);
    }
}
