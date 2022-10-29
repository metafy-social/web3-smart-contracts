// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

error AuctionExpired();
error AuctionFinished();
InsufficientValue(uint256 receivedAmount, uint256 price requiredAmount);

contract DutchAuction {
    event Buy(address winner, uint256 amount);

    IERC721 public immutable nft;
    uint256 public immutable nftId;

    address payable public seller;
    uint256 public startingPrice;
    uint256 public startAt;
    uint256 public expiresAt;
    uint256 public priceDeductionRate;
    address public winner;

    constructor(
        uint256 _startingPrice,
        uint256 _priceDeductionRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + 7 days; //Expires in  week from the start
        priceDeductionRate = _priceDeductionRate;

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function buy() external payable {
        // Check for the timestamp before buy
        if(block.timestamp >= expiresAt){
          revert AuctionExpired();
        }

        if(winner != address(0)) {
          revert AuctionFinished();
        }

        uint256 timeElapsed = block.timestamp - startAt;
        uint256 deduction = priceDeductionRate * timeElapsed;
        uint256 price = startingPrice - deduction;

        if(msg.value < price){
          revert InsufficientValue(msg.value, price);
        }

        winner = msg.sender;
        nft.transferFrom(seller, msg.sender, nftId);
        seller.transfer(msg.value);

        emit Buy(msg.sender, msg.value);
    }
}
