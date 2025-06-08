#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "xmlUnloading.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Регистрация C++ класса для использования в QML
    qmlRegisterType<XmlUnloading>("XmlUnloading", 1, 0, "XmlUnloading");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/test/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
