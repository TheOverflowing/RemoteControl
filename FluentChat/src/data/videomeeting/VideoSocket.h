#ifndef VIDEOSOCKET_H
#define VIDEOSOCKET_H

#include <QTcpSocket>
#include <QAbstractSocket>
#include <QHostAddress>
#include "VideoMeetingHeader.h"

class VideoSocket : public QTcpSocket
{
    Q_OBJECT

private:
    quint32 _blocksize;

public:
    VideoSocket(QObject *parent = nullptr);
    
    void setBlockSize(quint32 blocksize);
    void connectVideo(const QString &hostName, quint16 port);
    void sendVideoMessage(VIDEO_MSG_TYPE msgType, const QByteArray &data = QByteArray());

public slots:
    void onConnected();
    void onDisconnected();
    void onError(QAbstractSocket::SocketError);
    void onReadyRead();

signals:
    void videoMessageReceived(VIDEO_MESG *msg);
    void videoSocketError(QAbstractSocket::SocketError);
    void videoConnected();
    void videoDisconnected();
};

#endif // VIDEOSOCKET_H 