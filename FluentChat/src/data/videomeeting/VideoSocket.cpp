#include "VideoSocket.h"
#include <QDataStream>
#include <QDebug>

VideoSocket::VideoSocket(QObject *parent)
    : QTcpSocket(parent), _blocksize(0)
{
    connect(this, &QTcpSocket::connected, this, &VideoSocket::onConnected);
    connect(this, &QTcpSocket::disconnected, this, &VideoSocket::onDisconnected);
    connect(this, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &VideoSocket::onError);
    connect(this, &QTcpSocket::readyRead, this, &VideoSocket::onReadyRead);
}

void VideoSocket::setBlockSize(quint32 blocksize)
{
    _blocksize = blocksize;
}

void VideoSocket::connectVideo(const QString &hostName, quint16 port)
{
    connectToHost(hostName, port);
}

void VideoSocket::sendVideoMessage(VIDEO_MSG_TYPE msgType, const QByteArray &data)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_6_0);
    
    out << (quint32)0;
    out << (quint32)msgType;
    out << data;
    
    out.device()->seek(0);
    out << (quint32)(block.size() - sizeof(quint32));
    
    write(block);
    flush();
}

void VideoSocket::onConnected()
{
    qDebug() << "Video socket connected";
    emit videoConnected();
}

void VideoSocket::onDisconnected()
{
    qDebug() << "Video socket disconnected";
    emit videoDisconnected();
}

void VideoSocket::onError(QAbstractSocket::SocketError error)
{
    qDebug() << "Video socket error:" << errorString();
    emit videoSocketError(error);
}

void VideoSocket::onReadyRead()
{
    QDataStream in(this);
    in.setVersion(QDataStream::Qt_6_0);
    
    while (bytesAvailable() > 0) {
        if (_blocksize == 0) {
            if (bytesAvailable() < sizeof(quint32)) {
                return;
            }
            in >> _blocksize;
        }
        
        if (bytesAvailable() < _blocksize) {
            return;
        }
        
        quint32 msgType;
        QByteArray data;
        in >> msgType >> data;
        
        VIDEO_MESG *msg = new VIDEO_MESG;
        msg->msg_type = (VIDEO_MSG_TYPE)msgType;
        msg->len = data.size();
        msg->data = new uchar[msg->len];
        memcpy(msg->data, data.data(), msg->len);
        msg->ip = peerAddress().toIPv4Address();
        
        emit videoMessageReceived(msg);
        
        _blocksize = 0;
    }
} 