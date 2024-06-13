#include "Player.h"
#include "QuestionCard.h"
#include "Leaderboard.h"
#include <iostream>

int main() {
    // Create a leaderboard
    Leaderboard leaderboard;

    // Create players
    Player* player1 = new Player("Alice");
    Player* player2 = new Player("Bob");
    Player* player3 = new Player("Charlie");

    // Add players to the leaderboard
    leaderboard.addPlayer(player1);
    leaderboard.addPlayer(player2);
    leaderboard.addPlayer(player3);

    // Simulate answering questions
    QuestionCard question1(100);
    QuestionCard question2(200);
    QuestionCard question3(300);

    player1->addScore(question1.score);  // Correct answer
    leaderboard.updateScores(player1, question1.score);

    player2->addScore(static_cast<int>(question2.score * 0.8));  // Discarded card answer
    leaderboard.updateScores(player2, static_cast<int>(question2.score * 0.8));

    player3->addScore(question3.score);  // Correct answer
    leaderboard.updateScores(player3, question3.score);

    // Display the leaderboard
    leaderboard.displayTop30();

    // Search for a player in the top 30
    std::string searchName = "Alice";
    if (leaderboard.isPlayerInTop30(searchName)) {
        std::cout << searchName << " is in the top 30." << std::endl;
    }
    else {
        std::cout << searchName << " is not in the top 30." << std::endl;
    }

    // Sort the leaderboard
    leaderboard.sortLeaderboard();

    // Display the sorted leaderboard
    std::cout << "Sorted Leaderboard:" << std::endl;
    leaderboard.displayTop30();

    // Manual search for a player's rank
    std::string manualSearchName = "Charlie";
    int rank = leaderboard.manualSearch(manualSearchName);
    if (rank != -1) {
        std::cout << manualSearchName << " is ranked " << rank << "." << std::endl;
    }
    else {
        std::cout << manualSearchName << " is not found in the leaderboard." << std::endl;
    }

    // Cleanup
    delete player1;
    delete player2;
    delete player3;

    return 0;
}
