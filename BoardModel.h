#ifndef BOARDMODEL_H
#define BOARDMODEL_H

#include <QJSEngine> // Required for QJSEngine in qmlInstance signature
#include <QObject>
#include <QPoint>     // For representing hex coordinates
#include <QQmlEngine> // Required for QQmlEngine in qmlInstance signature
#include <QVector>
#include <QtQml/qqmlregistration.h> // For QML_SINGLETON

// Define the state of a hex cell
class BoardModel : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  QML_NAMED_ELEMENT(boardModel)
public:
  BoardModel(QObject *parent = nullptr) : QObject(parent), m_boardSize(10) {}

private:
  // Expose properties to QML
  Q_PROPERTY(int boardSize READ boardSize CONSTANT)
  Q_PROPERTY(QVector<QPoint> hexPositions READ hexPositions NOTIFY boardChanged)
  Q_PROPERTY(int currentPlayer READ currentPlayer NOTIFY currentPlayerChanged)
  Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameOverChanged)

public:
  // Enum for hex state (can be made public in BoardModel)
  enum HexState { Empty = 0, Player1 = 1, Player2 = 2 };
  Q_ENUM(HexState) // Makes HexState enum accessible in QML
  // This is the constructor used by qmlInstance.
  // The explicit BoardModel(int size, ...) constructor declaration is removed
  // to avoid potential ambiguity during QML module generation.
  BoardModel(int size, QObject *parent = nullptr);

  // This static method is required by QML_SINGLETON to provide the instance
  static BoardModel *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

  int boardSize() const { return m_boardSize; }
  int currentPlayer() const { return m_currentPlayer; }
  bool gameOver() const { return m_gameOver; }

  // This method will provide data for the QML Repeater
  // It returns a list of QPoint (row, col) for each hex
  QVector<QPoint> hexPositions() const;

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
  QVector<QVector<HexState>> m_board; // 2D array to store hex states
  int m_currentPlayer;                // 1 or 2
  bool m_gameOver;

  // Helper functions for game logic (not exposed to QML directly)
  void initializeBoard();
  void nextTurn();
  bool checkWinCondition(int player) const; // Placeholder for win logic
};

// Allow for easier access of the enum type in QML
typedef BoardModel::HexState HexState;

#endif // BOARDMODEL_H