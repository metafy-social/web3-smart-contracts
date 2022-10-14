//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
 
contract EventContract {
 struct Event{
   address organizer;
   string name;
   uint date; //0 1 2
   uint price;
   uint ticketCount;  //1 sec  0.5 sec
   uint ticketRemain;
 }
 
 mapping(uint=>Event) public events;
 mapping(address=>mapping(uint=>uint)) public tickets;
 uint public nextId;
 
 
 function createEvent(string memory name,uint date,uint price,uint ticketCount) external{
   require(date>block.timestamp,"You can organize event for future date");
   require(ticketCount>0,"You can organize event only if you create more than 0 tickets");
 
   events[nextId] = Event(msg.sender,name,date,price,ticketCount,ticketCount);
   nextId++;
 }
 
 function buyTicket(uint id,uint quantity) external payable{
   require(events[id].date!=0,"Event does not exist");
   require(events[id].date>block.timestamp,"Event has already occured");
   Event storage _event = events[id];
   require(msg.value==(_event.price*quantity),"Ethere is not enough");
   require(_event.ticketRemain>=quantity,"Not enough tickets");
   _event.ticketRemain-=quantity;
   tickets[msg.sender][id]+=quantity;
 
 }
 
 function transferTicket(uint id,uint quantity,address to) external{
   require(events[id].date!=0,"Event does not exist");
   require(events[id].date>block.timestamp,"Event has already occured");
   require(tickets[msg.sender][id]>=quantity,"You do not have enough tickets");
   tickets[msg.sender][id]-=quantity;
   tickets[to][id]+=quantity;
 }
}
