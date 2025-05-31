#ifndef HEXBOARDSCENE_H
#define HEXBOARDSCENE_H

#include <QGraphicsScene>
#include <QVector>
#include "HexItem.h"

class HexBoardScene : public QGraphicsScene
{
    Q_OBJECT
public:
    HexBoardScene(int boardSize, qreal hexSize, QObject *parent = nullptr);

private:
    int m_boardSize; // N for an N x N hex board (diameter)
    qreal m_hexSize; // Distance from center to vertex

    QVector<QVector<HexItem*>> m_hexItems; // Store references to hex items

    void createBoard();
};

#endif // HEXBOARDSCENE_H