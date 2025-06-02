// main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
  int unusedVariable = 10; // This should trigger an "unused variable" warning

  // Use QGuiApplication for pure QML apps (no QWidgets needed)
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("QtAppQml", "Main");

  return app.exec();
}