#ifndef XBEEINTERFACE_HPP
#define XBEEINTERFACE_HPP

#include <QObject>
#include <QDebug>
#include <QString>
#include <QQmlContext>
//#include "../../NGCP/xbeeplus/include/SerialXbee.hpp"
#include "../xbeeplus/include/ReceivePacket.hpp"
#include "../xbeeplus/include/TransmitRequest.hpp"

enum class QuadAddress : uint64_t {
    QUADA = 0x0013A20040A8157E,
    QUADB = 0x0013A20040F8063C,
    QUADC = 0x0013A20040F8064D,
    QUADD = 0x0013A20040A815D6,
    GCS = 0x0013A20040F8064C
};

class XbeeInterface : public QObject
{
    Q_OBJECT
//    Q_PROPERTY (int baudrate READ baudrate WRITE setBaudrate NOTIFY baudrateChanged)
public:
    explicit XbeeInterface(QObject *parent = 0);

    QString name() const {return m_name;}
    void setName(const QString &name) {m_name = name;}

    QString device() const {return m_device;}
    void setDevice(const QString &device) {m_device =  device;}

    int baudrate() const {return m_baudrate;}
    void setBaudrate(const int &baudrate) {m_baudrate = baudrate;}

    void callbackFun(XBEE::Frame *item);

    Q_INVOKABLE void writeMsg(QString msg);

    Q_INVOKABLE void startComms();
    Q_INVOKABLE void stopComms();

    ~XbeeInterface() {}

signals:
    void newMsg(const QString &item);
    void baudrateChanged(int newValue);

public slots:
//    void handleSignalExample(const QVariant& object);

private:

    QString m_name;
    QString m_device;
    int m_baudrate;
    bool comms = false;

    // TODO: Refactor to not be hardcoded
    XBEE::SerialXbee serial_interface;
//    XBEE::TransmitRequest frame_a(0x0013A20040A8157E);
//    XBEE::TransmitRequest frame_b(0x0013A20040F8063C);
//    XBEE::TransmitRequest frame_c(0x0013A20040F8064D);
//    XBEE::TransmitRequest frame_d(0x0013A20040A815D6);

};

static QObject *singleton_MessageHandler(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    qDebug() << "Instantiate Here?";
    XbeeInterface *msgs = new XbeeInterface();
    qDebug() << "Finished instantiation here?";
    return msgs;
}
#endif // XBEEINTERFACE_HPP
