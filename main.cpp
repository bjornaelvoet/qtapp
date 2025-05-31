// main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // To expose C++ objects to QML

#include "BoardModel.h" // Your C++ game logic
#include "HexCoordConverter.h" // Your coordinate utility

int main(int argc, char *argv[])
{
    // Use QGuiApplication for pure QML apps (no QWidgets needed)
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 1. Instantiate your C++ backend classes
    BoardModel gameBoard(11); // e.g., 11x11 board
    HexCoordConverter coordConverter(50.0); // Hex radius 50 pixels

    // 2. Expose C++ objects to the QML context
    // These names (e.g., "boardModel", "coordConverter") are how you access them in QML.
    engine.rootContext()->setContextProperty("boardModel", &gameBoard);
    engine.rootContext()->setContextProperty("coordConverter", &coordConverter);

    // 3. Register your C++ enums for QML
    // This allows QML to use BoardModel.Empty, BoardModel.Player1, etc.
    qmlRegisterUncreatableType<BoardModel>("GameEnums", 1, 0, "BoardModel", "Access enums only");

    // 4. Load your main QML file
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("QtAppQml", "Main");

    return app.exec();
}