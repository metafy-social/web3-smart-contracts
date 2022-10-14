// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
contract TicTacToe{
    address player1;
    address player2;
    uint8 current_move = 0;
    enum SquareState {Empty, X, O}
    SquareState[3][3] board;
    constructor(address _player2) {
        require(_player2 != address(0x0));
        player1 = msg.sender;
        player2 = _player2;
    }
    function performMove(uint8 xpos, uint8 ypos) public{
        require(msg.sender == player1 || msg.sender == player2);
        require(!isGameOver());
        require(msg.sender == currentPlayerAddress());

        require (positionIsInBounds(xpos, ypos));
        require (board[xpos][ypos] == SquareState.Empty);

        board[xpos][ypos] = currentPlayerShape();
        current_move = current_move +  1;
    }
    function currentPlayerAddress() public view returns (address){
        if(current_move % 2 == 0){
            return player2;
        }else{
            return player1;
        }
    }
    function currentPlayerShape() public view returns(SquareState){
        if(current_move % 2 == 0){
            return SquareState.X;
        }else{
            return SquareState.O;
        }
    }
    function winner() public view returns (address) {
        SquareState winning_shape = winningPlayerShape();
        if(winning_shape == SquareState.X){
            return player2;
        }else if (winning_shape == SquareState.O){
            return player1;
        }
        return address(0x0);
    }
    function isGameOver() public view returns (bool){
        return (winningPlayerShape() != SquareState.Empty || current_move > 8);
    }
    function winningPlayerShape() public view returns(SquareState){
        // Columns
        if(board[0][0] != SquareState.Empty && board[0][0] == board[0][1] && board[0][0] == board[0][2]){
            return board[0][0];
        }
        if(board[1][0] != SquareState.Empty && board[1][0] == board[1][1] && board[1][0] == board[1][2]){
            return board[1][0];
        } 
        if(board[2][0] != SquareState.Empty && board[2][0] == board[2][1] && board[2][0] == board[2][2]){
            return board[2][0];
        }
        // rows
        if(board[0][0] != SquareState.Empty && board[0][0] == board[1][0] && board[0][0] == board[2][0]){
            return board[0][0];
        }
        if(board[0][1] != SquareState.Empty && board[0][1] == board[1][1] && board[0][1] == board[2][1]){
            return board[0][1];
        }
        if(board[0][2] != SquareState.Empty && board[0][2] == board[1][2] && board[0][2] == board[2][2]){
            return board[0][2];
        }
        // Diagonals
        if(board[0][0] != SquareState.Empty && board[0][0] == board[1][1] && board[0][0] == board[2][2]){
            return board[0][0];
        }if(board[0][2] != SquareState.Empty && board[0][2] == board[1][1] && board[0][2] == board[2][0]){
            return board[0][2];
        }
        return SquareState.Empty;
    }
    function stateToString() public view returns (string memory){
        return string(abi.encodePacked("\n",
        rowToString(0),"\n",
        rowToString(1),"\n",
        rowToString(2),"\n"
        ));
    }
    function rowToString(uint8 ypos) public view returns(string memory){
        return string(abi.encodePacked(squareToString(0, ypos), "|", squareToString(1, ypos), "|", squareToString(2, ypos)));
    }
    function squareToString(uint8 xpos, uint8 ypos) public view returns (string memory){
        require (positionIsInBounds(xpos, ypos));
        if(board[xpos][ypos] == SquareState.Empty){
            return " ";
        }
        if(board[xpos][ypos] == SquareState.X){
            return "X";
        }
        if(board[xpos][ypos] == SquareState.O){
            return "O";
        }
        return "";
    }
    function positionIsInBounds(uint8 xpos, uint8 ypos) public pure returns(bool) {
        return(xpos >= 0 && xpos < 3 && ypos >= 0 && ypos < 3);
    }
}
