#ifndef NODE_H
#define NODE_H

#include "Player.h"

class Node {
public:
    Player* player;
    Node* next;
    Node(Player* p);
};

#endif
