#ifndef BOARDMODEL_H
#define BOARDMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>

#include "HexPosition.h"
#include <QVector>

// Define the state of a hex cell
class BoardModel : public QAbstractListModel {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  // Expose properties to QML
  Q_PROPERTY(int boardSize READ boardSize CONSTANT)
  Q_PROPERTY(int currentPlayer READ currentPlayer NOTIFY currentPlayerChanged)
  Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameOverChanged)

public:
  // Enum for hex state (can be made public in BoardModel)
  enum HexState { Empty = 0, Player1 = 1, Player2 = 2 };
  Q_ENUM(HexState) // Makes HexState enum accessible in QML

  enum HexRoles { HexRowRole = Qt::UserRole + 1, HexColRole };
  Q_ENUM(HexRoles) // This allows you to use BoardModel.HexRowRole in QML

  BoardModel(QObject *parent = nullptr);

  // QAbstractListModel overrides
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index,
                int role = Qt::DisplayRole) const override;
  QHash<int, QByteArray> roleNames() const override;

  int boardSize() const { return m_boardSize; }
  int currentPlayer() const { return m_currentPlayer; }
  bool gameOver() const { return m_gameOver; }

  // Q_INVOKABLE methods are callable from QML
  Q_INVOKABLE int getHexState(int row, int col) const;
  Q_INVOKABLE bool makeMove(int row, int col);
  Q_INVOKABLE void resetGame();

signals:
  // Signals to notify QML about changes
  void boardChanged(); // Emitted when the entire board state might have changed
  void hexStateChanged(int row, int col,
                       BoardModel::HexState newState); // Specific hex change
  void currentPlayerChanged();
  void gameOverChanged();
  void unitMoved(int fromRow, int fromCol, int toRow,
                 int toCol); // For future unit movement

private:
  int m_boardSize;
  QVector<HexPosition *> m_hexPositions; // Stores the positions of hexes
  QVector<QVector<HexState>> m_board;    // 2D array to store hex states
  int m_currentPlayer;                   // 1 or 2
  bool m_gameOver;

  // Helper functions for game logic (not exposed to QML directly)
  void initializeBoard();
  void nextTurn();
  bool checkWinCondition(int player) const; // Placeholder for win logic
};

// Allow for easier access of the enum type in QML
typedef BoardModel::HexState HexState;

#endif // BOARDMODEL_H