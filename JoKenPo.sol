// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

contract JoKenPo {
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    }

    Options private choice1 = Options.NONE;
    address private player1;
    string public result = "";

    address payable private immutable owner;

    struct Player {
        address wallet;
        uint32 wins;
    }

    Player[] public players;

    constructor() {
        owner = payable(msg.sender);
    }

    function updateWinner(address winner) private {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].wallet == winner) {
                players[i].wins++;
                return;
            }
        }
        players.push(Player(winner, 1));
    }

    function finishiGame(string memory newResult, address winner) private {
        address contractAddress = address(this);
        payable(winner).transfer((contractAddress.balance / 100) * 90);
        owner.transfer(contractAddress.balance);

        updateWinner(winner);

        result = newResult;
        player1 = msg.sender;
        choice1 = Options.NONE;
    }

    function getBalance() public view returns (uint256) {
        require(owner == msg.sender, "You don't have permission...");
        return address(this).balance;
    }

    function play(Options newChoice) public payable {
        require(newChoice != Options.NONE, "Invalid choice...");
        require(player1 != msg.sender, "Wait the another player...");
        require(msg.value >= 0.001 ether, "Invalid bid...");

        if (choice1 == Options.NONE) {
            player1 = msg.sender;
            choice1 = newChoice;
            result = "Player1 choose his/her option. Waiting Player2...";
        } else if (choice1 == Options.ROCK && newChoice == Options.SCISSORS) {
            finishiGame("Rock breaks scissors. Player1 WIN...", player1);
        } else if (choice1 == Options.PAPER && newChoice == Options.ROCK) {
            finishiGame("Paper wraps rock. Player1 WIN...", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.PAPER) {
            finishiGame("Scissors cuts paper. Player1 WIN...", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.ROCK) {
            finishiGame("Rock breaks scissors. Player2 WIN...", msg.sender);
        } else if (choice1 == Options.ROCK && newChoice == Options.PAPER) {
            finishiGame("Paper wraps rock. Player2 WIN...", msg.sender);
        } else if (choice1 == Options.PAPER && newChoice == Options.SCISSORS) {
            finishiGame("Scissors cuts paper. Player2 WIN...", msg.sender);
        } else {
            result = "Draw game. The prixe was doubled...";
            player1 = address(0);
            choice1 = Options.NONE;
        }
    }

    function getLeaderboard() public view returns (Player[] memory) {
        if (players.length < 2) return players;

        Player[] memory arr = new Player[](players.length);
        for (uint256 i = 0; i < players.length; i++) arr[i] = players[i];

        for (uint256 i = 0; i < arr.length - 1; i++) {
            for (uint256 j = 1; j < arr.length; j++) {
                if (arr[i].wins < arr[j].wins) {
                    Player memory change = arr[i];
                    arr[i] = arr[j];
                    arr[j] = change;
                }
            }
        }

        return arr;
    }
}
