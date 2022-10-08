// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

// Taxi service contract

contract Taxi {
  address payable public companyAddress;
  address public clientAddress;

  uint public orderCount = 0;

  // Taxi Order structure
  struct Order {
    uint id;
    uint xDep;
    uint yDep;
    uint xDext;
    uint yDext;
    uint price;
    uint paid;
    bool confirmed;
    bool completed;
  }

  mapping (uint => Order) orders;

  // order lifecycle events
  event OrderRequested(address client, uint id, uint xDep, uint yDep, uint xDest, uint yDest);
  event OrderConfirmed(address client, uint id, uint price);
  event OrderPaid(address client, uint id, uint value);
  event OrderFinished(address client, uint id);

  event OrderCompleted(
    uint id,
    uint price
  );

  constructor(address _clientAddress) public {
    companyAddress = msg.sender;

    clientAddress = _clientAddress;
  }

  // Request Ride
  function requestOrder(uint xDep, uint yDep, uint xDest, uint yDest) public {
    require(msg.sender == clientAddress);

    orderCount ++;
    orders[orderCount] = Order(orderCount, xDep, yDep, xDest, yDest, 0, 0, false, false);
    
    emit OrderRequested(msg.sender, orderCount, xDep, yDep, xDest, yDest);
  }

  // Confirm Ride
  function confirmOrder(uint id, uint price) public {
    require(msg.sender == companyAddress);
    require(id >= 0);
    require(id <= orderCount);

    orders[id].confirmed = true;
    orders[id].price = price;
    emit OrderConfirmed(clientAddress, id, price);
  }

  // Pay after Ride
  function payForOrder(uint id, uint price) payable public {
    require(msg.sender == clientAddress);
    require(id >= 0);
    require(id <= orderCount);
    require(orders[id].price == msg.value);

    orders[id].paid = msg.value;
    emit OrderPaid(msg.sender, id, price);
  }

  // Mark the order/ride as finished
  function finishOrder(uint id) payable public {
    require(msg.sender == clientAddress);
    require(id >= 0);
    require(id <= orderCount);

    orders[id].completed = true;
    emit OrderFinished(msg.sender, id);

    companyAddress.transfer(orders[id].paid);
  }
}
