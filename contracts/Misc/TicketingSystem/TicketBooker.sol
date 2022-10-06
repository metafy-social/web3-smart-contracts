// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
import "./PriceConverter.sol";

error NotOwner();

contract TicketBooker{

    using PriceConverter for uint256;
    
    address public immutable Host;
    uint256 public constant TICKET_PRICE = 2 * 10 ** 18; //Price set at 2 dollars
    uint256 public currentTicketID = 1;

    mapping(uint256 => address) public TicketIDToAddress;
    uint256 [] public Ticket_IDs;
    

    constructor(){
        Host = msg.sender;
    }

    function buyTicket() public payable{
        require((msg.value.getConvertedAmount()) >= TICKET_PRICE, "Spend more ETH");
        TicketIDToAddress[currentTicketID] = msg.sender;
        Ticket_IDs.push(currentTicketID);
        currentTicketID++;
    }

    

    modifier onlyHost {
        if(msg.sender != Host) revert NotOwner();
        _;
    }

    function verifyTicket(uint256 ticket_id, address claimer) public onlyHost view returns (bool){
        if(TicketIDToAddress[ticket_id] == claimer){
            return true;
        }
        return false;
    }

    receive() external payable{
        buyTicket();
    }

    fallback() external payable{
        buyTicket();
    }

}
