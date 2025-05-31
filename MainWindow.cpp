#include "MainWindow.h"
#include <QVBoxLayout>
#include <QWidget>
#include <QDebug>
#include <QTimer>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("Qt Hex Game");
    resize(800, 600); // Initial window size

    // Create the Hex Board Scene
    m_hexScene = new HexBoardScene(BOARD_SIZE, HEX_RADIUS, this);

    // Create the Graphics View and set the scene
    m_graphicsView = new QGraphicsView(m_hexScene, this);
    m_graphicsView->setRenderHint(QPainter::Antialiasing); // Smooth edges
    m_graphicsView->setDragMode(QGraphicsView::ScrollHandDrag); // Allow dragging the view
    m_graphicsView->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_graphicsView->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    // Set the central widget
    QWidget *centralWidget = new QWidget(this);
    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
    mainLayout->addWidget(m_graphicsView);

    setCentralWidget(centralWidget);

    // Initial fit of the view to the scene
    // Use a singleShot timer to give the UI a chance to fully render and size itself
    QTimer::singleShot(0, this, [this](){
        m_graphicsView->fitInView(m_hexScene->sceneRect(), Qt::KeepAspectRatio);
    });
}

MainWindow::~MainWindow()
{
    // Scene and view are child objects, so they will be deleted by parent
    // when the parent is deleted. No explicit delete needed here.
}