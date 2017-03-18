#include <iostream>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <QObject>
#include <QDebug>
#include <QString>
#include <functional>

#include "XbeeInterface.hpp"
#include "../xbeeplus/include/SerialXbee.hpp"
#include "../xbeeplus/include/ReceivePacket.hpp"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    // must register types before loading application
    qmlRegisterSingletonType<XbeeInterface>("XbeeInterfaceClass", 1, 0, "XbeeInterface", singleton_MessageHandler);

    qDebug() << "App not loaded yet";
    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));


    return app.exec();
}
