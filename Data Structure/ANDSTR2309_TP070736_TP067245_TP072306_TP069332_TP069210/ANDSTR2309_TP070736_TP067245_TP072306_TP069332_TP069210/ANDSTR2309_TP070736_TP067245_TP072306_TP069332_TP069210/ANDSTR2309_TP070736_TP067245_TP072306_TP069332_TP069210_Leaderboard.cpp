#include "Leaderboard.h"
#include <iostream>

Leaderboard::Leaderboard() : head(nullptr), size(0) {}

void Leaderboard::addPlayer(Player* player) {
    Node* newNode = new Node(player);
    insertSorted(newNode);
    size++;
}

void Leaderboard::updateScores(Player* player, int score) {
    player->addScore(score);

    // Remove and re-insert player to maintain sorted order
    Node** current = &head;
    while (*current && (*current)->player != player) {
        current = &((*current)->next);
    }

    if (*current) {
        Node* temp = *current;
        *current = (*current)->next;
        delete temp;
        size--;
    }

    addPlayer(player);
}

void Leaderboard::insertSorted(Node* newNode) {
    if (!head || head->player->score <= newNode->player->score) {
        newNode->next = head;
        head = newNode;
    }
    else {
        Node* current = head;
        while (current->next && current->next->player->score > newNode->player->score) {
            current = current->next;
        }
        newNode->next = current->next;
        current->next = newNode;
    }
}

bool Leaderboard::isPlayerInTop30(const std::string& playerName) {
    Node* current = head;
    for (int i = 0; i < 30 && current != nullptr; ++i) {
        if (current->player->name == playerName) {
            return true;
        }
        current = current->next;
    }
    return false;
}

void Leaderboard::sortLeaderboard() {
    if (!head || !head->next) return;

    bool swapped;
    Node* ptr1;
    Node* lptr = nullptr;

    do {
        swapped = false;
        ptr1 = head;

        while (ptr1->next != lptr) {
            if (ptr1->player->score < ptr1->next->player->score) {
                // Swap the players
                Player* temp = ptr1->player;
                ptr1->player = ptr1->next->player;
                ptr1->next->player = temp;
                swapped = true;
            }
            ptr1 = ptr1->next;
        }
        lptr = ptr1;
    } while (swapped);
}

int Leaderboard::manualSearch(const std::string& playerName) {
    Node* current = head;
    int rank = 1;
    while (current != nullptr) {
        if (current->player->name == playerName) {
            return rank;
        }
        current = current->next;
        rank++;
    }
    return -1; // Player not found
}

void Leaderboard::displayTop30() {
    std::cout << "Top 30 Players:" << std::endl;
    Node* current = head;
    for (int i = 0; i < 30 && current != nullptr; ++i) {
        std::cout << i + 1 << ". " << current->player->name << " - " << current->player->score << std::endl;
        current = current->next;
    }
}
