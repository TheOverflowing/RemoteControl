#include "VideoMeetingService.h"
#include <QDataStream>
#include <QDebug>
#include <QDateTime>

VideoMeetingService::VideoMeetingService(QObject *parent)
    : QObject(parent)
    , _server(nullptr)
    , _cleanupTimer(nullptr)
{
    _server = new QTcpServer(this);
    connect(_server, &QTcpServer::newConnection, this, &VideoMeetingService::onNewConnection);
    
    _cleanupTimer = new QTimer(this);
    connect(_cleanupTimer, &QTimer::timeout, this, &VideoMeetingService::cleanupInactiveRooms);
    _cleanupTimer->start(60000); // 每分钟清理一次
}

VideoMeetingService::~VideoMeetingService()
{
    stopServer();
    
    // 清理所有房间
    for (auto room : _rooms.values()) {
        delete room;
    }
    _rooms.clear();
}

bool VideoMeetingService::startServer(quint16 port)
{
    if (_server->listen(QHostAddress::Any, port)) {
        qDebug() << "Video meeting server started on port:" << port;
        return true;
    } else {
        qDebug() << "Failed to start video meeting server:" << _server->errorString();
        return false;
    }
}

void VideoMeetingService::stopServer()
{
    if (_server && _server->isListening()) {
        _server->close();
        qDebug() << "Video meeting server stopped";
    }
}

QString VideoMeetingService::createMeeting(QTcpSocket *hostSocket)
{
    QString roomId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    
    VideoMeetingRoom *room = new VideoMeetingRoom();
    room->roomId = roomId;
    room->hostId = QString::number(reinterpret_cast<quint64>(hostSocket));
    room->participants.append(hostSocket);
    room->createdTime = QDateTime::currentMSecsSinceEpoch();
    room->isActive = true;
    
    _rooms[roomId] = room;
    _socketToRoom[hostSocket] = roomId;
    
    qDebug() << "Created meeting room:" << roomId << "by host:" << room->hostId;
    
    return roomId;
}

bool VideoMeetingService::joinMeeting(QTcpSocket *clientSocket, const QString &roomId)
{
    if (!_rooms.contains(roomId)) {
        qDebug() << "Room not found:" << roomId;
        return false;
    }
    
    VideoMeetingRoom *room = _rooms[roomId];
    if (!room->isActive) {
        qDebug() << "Room is not active:" << roomId;
        return false;
    }
    
    room->participants.append(clientSocket);
    _socketToRoom[clientSocket] = roomId;
    
    // 通知房间内其他人有新成员加入
    QByteArray joinData = QString::number(reinterpret_cast<quint64>(clientSocket)).toUtf8();
    broadcastToRoom(roomId, VIDEO_PARTNER_JOIN, joinData, clientSocket);
    
    qDebug() << "Client joined meeting room:" << roomId;
    
    return true;
}

void VideoMeetingService::exitMeeting(QTcpSocket *clientSocket)
{
    QString roomId = findRoomBySocket(clientSocket);
    if (roomId.isEmpty()) {
        return;
    }
    
    VideoMeetingRoom *room = _rooms[roomId];
    if (room) {
        room->participants.removeAll(clientSocket);
        
        // 通知房间内其他人有成员离开
        QByteArray exitData = QString::number(reinterpret_cast<quint64>(clientSocket)).toUtf8();
        broadcastToRoom(roomId, VIDEO_PARTNER_EXIT, exitData, clientSocket);
        
        // 如果房间没有人了，关闭房间
        if (room->participants.isEmpty()) {
            room->isActive = false;
            qDebug() << "Room became empty, deactivating:" << roomId;
        }
    }
    
    _socketToRoom.remove(clientSocket);
    qDebug() << "Client exited meeting room:" << roomId;
}

void VideoMeetingService::broadcastToRoom(const QString &roomId, VideoMessageType msgType, 
                                         const QByteArray &data, QTcpSocket *sender)
{
    if (!_rooms.contains(roomId)) {
        return;
    }
    
    VideoMeetingRoom *room = _rooms[roomId];
    for (QTcpSocket *socket : room->participants) {
        if (socket != sender && socket->state() == QTcpSocket::ConnectedState) {
            sendMessage(socket, msgType, data);
        }
    }
}

void VideoMeetingService::onNewConnection()
{
    while (_server->hasPendingConnections()) {
        QTcpSocket *clientSocket = _server->nextPendingConnection();
        
        connect(clientSocket, &QTcpSocket::disconnected, this, &VideoMeetingService::onClientDisconnected);
        connect(clientSocket, &QTcpSocket::readyRead, this, &VideoMeetingService::onDataReceived);
        
        qDebug() << "New video meeting client connected:" << clientSocket->peerAddress().toString();
    }
}

void VideoMeetingService::onClientDisconnected()
{
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket*>(sender());
    if (clientSocket) {
        exitMeeting(clientSocket);
        qDebug() << "Video meeting client disconnected:" << clientSocket->peerAddress().toString();
        clientSocket->deleteLater();
    }
}

void VideoMeetingService::onDataReceived()
{
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket*>(sender());
    if (!clientSocket) {
        return;
    }
    
    QDataStream in(clientSocket);
    in.setVersion(QDataStream::Qt_6_0);
    
    while (clientSocket->bytesAvailable() > 0) {
        static quint32 blockSize = 0;
        
        if (blockSize == 0) {
            if (clientSocket->bytesAvailable() < sizeof(quint32)) {
                return;
            }
            in >> blockSize;
        }
        
        if (clientSocket->bytesAvailable() < blockSize) {
            return;
        }
        
        quint32 msgType;
        QByteArray data;
        in >> msgType >> data;
        
        processMessage(clientSocket, static_cast<VideoMessageType>(msgType), data);
        
        blockSize = 0;
    }
}

void VideoMeetingService::cleanupInactiveRooms()
{
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    QStringList roomsToDelete;
    
    for (auto it = _rooms.begin(); it != _rooms.end(); ++it) {
        VideoMeetingRoom *room = it.value();
        if (!room->isActive && (currentTime - room->createdTime) > MAX_ROOM_IDLE_TIME) {
            roomsToDelete.append(it.key());
        }
    }
    
    for (const QString &roomId : roomsToDelete) {
        delete _rooms[roomId];
        _rooms.remove(roomId);
        qDebug() << "Cleaned up inactive room:" << roomId;
    }
}

void VideoMeetingService::processMessage(QTcpSocket *client, VideoMessageType msgType, const QByteArray &data)
{
    switch (msgType) {
        case VIDEO_CREATE_MEETING: {
            QString roomId = createMeeting(client);
            sendMessage(client, VIDEO_CREATE_MEETING_RESPONSE, roomId.toUtf8());
            break;
        }
        
        case VIDEO_JOIN_MEETING: {
            QString roomId = QString::fromUtf8(data);
            if (joinMeeting(client, roomId)) {
                sendMessage(client, VIDEO_JOIN_MEETING_RESPONSE, roomId.toUtf8());
            } else {
                sendMessage(client, VIDEO_JOIN_MEETING_RESPONSE, QByteArray("FAILED"));
            }
            break;
        }
        
        case VIDEO_EXIT_MEETING: {
            exitMeeting(client);
            break;
        }
        
        case VIDEO_IMG_SEND: {
            QString roomId = findRoomBySocket(client);
            if (!roomId.isEmpty()) {
                broadcastToRoom(roomId, VIDEO_IMG_RECV, data, client);
            }
            break;
        }
        
        case VIDEO_AUDIO_SEND: {
            QString roomId = findRoomBySocket(client);
            if (!roomId.isEmpty()) {
                broadcastToRoom(roomId, VIDEO_AUDIO_RECV, data, client);
            }
            break;
        }
        
        case VIDEO_CLOSE_CAMERA: {
            QString roomId = findRoomBySocket(client);
            if (!roomId.isEmpty()) {
                QByteArray cameraOffData = QString::number(reinterpret_cast<quint64>(client)).toUtf8();
                broadcastToRoom(roomId, VIDEO_CLOSE_CAMERA, cameraOffData, client);
            }
            break;
        }
        
        default:
            qDebug() << "Unknown video message type:" << msgType;
            break;
    }
}

void VideoMeetingService::sendMessage(QTcpSocket *client, VideoMessageType msgType, const QByteArray &data)
{
    if (!client || client->state() != QTcpSocket::ConnectedState) {
        return;
    }
    
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_6_0);
    
    out << (quint32)0;
    out << (quint32)msgType;
    out << data;
    
    out.device()->seek(0);
    out << (quint32)(block.size() - sizeof(quint32));
    
    client->write(block);
    client->flush();
}

QString VideoMeetingService::findRoomBySocket(QTcpSocket *socket)
{
    return _socketToRoom.value(socket, QString());
}

void VideoMeetingService::removeSocketFromAllRooms(QTcpSocket *socket)
{
    for (auto room : _rooms.values()) {
        room->participants.removeAll(socket);
    }
    _socketToRoom.remove(socket);
} 