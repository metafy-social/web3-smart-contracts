// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract GetMemo {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event NewMemo(
        address indexed from,
        uint256 timestam,
        string name,
        string message
    );

    struct Memo {
        address from;
        uint256 timestam;
        string name;
        string message;
    }
    Memo[] memos;
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    //---------------------------
    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = payable(newOwner);
    }

    function whoIsOwner() public view returns (address) {
        return owner;
    }

    //------------------------------------------------
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    function buyMemo(string memory _name, string memory _message)
        public
        payable
    {
        require(msg.value > 0, "You have to pay more ETH ");

        memos.push(Memo(msg.sender, block.timestamp, _name, _message));
        emit NewMemo(msg.sender, block.timestamp, _name, _message);
    }

    //------------------------
    uint256 costSpecialMemo = 0.00299 ether;

    function buyMemo2(string memory _name, string memory _message)
        public
        payable
    {
        require(msg.value > costSpecialMemo, "You have to pay more ETH ");

        memos.push(Memo(msg.sender, block.timestamp, _name, _message));
        emit NewMemo(msg.sender, block.timestamp, _name, _message);
    }

    //--------------------------------------------------------

    function withdrawTips() public {
        require(owner.send(address(this).balance));
    }
}
