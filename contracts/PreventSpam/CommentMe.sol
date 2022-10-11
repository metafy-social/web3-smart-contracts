// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract CommentMe {
    //It will help us in getting total comments, so far.
    uint256 totalComments;

    //Creating event, it helps in logging(cheap storage)
    event NewComment(address indexed from, uint256 timestamp, string message);

    //Creating struct(custom data type)
    struct Comment {
        address commenter; // The address of the user who commented.
        string message; // The message the user sent.
        uint timestamp; // The timestamp when the user commented.
    }

    // declare a variable comments that lets me store an array of structs.
    Comment[] comments;

    //Creating map data structure to associate an address with a number, It will help in checking spammers and preventing spam messages.
    mapping(address => uint256) public lastCommentedAt;

    function comment(string memory _message) public {
        //Making sure that the commenter/Spammer, should wait atlest 1 day(Customizable) before next comment, Hence preventing spam.
        require(
            lastCommentedAt[msg.sender] + 24 hours < block.timestamp,
            "Wait for a day, before next comment."
        );

        lastCommentedAt[msg.sender] = block.timestamp;

        totalComments += 1;

        comments.push(Comment(msg.sender, _message, block.timestamp));

        emit NewComment(msg.sender, block.timestamp, _message);
    }

    function getAllComments() public view returns (Comment[] memory) {
        return comments;
    }

    function getTotalComments() public view returns (uint256) {
        return totalComments;
    }
}
