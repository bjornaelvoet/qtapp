#ifndef HEXCOORDCONVERTER_H
#define HEXCOORDCONVERTER_H

#include <QObject>
#include <QPointF> // For pixel coordinates

class HexCoordConverter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal hexRadius READ hexRadius CONSTANT) // Expose hex radius for QML

public:
    explicit HexCoordConverter(qreal radius, QObject *parent = nullptr);

    qreal hexRadius() const { return m_hexRadius; }

    // Q_INVOKABLE methods to convert coordinates
    Q_INVOKABLE QPointF hexToPixel(int row, int col) const;
    // Q_INVOKABLE QPoint hexToAxial(int row, int col) const; // If you use axial internally
    // Q_INVOKABLE QPoint pixelToHex(qreal x, qreal y) const; // More complex, for later

private:
    qreal m_hexRadius; // Distance from center to vertex (r)

    // Cached hex dimensions for calculation
    qreal m_hexWidth;  // Side-to-side distance (w = r * sqrt(3))
    qreal m_hexHeight; // Vertex-to-vertex distance (h = 2 * r)

    // Spacing between hex centers for a flat-top offset grid
    qreal m_xOffsetStep; // Horizontal step for columns
    qreal m_yOffsetStep; // Vertical step between row centers
};

#endif // HEXCOORDCONVERTER_H