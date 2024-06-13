#ifndef PLAYER_H
#define PLAYER_H

#include <string>

class Player {
public:
    std::string name;
    int score;

    Player(const std::string& name);
    void addScore(int points);
};

#endif
