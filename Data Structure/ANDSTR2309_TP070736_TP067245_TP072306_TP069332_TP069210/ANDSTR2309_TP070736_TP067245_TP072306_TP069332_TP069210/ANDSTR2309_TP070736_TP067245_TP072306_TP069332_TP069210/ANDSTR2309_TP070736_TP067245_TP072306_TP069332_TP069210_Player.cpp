#include "Player.h"

Player::Player(const std::string& name) : name(name), score(0) {}

void Player::addScore(int points) {
    score += points;
}
