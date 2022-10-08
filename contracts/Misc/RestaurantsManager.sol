// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Ballot {

    // Review structure
    struct Review{
        uint bill_id;
        address restaurant_id;
        uint curr_time;
        uint rating_value ;
        bytes32 comment;
    }
    
    uint valid_duration = 3 days;
    
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
        result := mload(add(source, 32))
        }
    }
    
    // Restaurant structures
    struct Restaurant{
        address restaurant_id;
        uint total_rating_value;
        uint number_of_votes;
    }

    address public chairperson=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    
    // A dynamically-sized array of `restaurant` structs.
    Restaurant[] restaurants;
    uint[] bill_ids;
    uint[] expiry_times;
    address[] restaurant_ids;
    mapping(address => uint) rinds;
    mapping(address => bytes32[]) rcomments;
    
    function addRestaurant(address _restaurant_id) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can add a restaurant."
        );
        // the address has to be new to be added
        if (rinds[_restaurant_id] >= restaurants.length){
            restaurants.push(Restaurant(
            {
               restaurant_id: _restaurant_id,
               total_rating_value: 0,
               number_of_votes: 0
            }));
            rinds[_restaurant_id] = restaurants.length-1;   
        }
    }
    
    function addBillID(uint bill_id, address restaurant_id) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can add a restaurant."
        );
        bill_ids.push(bill_id);
        expiry_times.push(block.timestamp + valid_duration);
        restaurant_ids.push(restaurant_id);
    }
    
    function addReview(uint bill_id, 
        address restaurant_id,
        uint rating_value,
        string memory comment) 
    public {
        uint i;
        for(i=0; i < bill_ids.length; i++){
            if(bill_ids[i] == bill_id)
            {
                if(expiry_times[i] > block.timestamp && 
                restaurant_ids[i] == restaurant_id)
                {
                    uint ind = rinds[restaurant_id];
                    if (rating_value>5){
                        restaurants[ind].total_rating_value += 5;
                    }
                    else{
                        restaurants[ind].total_rating_value += rating_value;
                    }
                    restaurants[ind].number_of_votes += 1;
                    rcomments[restaurant_id].push(stringToBytes32(comment));
                    
                    // following will work even if length is 1
                    bill_ids[i] = bill_ids[bill_ids.length-1];
                    restaurant_ids[i] = restaurant_ids[bill_ids.length-1];
                    expiry_times[i] = expiry_times[bill_ids.length-1];
                    delete bill_ids[bill_ids.length-1];
                    delete restaurant_ids[bill_ids.length-1];
                    delete expiry_times[bill_ids.length-1];
                }
            }
        }
    }
    
    function calcul(uint a, uint b, uint precision) private pure returns ( uint) {
        return a*(10**precision)/b;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    string public avg_rating_requested;
    uint public number_of_ratings_requested;
    string public comments_requested=''; 
    
    function getReviews(address _restaurant_id) public
    {
        uint ind = rinds[_restaurant_id];
        if (ind <= restaurants.length){
            Restaurant memory r = restaurants[ind];
            if (r.number_of_votes>0){
                avg_rating_requested = uint2str(calcul(r.total_rating_value, r.number_of_votes, 2));
            }
            else {
                avg_rating_requested = '000';
            }
            number_of_ratings_requested =r.number_of_votes;
            bytes32[] memory temp = rcomments[_restaurant_id];
            for(uint i=0; i<temp.length-1; i++){
                comments_requested=string(abi.encodePacked(comments_requested, temp[i]));
                comments_requested=string(abi.encodePacked(comments_requested, '--'));
            }
            comments_requested=string(abi.encodePacked(comments_requested, temp[temp.length-1]));
        }
    }
}
