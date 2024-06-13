#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>
#include <algorithm>
#include <chrono>

using namespace std;
using namespace std::chrono;

// Constants for the game
const int MAX_QUESTIONS = 300;
const int MAX_PLAYERS = 100;
const int ROUNDS = 3;

// Structure to hold question cards
struct QuestionCard {
    string question;
    string answer;
    int score;
};

// Structure to hold player information
struct Player {
    string name;
    int totalScore;
};

// Class to manage a dynamic array of question cards
class DynamicArray {
private:
    QuestionCard* array;  // Pointer to the array of question cards
    int size;             // Current size of the array
    int capacity;         // Current capacity of the array

public:
    DynamicArray(int initialCapacity = 10) : size(0), capacity(initialCapacity) {
        array = new QuestionCard[capacity];  // Allocate memory for the array
    }

    ~DynamicArray() {
        delete[] array;  // Free the allocated memory
    }

    // Function to add a card to the dynamic array
    void addCard(const QuestionCard& card) {
        if (size == capacity) {
            capacity *= 2;  // Double the capacity if the array is full
            QuestionCard* newArray = new QuestionCard[capacity];  // Allocate new array with double capacity
            for (int i = 0; i < size; ++i) {
                newArray[i] = array[i];  // Copy existing elements to the new array
            }
            delete[] array;  // Delete the old array
            array = newArray;  // Point to the new array
        }
        array[size++] = card;  // Add the new card and increment the size
    }

    // Function to get a card from the array by index
    QuestionCard& getCard(int index) {
        return array[index];
    }

    // Function to remove a card from the array by index
    void removeCard(int index) {
        for (int i = index; i < size - 1; ++i) {
            array[i] = array[i + 1];  // Shift elements to fill the gap
        }
        size--;  // Decrease the size
    }

    // Function to get the current size of the array
    int getSize() const {
        return size;
    }

    // Function to shuffle the array
    void shuffle() {
        srand(time(0));  // Seed the random number generator
        for (int i = size - 1; i > 0; --i) {
            int j = rand() % (i + 1);  // Generate a random index
            swap(array[i], array[j]);  // Swap the elements
        }
    }
};

// Structure to hold player nodes for linked list
struct PlayerNode {
    Player player;
    PlayerNode* next;

    // Constructor to initialize player node
    PlayerNode(const string& name, int score) : player{name, score}, next(nullptr) {}
};

// Class to manage a linked list of players
class PlayerLinkedList {
private:
    PlayerNode* head;  // Pointer to the head of the linked list
    int size;          // Current size of the linked list

public:
    PlayerLinkedList() : head(nullptr), size(0) {}

    ~PlayerLinkedList() {
        while (head) {
            PlayerNode* temp = head;  // Temporary pointer to hold the current head
            head = head->next;  // Move the head to the next node
            delete temp;  // Delete the old head
        }
    }

    // Function to add a player to the linked list
    void addPlayer(const string& name, int score = 0) {
        PlayerNode* newNode = new PlayerNode(name, score);  // Create a new player node
        sortedInsert(newNode);  // Insert the new node in sorted order
        size++;  // Increase the size
    }

    // Function to insert a player node in sorted order
    void sortedInsert(PlayerNode* newNode) {
        if (!head || head->player.totalScore <= newNode->player.totalScore) {
            newNode->next = head;  // Insert at the beginning if head is null or new node's score is higher
            head = newNode;
        } else {
            PlayerNode* current = head;
            while (current->next && current->next->player.totalScore > newNode->player.totalScore) {
                current = current->next;  // Traverse to the correct position
            }
            newNode->next = current->next;  // Insert the new node
            current->next = newNode;
        }
    }

    // Function to update the score of a player
    void updateScore(const string& name, int score) {
        PlayerNode* current = head;
        PlayerNode* prev = nullptr;
        while (current && current->player.name != name) {
            prev = current;
            current = current->next;  // Traverse to find the player
        }
        if (current) {
            if (prev) {
                prev->next = current->next;  // Remove the current node from its position
            } else {
                head = current->next;  // If it's the head, update the head
            }
            current->player.totalScore += score;  // Update the player's score
            sortedInsert(current);  // Reinsert the node in sorted order
        }
    }

    // Function to set the score of a player directly
    void setScore(const string& name, int score) {
        PlayerNode* current = head;
        while (current && current->player.name != name) {
            current = current->next;  // Traverse to find the player
        }
        if (current) {
            current->player.totalScore = score;  // Set the player's score
        }
    }

    // Function to get a player node by index
    PlayerNode* getPlayerNodeByIndex(int index) {
        PlayerNode* current = head;
        for (int i = 0; i < index && current; ++i) {
            current = current->next;  // Traverse to the correct index
        }
        return current;
    }

    // Function to display the top players
    void displayTopPlayers(int topN = 30) const {
        PlayerNode* current = head;
        for (int i = 0; i < topN && current; ++i) {
            cout << i + 1 << ". " << current->player.name << ": " << current->player.totalScore << " points\n";
            current = current->next;  // Traverse to display each player
        }
    }

    // Function to check if a player is in the top 30
    bool isPlayerInTop30(const string& name) {
        PlayerNode* current = head;
        for (int i = 0; i < 30 && current; ++i) {
            if (current->player.name == name) {
                return true;  // Return true if player is found in top 30
            }
            current = current->next;
        }
        return false;  // Return false if player is not found
    }

    // Function to sort the leaderboard
    void sortLeaderboard() {
        if (!head) {
            return;  // Return if the list is empty
        }
        bool swapped;
        do {
            swapped = false;
            PlayerNode* current = head;
            PlayerNode* prev = nullptr;
            while (current->next) {
                if (current->player.totalScore < current->next->player.totalScore) {
                    if (prev) {
                        prev->next = current->next;
                    } else {
                        head = current->next;
                    }
                    PlayerNode* temp = current->next;
                    current->next = temp->next;
                    temp->next = current;
                    prev = temp;
                    swapped = true;  // Set swapped to true if any swapping is done
                } else {
                    prev = current;
                    current = current->next;
                }
            }
        } while (swapped);  // Repeat until no more swaps are done
    }

    // Function to search for a player manually
    int manualSearch(const string& name) {
        PlayerNode* current = head;
        int rank = 1;
        while (current) {
            if (current->player.name == name) {
                return rank;  // Return rank if player is found
            }
            current = current->next;
            rank++;
        }
        return -1;  // Return -1 if player is not found
    }
};

// Function to read questions from a file into a dynamic array
void readQuestionsFromFile(const string& filename, DynamicArray& deck) {
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error: Unable to open file " << filename << endl;
        return;
    }
    string line;
    while (getline(file, line)) {
        stringstream ss(line);
        string question, answer;
        int score;
        if (getline(ss, question, '/') && getline(ss, answer, '/') && (ss >> score)) {
            QuestionCard card{ question, answer, score };
            deck.addCard(card);  // Add the card to the deck
        } else {
            cerr << "Error: Invalid format in file " << filename << ", skipping line" << endl;
        }
    }
    file.close();
}

int main() {
    srand(time(0));  // Seed the random number generator
    DynamicArray unansweredDeck, answeredDeck, discardedDeck;

    // Profile: Reading questions from file
    auto start = high_resolution_clock::now();
    readQuestionsFromFile("questions.txt", unansweredDeck);
    auto end = high_resolution_clock::now();
    duration<double> duration = end - start;
    cout << "Reading questions from file took " << duration.count() << " seconds.\n";

    unansweredDeck.shuffle();  // Shuffle the deck of unanswered questions

    cout << "\nEnter number of players: ";
    int numPlayers;
    cin >> numPlayers;
    cin.ignore();
    numPlayers = min(numPlayers, MAX_PLAYERS);

    PlayerLinkedList players;
    for (int i = 0; i < numPlayers; ++i) {
        cout << "Enter name of player " << i + 1 << ": ";
        string playerName;
        getline(cin, playerName);
        players.addPlayer(playerName, 0);  // Add each player to the linked list
    }

    // Main game loop for each round
    for (int round = 1; round <= ROUNDS; ++round) {
        // Profile: Round execution time
        start = high_resolution_clock::now();
        cout << "\nRound " << round << " begins now.\n";
        for (int playerIndex = 0; playerIndex < numPlayers; ++playerIndex) {
            if (unansweredDeck.getSize() == 0 && discardedDeck.getSize() == 0) {
                cout << "No more questions available.\n";
                break;
            }
            int deckChoice = 1;
            if (discardedDeck.getSize() > 0) {
                cout << "\nChoice for player " << playerIndex + 1 << ": Enter 1 to pick a question from the Unanswered deck OR Enter 2 to pick a question from the Discarded deck: ";
                cin >> deckChoice;
                cin.ignore();
            }
            DynamicArray& currentDeck = (deckChoice == 2 && discardedDeck.getSize() > 0) ? discardedDeck : unansweredDeck;
            QuestionCard currentQuestion;
            if (deckChoice == 2) {
                cout << "Available discarded questions:\n";
                for (int i = 0; i < discardedDeck.getSize(); ++i) {
                    cout << i + 1 << ". " << discardedDeck.getCard(i).question << endl;
                }
                cout << "Choose the question number you want to answer: ";
                int questionChoice;
                cin >> questionChoice;
                cin.ignore();
                currentQuestion = discardedDeck.getCard(questionChoice - 1);  // Get the chosen question from discarded deck
                discardedDeck.removeCard(questionChoice - 1);  // Remove the chosen question from discarded deck
            } else {
                currentQuestion = currentDeck.getCard(0);  // Get the first question from unanswered deck
                currentDeck.removeCard(0);  // Remove the first question from unanswered deck
            }
            cout << "\nQuestion to player " << playerIndex + 1 << ": " << currentQuestion.question << endl;
            string response;
            cout << "Enter answer or Enter \"skip\" to pass the question: ";
            getline(cin, response);
            bool fromDiscarded = (deckChoice == 2);

            // Main Game Loop - Updating Scores
            if (response == currentQuestion.answer) {
                float score = currentQuestion.score;
                if (fromDiscarded) {
                    score *= 0.8;  // Reduce score by 20% if from discarded deck
                }
                cout << "\nCorrect!\n";
                cout << "You earned " << floor(score) << " points.\n";
                answeredDeck.addCard(currentQuestion);  // Add the question to answered deck
                PlayerNode* playerNode = players.getPlayerNodeByIndex(playerIndex);
                if (playerNode) {
                    players.updateScore(playerNode->player.name, static_cast<int>(floor(score)));  // Update the player's score
                    if (answeredDeck.getSize() == 1 && discardedDeck.getSize() == 0) {
                        players.setScore(playerNode->player.name, 0);  // Reset score if only one question is answered
                    }
                }
            } else if (response == "skip") {
                discardedDeck.addCard(currentQuestion);  // Add the question to discarded deck
            } else {
                cout << "Incorrect.\n";
                cout << "The correct answer was: " << currentQuestion.answer << endl;
                discardedDeck.addCard(currentQuestion);  // Add the question to discarded deck
            }
            cout << "\nUnanswered Questions: " << unansweredDeck.getSize() << "\n";
            cout << "Discarded questions: " << discardedDeck.getSize() << "\n";
            cout << "Answered questions: " << answeredDeck.getSize() << "\n";
        }
        cout << "\n---End of Round " << round << "---\n";
        cout << "Remaining Round(s): " << ROUNDS - round << "---\n\n";

        end = high_resolution_clock::now();
        duration = end - start;
        cout << "Round " << round << " took " << duration.count() << " seconds.\n";
    }

    // Main Game Loop - Displaying Top Players
    cout << "\n--- Final Scores ---\n";
    players.displayTopPlayers();

    string searchName;
    cout << "\nEnter the name of the player to search in the top 30: ";
    getline(cin, searchName);
    if (players.isPlayerInTop30(searchName)) {
        cout << searchName << " is in the top 30.\n";
    } else {
        cout << searchName << " is not in the top 30.\n";
    }

    // Main Game Loop - Sorting the Leaderboard
    // Profile: Sorting the leaderboard
    start = high_resolution_clock::now();
    players.sortLeaderboard();
    end = high_resolution_clock::now();
    duration = end - start;
    cout << "Sorting leaderboard took " << duration.count() << " seconds.\n";

    cout << "\nSorted Leaderboard:\n";
    players.displayTopPlayers();

    string manualSearchName;
    cout << "\nEnter the name of the player to search for their rank: ";
    getline(cin, manualSearchName);
    int rank = players.manualSearch(manualSearchName);
    if (rank != -1) {
        cout << manualSearchName << " is ranked " << rank << ".\n";
    } else {
        cout << manualSearchName << " is not found in the leaderboard.\n";
    }
    return 0;
}
