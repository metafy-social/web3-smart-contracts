//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Ecommerce{
    
    struct Product{
        string title;
        string description;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    } 

    Product [] public products;  // array of type "Product struct"
    uint counter = 0;

    event registered(string title, uint productId, address seller);
    event bought(uint productId, address buyer);
    event delivered(uint productId);

    // function is used for registering the product
    function registerProduct
        (string memory _title,
        string memory _description,
        uint _price)
        public {
            require(_price > 0 , "Price of products has to be greater then 0");
            Product memory tempProduct;
            tempProduct.title = _title;
            tempProduct.description = _description;
            tempProduct.price = _price * 10**18;
            tempProduct.seller = payable(msg.sender);
            tempProduct.productId = counter;
            products.push(tempProduct);
            counter++;
            emit registered(_title,tempProduct.productId, msg.sender);
        }    
     // funtion to buy the product
    function buy(uint _productId) payable public{
        require(products[_productId].price == msg.value,"Please pay the exact amount");
        products[_productId].buyer  = msg.sender;
        emit bought(_productId, msg.sender);
    }
 
    // function to confirm delivery from buyer
    function delivery(uint _productId) public {
        require(products[_productId].buyer == msg.sender, "buyer confirmation only");
        products[_productId].delivered = true;
        products[_productId].seller.transfer(products[_productId].price);
        emit delivered(_productId);
    } 
}

