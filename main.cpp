#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSurfaceFormat>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QSurfaceFormat format;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

