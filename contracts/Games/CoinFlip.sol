// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// This is a smart contract for coin-flip game.
// Here 2 individuals agree play the game. They each send an identical amount of ETH to the contract.
// Then contract flips a coin (pseudo-random boolean) and sends all the ETH to the winner (2 times the intial bet).

contract CoinFlip {
  address[] private players = new address[](2);
  uint256 private amount;
  address private winner;

  constructor(uint256 _amount) {
    amount = _amount;
  }

  // generate random pseudo-random boolean
  function random() private view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players))) % 2;
  }

  function getAmount() external view returns (uint256) {
    return amount;
  }

  function getPlayers() external view returns (address[] memory) {
    return players;
  }

  function getWinner() external view returns (address) {
    return winner;
  }

  function setAmount(uint256 _amount) external {
    require(
      (players[0] == address(0) && players[1] == address(0)),
      'Unable to change amount when a player is registered'
    );
    amount = _amount;
  }

  function register() external payable {
    require(msg.value == amount, 'Amount not exact');

    if (players[0] == address(0)) {
      players[0] = msg.sender;
      winner = address(0);
    } else if (players[1] == address(0)) {
      players[1] = msg.sender;
      play();
      sendPrizeToWinner(winner);
      players = new address[](2);
    }
  }

  function play() private {
    winner = players[random()];
  }

  function sendPrizeToWinner(address _winner) private {
    (bool success, ) = payable(_winner).call{value: 2 * amount}('');
    require(success, 'Could not send the amount to the winner');
  }
}