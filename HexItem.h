#ifndef HEXITEM_H
#define HEXITEM_H

#include <QGraphicsPolygonItem>
#include <QBrush>
#include <QPen>

class HexItem : public QGraphicsPolygonItem
{
public:
    enum State {
        Empty,
        Player1,
        Player2
    };

    HexItem(int row, int col, qreal size, QGraphicsItem *parent = nullptr);

    // Getters
    int getRow() const { return m_row; }
    int getCol() const { return m_col; }
    State getState() const { return m_state; }

    // Setters
    void setState(State newState);

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event) override;
    void hoverEnterEvent(QGraphicsSceneHoverEvent *event) override;
    void hoverLeaveEvent(QGraphicsSceneHoverEvent *event) override;

private:
    int m_row;
    int m_col;
    qreal m_size; // size is the distance from center to a vertex
    State m_state;

    // Helper to calculate hexagon points
    QPolygonF createHexagonPolygon(qreal size);
    void updateAppearance();
};

#endif // HEXITEM_H