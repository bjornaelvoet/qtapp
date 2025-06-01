#include "BoardModel.h"
#include <QDebug>
#include <QRandomGenerator> // For random initial states (optional)

BoardModel::BoardModel(int size, QObject *parent)
    : QObject(parent), m_boardSize(size), m_currentPlayer(1), // Player 1 starts
      m_gameOver(false) {
  initializeBoard();
}

void BoardModel::initializeBoard() {
  m_board.clear();
  m_board.resize(m_boardSize);
  for (int i = 0; i < m_boardSize; ++i) {
    m_board[i].resize(m_boardSize);
    for (int j = 0; j < m_boardSize; ++j) {
      m_board[i][j] = Empty;
    }
  }
  emit boardChanged();
  emit currentPlayerChanged();
  emit gameOverChanged(); // Reset game over state
}

QVector<QPoint> BoardModel::hexPositions() const {
  QVector<QPoint> positions;
  for (int r = 0; r < m_boardSize; ++r) {
    for (int c = 0; c < m_boardSize; ++c) {
      positions.append(QPoint(r, c));
    }
  }
  return positions;
}

int BoardModel::getHexState(int row, int col) const {
  if (row >= 0 && row < m_boardSize && col >= 0 && col < m_boardSize) {
    return m_board[row][col];
  }
  return Empty; // Or some error state
}

bool BoardModel::makeMove(int row, int col) {
  if (m_gameOver) {
    qDebug() << "Game is over. Reset to play again.";
    return false;
  }

  if (row >= 0 && row < m_boardSize && col >= 0 && col < m_boardSize &&
      m_board[row][col] == Empty) {
    m_board[row][col] = static_cast<HexState>(m_currentPlayer);
    qDebug() << "Player" << m_currentPlayer << "moved to (" << row << "," << col
             << ")";

    // Emit signal to update UI for this specific hex
    emit hexStateChanged(row, col, m_board[row][col]);

    // Check for win condition
    if (checkWinCondition(m_currentPlayer)) {
      m_gameOver = true;
      emit gameOverChanged();
      qDebug() << "Player" << m_currentPlayer << "wins!";
    } else {
      nextTurn();
    }
    return true;
  }
  qDebug() << "Invalid move at (" << row << "," << col << ")";
  return false;
}

void BoardModel::resetGame() {
  qDebug() << "Resetting game...";
  m_currentPlayer = 1;
  m_gameOver = false;
  initializeBoard(); // Re-initialize the board state
}

void BoardModel::nextTurn() {
  m_currentPlayer = (m_currentPlayer == 1) ? 2 : 1;
  emit currentPlayerChanged();
}

// Dummy win condition check for now.
// You'll replace this with actual Hex win logic (e.g., pathfinding from side to
// side).
bool BoardModel::checkWinCondition(int player) const {
  // For a real Hex game, this involves pathfinding from one side to the other.
  // E.g., Player 1 connects top to bottom, Player 2 connects left to right.
  // This dummy version just checks if the first row is full for Player 1, or
  // last row for Player 2
  if (player == 1) {
    for (int c = 0; c < m_boardSize; ++c) {
      if (m_board[0][c] != Player1)
        return false;
    }
    return true;
  } else if (player == 2) {
    for (int c = 0; c < m_boardSize; ++c) {
      if (m_board[m_boardSize - 1][c] != Player2)
        return false;
    }
    return true;
  }
  return false;
}