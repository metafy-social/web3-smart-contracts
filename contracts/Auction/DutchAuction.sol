// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

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
        require(block.timestamp < expiresAt, "auction expired");

        require(winner == address(0), "auction finished");

        uint256 timeElapsed = block.timestamp - startAt;
        uint256 deduction = priceDeductionRate * timeElapsed;
        uint256 price = startingPrice - deduction;

        require(msg.value >= price, "ETH < price");

        winner = msg.sender;
        nft.transferFrom(seller, msg.sender, nftId);
        seller.transfer(msg.value);

        emit Buy(msg.sender, msg.value);
    }
}
