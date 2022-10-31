// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Goldfish {

    struct Player {
      uint[] hand; //the cards in the player's hand
      uint score; //the player's score
    }

    Player[] public players; //the two players in the game
    uint[] public drawPile; //the cards remaining in the draw pile
    uint[] public discardPile; //the cards in the discard pile

    //takes the top card from the draw pile and puts it in the discard pile
    function drawCard() internal {
      discardPile.push(uint256(drawPile.pop()))
    };

    //initializes the deck of cards
    function initDeck() internal {
      uint[] memory deck = new uint[52];
        
      for (uint i = 0; i < 52; i++) {
        deck[i] = i;
      }

      //shuffles the deck
      for (uint i = 0; i < 52; i++) {
        uint rand = uint(keccak256(block.number, now, i)) % 52;
      
        drawPile = deck;
      }
    }

    //initializes the two players
    function initPlayers() internal { 
      players.push(Player({
        hand: new uint[](7),
        score: 0
      }));

      players.push(Player({
        hand: new uint[](7),
        score: 0}));
    }

    //deals 7 cards to each player from the deck
    function dealCards() internal {
      for (uint i = 0; i < 7; i++) {
        players[0].hand[i] = drawPile.pop();
        players[1].hand[i] = drawPile.pop();
      }

    }

  //returns the player's hand
  function getHand(uint player) public view returns (uint[] memory ) {
    return players[player].hand;
  }

  //returns true if the card can be played, false otherwise
  function canPlayCard(uint card) public view returns (bool) {

    //if the card is the same number or color as the top card of the discard pile, it can be played
    if (card == discardPile[discardPile.length - 1]) {
      return true;
    }

    //get the suit of the card
    uint suit = card / 13;

    //get the number of the card
    uint number = card % 13;

    //check if the player has any other cards of the same suit
    for (uint i = 0; i < players[0].hand.length; i++) {

      if (suit == players[0].hand[i] / 13 && card != players[0].hand[i]) {
        return true;
      }

    }

    //check if the player has any other cards of the same number
    for (uint i = 0; i < players[0].hand.length; i++) {

        if (number == players[0].hand[i] % 13 && card != players[0].hand[i]) {
          return true;
        }
    }
    return false;

  }

  //plays a card from the player's hand
  function playCard(uint card) public {
    require(canPlayCard(card));
    discardPile.push(card);
    removeFromHand(card);
  }

  //removes a card from the player's hand
  function removeFromHand(uint card) internal {
      for (uint i = 0; i < players[0].hand.length; i++) {
        if (players[0].hand[i] == card) {
          players[0].hand[i] = players[0].hand[players[0].hand.length - 1];
          players[0].hand.length--;
          return;
      }
    }
  }

  //returns the player's score
  function getScore(uint player) public view returns (uint) { 
    return players[player].score;
  }

  //calculates the score for the player who has no cards remaining
  function calculateScore() internal {
    uint player = 0;

    if (players[1].hand.length == 0) {
      player = 1;
    }

    players[player].score = players[player].score + players[1 - player].hand.length;

  }

  //ends the current turn
  function endTurn() internal {
    drawCard();

    //if the player has no cards remaining, the game ends
    if (players[0].hand.length == 0) {
      calculateScore();
    }

  }

  //called when the contract is created
  constructor() public {
    initDeck();
    initPlayers();
    dealCards();
  }

  //called when it is time for the player to make their move
  function play() public {
    uint card = players[0].hand[0];
    playCard(card);
    endTurn();
  }

}
