#include "HexCoordConverter.h"
#include <QtMath>
#include <QDebug>

HexCoordConverter::HexCoordConverter(qreal radius, QObject *parent)
    : QObject(parent),
      m_hexRadius(radius)
{
    // Pre-calculate common hex dimensions for flat-top hexes
    m_hexWidth = m_hexRadius * qSqrt(3);  // Side-to-side distance (w = r * sqrt(3))
    m_hexHeight = m_hexRadius * 2;       // Vertex-to-vertex distance (h = 2 * r)

    // Spacing for an "odd-r" offset coordinate system (flat-top)
    m_xOffsetStep = m_hexWidth;
    m_yOffsetStep = m_hexRadius * 1.5;

    qDebug() << "HexCoordConverter initialized with radius:" << m_hexRadius;
    qDebug() << "Hex Width:" << m_hexWidth << ", Hex Height:" << m_hexHeight;
}

QPointF HexCoordConverter::hexToPixel(int row, int col) const
{
    qreal x = col * m_xOffsetStep;
    qreal y = row * m_yOffsetStep;

    if (row % 2 != 0) { // If odd row, offset x position by half a hex width
        x += m_hexWidth / 2;
    }

    // You might want to apply a global offset here if you want the board to be centered
    // around (0,0) or start from a specific corner.
    // For now, we'll let QML handle the centering of the entire board.
    return QPointF(x, y);
}