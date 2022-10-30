// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract UnoGame {

    // Each player starts with 7 cards
    // The game is played with a regular deck of 108 cards
    // There are 4 suits (Red, Yellow, Green, Blue)
    // Each suit has 1 Zero card, 2 One cards, 2 Two cards, 3 Three cards, 4 Four cards, 5 Five cards, 6 Six cards, 7 Seven cards, 8 Eight cards, 9 Nine cards, Skip, Reverse, and Draw Two cards
    // In addition, there are 4 Wild cards and 4 Wild Draw Four cards

    enum Suit { Red, Yellow, Green, Blue }

    // This struct represents a single Uno card
    struct Card {
        uint8 value;
        Suit suit;
    }

    // The player struct represents a single Uno player

    struct Player {
        uint8 handSize;
        Card[] cards;
    }

    // The gameState struct keeps track of important game information

    struct GameState {
        uint8 turn;
        uint8 direction;
        uint8 drawCount;
        Card currentCard;
        Player[] players;
    }


    // Keep track of the game's state
    GameState public gameState;

    // An array to hold all of the game's cards
    Card[] public deck;

    // The address of the contract's creator (the game host)
    address public host;

    // The addresses of the contract's players
    address[] public players;

    // The Contract's constructor
    constructor(address _host) { 
        // Initialize the game's basic state
        gameState.turn = 0;
        gameState.direction = 1;
        gameState.drawCount = 0;
        // Set the host
        host = _host;
        // Initialize the deck  
        initializeDeck();
    }

    // Function to add a player to the game
    function joinGame(address _player) public {

        // Only the game host can add players
        require(msg.sender == host);

        // Add the player to the list of players
        players.push(_player);
    }

    // Function to start the game
    function startGame() public {

        // Only the game host can start the game
        require(msg.sender == host);
        // Shuffle the deck
        shuffleDeck();

        uint8 STARTING_HAND_SIZE = 7;

        // Deal cards to each player
        for (uint8 i = 0; i < players.length; i++) {
            gameState.players[i].handSize = STARTING_HAND_SIZE;
            for (uint8 j = 0; j < STARTING_HAND_SIZE; j++) {
                gameState.players[i].cards[j] = deck[i * STARTING_HAND_SIZE + j];
            }
        }

        // Set the current card to the top of the deck
        gameState.currentCard = deck[0];
    }

    // Function to play a card
    function playCard(uint8 _playerIndex, uint8 _cardIndex) public {
        // Make sure it's the player's turn
        require(gameState.turn == _playerIndex);
        // Get a reference to the player's hand
        Player storage player = gameState.players[_playerIndex];
        // Get a reference to the card being played
        Card storage card = player.cards[_cardIndex];
        // Remove the card from the player's hand
        for (uint8 i = _cardIndex; i < player.handSize - 1; i++) {
            player.cards[i] = player.cards[i+1];
        }

        player.cards[player.handSize - 1] = Card(0, Suit.Red);
        player.handSize--;

        // Check if the card being played matches the current card
        if (card.value == gameState.currentCard.value || card.suit == gameState.currentCard.suit) {
            // Play the card
            gameState.currentCard = card;

        // Check if the player has won the game
        if (player.handSize == 0) {
        // The player has won the game!
        }
        // It's the next player's turn
        gameState.turn = uint8((_playerIndex + gameState.direction) % players.length);
        } else {
        // The card being played doesn't match the current card
        // The player must draw a card
        drawCard(_playerIndex);
        }
    }

    // Function to draw a card
    function drawCard(uint8 _playerIndex) public {

        // Make sure it's the player's turn
        require(gameState.turn == _playerIndex);
        // Get a reference to the player  
        Player storage player = gameState.players[_playerIndex];

        uint8 STARTING_HAND_SIZE = 7;
        // Make sure the player can draw a card
        require(player.handSize < STARTING_HAND_SIZE);
        // Draw a card from the deck
        player.cards[player.handSize] = deck[gameState.drawCount];
        player.handSize++;
        gameState.drawCount++;
    }

    // Function to initialize the deck
    function initializeDeck() private {
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 10; j++) {  
                deck.push(Card(j, Suit(i)));
            }
            for (uint8 j = 0; j < 2; j++) {
                    deck.push(Card(10, Suit(i))); // Skip
                    deck.push(Card(11, Suit(i))); // Reverse
                    deck.push(Card(12, Suit(i))); // Draw Two
                }
        }

        for (uint8 i = 0; i < 4; i++) {
            deck.push(Card(13, Suit.Red)); // Wild
            deck.push(Card(14, Suit.Red)); // Wild Draw Four
        }
    }
    // Function to shuffle the deck
    function shuffleDeck() private {
        for (uint8 i = 0; i < deck.length; i++) {
            uint256 j = uint256(keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender, i))) % deck.length;
            Card storage temp = deck[i];
            deck[i] = deck[j];
            deck[j] = temp;
        }

    }
}
