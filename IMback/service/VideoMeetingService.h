#ifndef VIDEOMEETINGSERVICE_H
#define VIDEOMEETINGSERVICE_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QThread>
#include <QMap>
#include <QUuid>
#include <QTimer>

struct VideoMeetingRoom {
    QString roomId;
    QString hostId;
    QList<QTcpSocket*> participants;
    qint64 createdTime;
    bool isActive;
    
    VideoMeetingRoom() : createdTime(0), isActive(false) {}
};

enum VideoMessageType {
    VIDEO_CREATE_MEETING = 100,
    VIDEO_JOIN_MEETING = 101,
    VIDEO_EXIT_MEETING = 102,
    VIDEO_IMG_SEND = 103,
    VIDEO_AUDIO_SEND = 104,
    VIDEO_CLOSE_CAMERA = 105,
    
    VIDEO_CREATE_MEETING_RESPONSE = 120,
    VIDEO_JOIN_MEETING_RESPONSE = 121,
    VIDEO_PARTNER_JOIN = 122,
    VIDEO_PARTNER_EXIT = 123,
    VIDEO_IMG_RECV = 124,
    VIDEO_AUDIO_RECV = 125
};

class VideoMeetingService : public QObject
{
    Q_OBJECT

public:
    explicit VideoMeetingService(QObject *parent = nullptr);
    ~VideoMeetingService();
    
    bool startServer(quint16 port = 8888);
    void stopServer();
    
    QString createMeeting(QTcpSocket *hostSocket);
    bool joinMeeting(QTcpSocket *clientSocket, const QString &roomId);
    void exitMeeting(QTcpSocket *clientSocket);
    
    void broadcastToRoom(const QString &roomId, VideoMessageType msgType, 
                        const QByteArray &data, QTcpSocket *sender = nullptr);

private slots:
    void onNewConnection();
    void onClientDisconnected();
    void onDataReceived();
    void cleanupInactiveRooms();

private:
    void processMessage(QTcpSocket *client, VideoMessageType msgType, const QByteArray &data);
    void sendMessage(QTcpSocket *client, VideoMessageType msgType, const QByteArray &data);
    QString findRoomBySocket(QTcpSocket *socket);
    void removeSocketFromAllRooms(QTcpSocket *socket);

private:
    QTcpServer *_server;
    QMap<QString, VideoMeetingRoom*> _rooms;
    QMap<QTcpSocket*, QString> _socketToRoom;
    QTimer *_cleanupTimer;
    
    static const int MAX_ROOM_IDLE_TIME = 3600000; // 1小时
};

#endif // VIDEOMEETINGSERVICE_H 