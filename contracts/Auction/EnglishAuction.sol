// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC721 {
    function transfer(address, uint) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}

error AuctionAlreadyStarted();
error UnauthorizedInitiationOfAuction(address initiator, address seller);
error AuctionNotStarted();
error AuctionAlreadyEnded();
error BidTooLow(uint256 bid, uint256 highestBid);
error AuctionNotEnded();
error SellerNotPaid();
error CouldNotWithdraw();

//Seller of NFT deploys this contract.
//Auction lasts for 7 days.
//Participants can bid by depositing ETH greater than the current highest bidder.

contract Auction {
    event Start();
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);

    address payable public seller;

    bool public started;
    bool public ended;
    uint public endAt;

    IERC721 public nft;
    uint public nftId;

    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    constructor() {
        seller = payable(msg.sender);
    }

    function start(
        IERC721 _nft,
        uint _nftId,
        uint startingBid
    ) external {
        if (started) {
            revert AuctionAlreadyStarted();
        }
        if (msg.sender != seller) {
            revert UnauthorizedInitiationOfAuction(msg.sender, seller);
        }
        highestBid = startingBid;

        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);

        started = true;
        endAt = block.timestamp + 7 days;

        emit Start();
    }

    function bid() external payable {
        if (!started) {
            revert AuctionNotStarted();
        }
        if (block.timestamp >= endAt) {
            revert AuctionAlreadyEnded();
        }
        if (msg.value <= highestBid) {
            revert BidTooLow(msg.value, highestBid);
        }

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(highestBidder, highestBid);
    }

    function withdraw() external payable {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool sent, ) = payable(msg.sender).call{value: bal}("");
        if(!sent) {
            revert CouldNotWithdraw();
        }

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        if (!started) {
            revert AuctionNotStarted();
        }
        if (block.timestamp < endAt) {
            revert AuctionNotEnded();
        }
        if (ended) {
            revert AuctionAlreadyEnded();
        }

        if (highestBidder != address(0)) {
            nft.transfer(highestBidder, nftId);
            (bool sent, ) = seller.call{value: highestBid}("");
            if (!sent) {
                revert SellerNotPaid();
            }
        } else {
            nft.transfer(seller, nftId);
        }

        ended = true;
        emit End(highestBidder, highestBid);
    }
}
