#include "HexItem.h"
#include <QBrush>
#include <QPen>
#include <QGraphicsSceneMouseEvent>
#include <QDebug>
#include <QtMath> // For qSin, qCos, M_PI

HexItem::HexItem(int row, int col, qreal size, QGraphicsItem *parent)
    : QGraphicsPolygonItem(createHexagonPolygon(size), parent),
      m_row(row),
      m_col(col),
      m_size(size),
      m_state(Empty)
{
    setAcceptHoverEvents(true); // Enable hover events
    updateAppearance();
}

QPolygonF HexItem::createHexagonPolygon(qreal size)
{
    QPolygonF hexagon;
    for (int i = 0; i < 6; ++i) {
        qreal angle_deg = 60 * i - 30; // Start at top flat side, adjust for pointy top if needed
        qreal angle_rad = qDegreesToRadians(angle_deg);
        hexagon << QPointF(size * qCos(angle_rad), size * qSin(angle_rad));
    }
    return hexagon;
}

void HexItem::setState(State newState)
{
    if (m_state != newState) {
        m_state = newState;
        updateAppearance();
    }
}

void HexItem::updateAppearance()
{
    QColor fillColor;
    QColor borderColor = Qt::black; // Default border color

    switch (m_state) {
        case Empty:
            fillColor = Qt::lightGray;
            break;
        case Player1:
            fillColor = Qt::blue;
            break;
        case Player2:
            fillColor = Qt::red;
            break;
    }

    // Set pen for border and brush for fill
    setPen(QPen(borderColor, 1));
    setBrush(QBrush(fillColor));
}

void HexItem::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        qDebug() << "Hex clicked: Row" << m_row << ", Col" << m_col;
        // Simple state change for demonstration
        if (m_state == Empty) {
            setState(Player1);
        } else if (m_state == Player1) {
            setState(Player2);
        } else {
            setState(Empty);
        }
    }
    QGraphicsPolygonItem::mousePressEvent(event); // Call base class implementation
}

void HexItem::hoverEnterEvent(QGraphicsSceneHoverEvent *event)
{
    setPen(QPen(Qt::darkGreen, 2)); // Thicker, green border on hover
    QGraphicsPolygonItem::hoverEnterEvent(event);
}

void HexItem::hoverLeaveEvent(QGraphicsSceneHoverEvent *event)
{
    updateAppearance(); // Revert to normal appearance
    QGraphicsPolygonItem::hoverLeaveEvent(event);
}