// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

contract Supplychain {
    //product structure initialization
    struct S_Item {
        uint256 _index;
        string _identifier;
        uint256 _priceInWei;
    }

    //product stats initalization
    struct ProductDetails {
        uint256 _count;
        uint256 _total;
    }

    //mapping index to product stats
    mapping(uint256 => ProductDetails) public productData;

    //stores all products in array
    S_Item[] public productArr;

    //map that stores the item details with item index
    mapping(uint256 => S_Item) public items;

    //initialized items index variable
    uint256 index;

    enum SupplyChainSteps {
        Created,
        Paid,
        Delivered
    }

    //user can create item
    function createItem(string memory _identifier, uint256 _priceInWei) public {
        items[index]._priceInWei = _priceInWei;

        items[index]._identifier = _identifier;
        items[index]._index = index;
        productArr.push(items[index]);
        //index is incremented
        index++;
    }

    //function for getting specific product details using index
    function getProduct(uint256 ind) public view returns (S_Item memory) {
        return items[ind];
    }

    //this function returns array of products
    function getProductArray() public view returns (S_Item[] memory) {
        return productArr;
    }

    //function that gives stats like how many number of products sold and total revenue generated from each product
    function Stats(uint256 ind, uint256 amount) public {
        productData[ind]._count += 1;
        productData[ind]._total += amount;
    }

    //payment for each item done from front-end using web.eth.sendTransaction() method amount stored in specofic address in our local blockchain like "GANACHE"
}
