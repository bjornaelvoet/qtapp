#include "HexBoardScene.h"
#include <QtMath>

HexBoardScene::HexBoardScene(int boardSize, qreal hexSize, QObject *parent)
    : QGraphicsScene(parent),
      m_boardSize(boardSize),
      m_hexSize(hexSize)
{
    createBoard();
}

void HexBoardScene::createBoard()
{
    // Dimensions of a flat-top hexagon:
    // m_hexSize is the distance from center to vertex (radius 'r')
    qreal hexWidth = m_hexSize * qSqrt(3);  // Side-to-side distance (w = r * sqrt(3))
    qreal hexHeight = m_hexSize * 2;       // Vertex-to-vertex distance (h = 2 * r)

    // Spacing between hex centers for a flat-top offset grid:
    qreal xOffset = hexWidth;                 // Full width for non-offset columns
    qreal yOffset = m_hexSize * 1.5;          // 1.5 * radius for vertical step between row centers

    m_hexItems.resize(m_boardSize);

    for (int row = 0; row < m_boardSize; ++row) {
        m_hexItems[row].resize(m_boardSize);
        for (int col = 0; col < m_boardSize; ++col) {
            HexItem *hex = new HexItem(row, col, m_hexSize);

            // Calculate position for flat-top hexagons with an "odd-r" offset coordinate system
            // (Red Blob Games: https://www.redblobgames.com/grids/hexagons/#coordinates-offset)
            qreal x = col * xOffset;
            qreal y = row * yOffset;

            if (row % 2 != 0) { // If odd row, offset x position by half a hex width
                x += hexWidth / 2;
            }

            hex->setPos(x, y);
            addItem(hex);
            m_hexItems[row][col] = hex;
        }
    }

    // Centering the board and setting sceneRect *after* all items are added and positioned
    // Find the tight bounding rect of all items
    QRectF bounds = itemsBoundingRect(); // This gets the union bounding rect of ALL items
    qDebug() << "Items Bounding Rect Before Centering:" << bounds;

    // Adjust the position of all items to center them around (0,0) or some desired origin
    qreal offsetX = -bounds.center().x();
    qreal offsetY = -bounds.center().y();

    for (int row = 0; row < m_boardSize; ++row) {
        for (int col = 0; col < m_boardSize; ++col) {
            HexItem *hex = m_hexItems[row][col];
            hex->setPos(hex->pos().x() + offsetX, hex->pos().y() + offsetY);
        }
    }

    // Now, set the sceneRect to encompass all items precisely
    setSceneRect(itemsBoundingRect()); // Recalculate after centering
    qDebug() << "Final Scene Rect After Centering:" << sceneRect();
    }