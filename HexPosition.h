// HexPosition.h
#ifndef HEXPOSITION_H
#define HEXPOSITION_H

#include <QObject>

class HexPosition : public QObject {
  Q_OBJECT
  Q_PROPERTY(int row READ row CONSTANT) // CONSTANT if they don't change
  Q_PROPERTY(int col READ col CONSTANT) // CONSTANT if they don't change

public:
  HexPosition(int r, int c, QObject *parent = nullptr);

  int row() const { return m_row; }
  int col() const { return m_col; }

private:
  int m_row;
  int m_col;
};

#endif // HEXPOSITION_H