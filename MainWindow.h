#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QGraphicsView>
#include "HexBoardScene.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    QGraphicsView *m_graphicsView;
    HexBoardScene *m_hexScene;

    // Board settings
    const int BOARD_SIZE = 11; // 11x11 Hex board
    const qreal HEX_RADIUS = 30.0; // Size from center to vertex
};

#endif // MAINWINDOW_H