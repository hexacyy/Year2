#ifndef LEADERBOARD_H
#define LEADERBOARD_H

#include "Node.h"
#include <string>

class Leaderboard {
private:
    Node* head;
    int size;
    void insertSorted(Node* newNode);
public:
    Leaderboard();
    void addPlayer(Player* player);
    void updateScores(Player* player, int score);
    bool isPlayerInTop30(const std::string& playerName);
    void sortLeaderboard();
    void displayTop30();
    int manualSearch(const std::string& playerName);  // Custom search function
};

#endif
