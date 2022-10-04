// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    
    function getLatestPrice() internal view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        (, int256 answer, , ,) = priceFeed.latestRoundData();

        return uint256(answer *  10000000000);
    }

    function getConvertedAmount(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = getLatestPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / (1000000000000000000);
        return ethAmountInUSD;
    }
}