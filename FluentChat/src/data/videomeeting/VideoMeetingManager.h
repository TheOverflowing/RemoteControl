#ifndef VIDEOMEETINGMANAGER_H
#define VIDEOMEETINGMANAGER_H

#include <QObject>
#include <QCamera>
#include <QMediaCaptureSession>
#include <QImageCapture>
#include <QAudioInput>
#include <QAudioOutput>
#include <QAudioSource>
#include <QAudioSink>
#include <QThread>
#include <QMap>
#include "VideoSocket.h"
#include "VideoSurface.h"
#include "VideoMeetingHeader.h"

class VideoMeetingManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isInMeeting READ isInMeeting NOTIFY isInMeetingChanged)
    Q_PROPERTY(bool isCameraOn READ isCameraOn NOTIFY isCameraOnChanged)
    Q_PROPERTY(bool isAudioOn READ isAudioOn NOTIFY isAudioOnChanged)
    Q_PROPERTY(VideoSurface* localVideoSurface READ localVideoSurface CONSTANT)

public:
    explicit VideoMeetingManager(QObject *parent = nullptr);
    ~VideoMeetingManager();

    // 会议控制
    Q_INVOKABLE void createMeeting(const QString &serverHost, quint16 port);
    Q_INVOKABLE void joinMeeting(const QString &serverHost, quint16 port, const QString &meetingId);
    Q_INVOKABLE void exitMeeting();
    
    // 音视频控制
    Q_INVOKABLE void startCamera();
    Q_INVOKABLE void stopCamera();
    Q_INVOKABLE void startAudio();
    Q_INVOKABLE void stopAudio();
    
    // 状态查询
    Q_INVOKABLE bool isInMeeting() const;
    Q_INVOKABLE bool isCameraOn() const;
    Q_INVOKABLE bool isAudioOn() const;
    
    // 视频表面访问
    VideoSurface* localVideoSurface() const;
    Q_INVOKABLE void setLocalVideoSink(QObject* videoSink);
    Q_INVOKABLE void setRemoteVideoSink(QObject* videoSink);

private slots:
    void onVideoMessageReceived(VIDEO_MESG *msg);
    void onVideoConnected();
    void onVideoDisconnected();
    void onCameraImageCaptured(const QVideoFrame &frame);
    void onAudioDataReady();

private:
    void initializeCamera();
    void initializeAudio();
    void sendVideoFrame(const QVideoFrame &frame);
    void sendAudioData(const QByteArray &data);
    void processReceivedMessage(VIDEO_MESG *msg);

private:
    VideoSocket *_videoSocket;
    QCamera *_camera;
    QMediaCaptureSession *_captureSession;
    QImageCapture *_imageCapture;
    VideoSurface *_videoSurface;
    QVideoSink *_localVideoSink;
    QVideoSink* _remoteVideoSink = nullptr;
    
    QAudioInput *_audioInput;
    QAudioOutput *_audioOutput;
    QAudioSource *_audioSource;
    QAudioSink *_audioSink;
    QIODevice *_audioInputDevice;
    QIODevice *_audioOutputDevice;
    
    QThread *_videoThread;
    QThread *_audioThread;
    
    bool _inMeeting;
    bool _cameraOn;
    bool _audioOn;
    
    QString _meetingId;
    QString _serverHost;
    quint16 _serverPort;
    
    QMap<quint32, QByteArray> _participantVideos;

signals:
    void meetingJoined(const QString &meetingId);
    void meetingLeft();
    void participantJoined(quint32 participantId);
    void participantLeft(quint32 participantId);
    void videoFrameReceived(quint32 participantId, const QVideoFrame &frame);
    void audioDataReceived(const QByteArray &data);
    void errorOccurred(const QString &error);
    void isInMeetingChanged();
    void isCameraOnChanged();
    void isAudioOnChanged();
};

#endif // VIDEOMEETINGMANAGER_H 