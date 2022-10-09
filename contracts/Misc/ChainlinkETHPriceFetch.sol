// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @dev Import chainlink Aggregator interface 
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title ETH/USD Price Fetcher 
/// @author supernovahs.eth <supernovahs@proton.me>
/// @notice Retrieves latest ETH/USD price with 8 floating decimal
/// warning Works on Goerli only.
contract FetchETHPrice {
AggregatorV3Interface internal priceFeed;
    
    constructor() {
        /// @dev Contract address for goerli network to fetch prices
    priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

/// Gets latest ETH/USD price 
/// return Price in USD with 8 floating decimal  ie. 100_00_00_00_000 = 1000 USD in actual
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return (price);
    }

}
