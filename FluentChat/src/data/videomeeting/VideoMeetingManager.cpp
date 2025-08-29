#include "VideoMeetingManager.h"
#include <QImageCapture>
#include <QMediaCaptureSession>
#include <QDebug>
#include <QBuffer>
#include <QImageWriter>
#include <QAudioFormat>
#include <QAudioDevice>
#include <QMediaDevices>
#include <QVideoSink>

VideoMeetingManager::VideoMeetingManager(QObject *parent)
    : QObject(parent)
    , _videoSocket(nullptr)
    , _camera(nullptr)
    , _captureSession(nullptr)
    , _imageCapture(nullptr)
    , _videoSurface(nullptr)
    , _localVideoSink(nullptr)
    , _audioInput(nullptr)
    , _audioOutput(nullptr)
    , _audioSource(nullptr)
    , _audioSink(nullptr)
    , _audioInputDevice(nullptr)
    , _audioOutputDevice(nullptr)
    , _videoThread(nullptr)
    , _audioThread(nullptr)
    , _inMeeting(false)
    , _cameraOn(false)
    , _audioOn(false)
    , _serverPort(0)
{
    _videoSocket = new VideoSocket(this);
    connect(_videoSocket, &VideoSocket::videoMessageReceived, 
            this, &VideoMeetingManager::onVideoMessageReceived);
    connect(_videoSocket, &VideoSocket::videoConnected, 
            this, &VideoMeetingManager::onVideoConnected);
    connect(_videoSocket, &VideoSocket::videoDisconnected, 
            this, &VideoMeetingManager::onVideoDisconnected);
    
    // 提前创建VideoSurface以便QML可以访问
    _videoSurface = new VideoSurface(this);
    connect(_videoSurface, &VideoSurface::frameAvailable,
            this, &VideoMeetingManager::onCameraImageCaptured);
}

VideoMeetingManager::~VideoMeetingManager()
{
    exitMeeting();
}

void VideoMeetingManager::createMeeting(const QString &serverHost, quint16 port)
{
    _serverHost = serverHost;
    _serverPort = port;
    _meetingId.clear(); // 清空会议ID，表示要创建新会议
    
    _videoSocket->connectVideo(serverHost, port);
}

void VideoMeetingManager::joinMeeting(const QString &serverHost, quint16 port, const QString &meetingId)
{
    _serverHost = serverHost;
    _serverPort = port;
    _meetingId = meetingId;
    
    _videoSocket->connectVideo(serverHost, port);
}

void VideoMeetingManager::exitMeeting()
{
    if (_inMeeting) {
        stopCamera();
        stopAudio();
        
        _videoSocket->sendVideoMessage(VIDEO_EXIT_MEETING);
        _videoSocket->disconnectFromHost();
        
        _inMeeting = false;
        _meetingId.clear(); // 清空会议ID
        emit isInMeetingChanged();
        emit meetingLeft();
    }
    
    // Clean up audio objects
    if (_audioInput) {
        delete _audioInput;
        _audioInput = nullptr;
    }
    if (_audioOutput) {
        delete _audioOutput;
        _audioOutput = nullptr;
    }
    if (_audioSource) {
        delete _audioSource;
        _audioSource = nullptr;
    }
    if (_audioSink) {
        delete _audioSink;
        _audioSink = nullptr;
    }
}

void VideoMeetingManager::startCamera()
{
    if (!_cameraOn) {
        initializeCamera();
        if (_camera) {
            _camera->start();
            _cameraOn = true;
            emit isCameraOnChanged();
        }
    }
}

void VideoMeetingManager::stopCamera()
{
    if (_cameraOn && _camera) {
        _camera->stop();
        _cameraOn = false;
        emit isCameraOnChanged();
        
        if (_inMeeting) {
            _videoSocket->sendVideoMessage(VIDEO_CLOSE_CAMERA);
        }
    }
}

void VideoMeetingManager::startAudio()
{
    if (!_audioOn) {
        initializeAudio();
        if (_audioSource) {
            _audioInputDevice = _audioSource->start();
            if (_audioInputDevice) {
                connect(_audioInputDevice, &QIODevice::readyRead,
                        this, &VideoMeetingManager::onAudioDataReady);
                _audioOn = true;
                emit isAudioOnChanged();
            }
        }
    }
}

void VideoMeetingManager::stopAudio()
{
    if (_audioOn) {
        if (_audioSource) {
            _audioSource->stop();
        }
        if (_audioInputDevice) {
            disconnect(_audioInputDevice, &QIODevice::readyRead,
                       this, &VideoMeetingManager::onAudioDataReady);
            _audioInputDevice = nullptr;
        }
        _audioOn = false;
        emit isAudioOnChanged();
    }
}

bool VideoMeetingManager::isInMeeting() const
{
    return _inMeeting;
}

bool VideoMeetingManager::isCameraOn() const
{
    return _cameraOn;
}

bool VideoMeetingManager::isAudioOn() const
{
    return _audioOn;
}

VideoSurface* VideoMeetingManager::localVideoSurface() const
{
    return _videoSurface;
}

void VideoMeetingManager::setLocalVideoSink(QObject* videoSink)
{
    if (auto sink = qobject_cast<QVideoSink*>(videoSink)) {
        _localVideoSink = sink;
        qDebug() << "Local video sink set successfully";
        
        // 如果摄像头已经初始化，重新设置capture session
        if (_captureSession && _camera) {
            initializeCamera();
        }
    } else {
        qWarning() << "Failed to cast to QVideoSink";
    }
}

void VideoMeetingManager::setRemoteVideoSink(QObject* videoSink)
{
    if (auto sink = qobject_cast<QVideoSink*>(videoSink)) {
        _remoteVideoSink = sink;
        qDebug() << "Remote video sink set successfully";
    } else {
        qWarning() << "Failed to cast to QVideoSink for remote video";
    }
}

void VideoMeetingManager::onVideoMessageReceived(VIDEO_MESG *msg)
{
    processReceivedMessage(msg);
    
    // 清理消息内存
    if (msg->data) {
        delete[] msg->data;
    }
    delete msg;
}

void VideoMeetingManager::onVideoConnected()
{
    qDebug() << "Connected to video meeting server";
    qDebug() << "Current meeting ID:" << _meetingId;
    
    if (_meetingId.isEmpty()) {
        // 创建会议
        qDebug() << "Sending CREATE_MEETING request";
        _videoSocket->sendVideoMessage(VIDEO_CREATE_MEETING);
    } else {
        // 加入会议
        qDebug() << "Sending JOIN_MEETING request for ID:" << _meetingId;
        QByteArray meetingData = _meetingId.toUtf8();
        _videoSocket->sendVideoMessage(VIDEO_JOIN_MEETING, meetingData);
    }
}

void VideoMeetingManager::onVideoDisconnected()
{
    qDebug() << "Disconnected from video meeting server";
    _inMeeting = false;
    _meetingId.clear(); // 清空会议ID
    emit isInMeetingChanged();
    emit meetingLeft();
}

void VideoMeetingManager::onCameraImageCaptured(const QVideoFrame &frame)
{
    if (_inMeeting && _cameraOn) {
        sendVideoFrame(frame);
    }
}

void VideoMeetingManager::onAudioDataReady()
{
    if (_audioInputDevice && _inMeeting && _audioOn) {
        QByteArray data = _audioInputDevice->readAll();
        if (!data.isEmpty()) {
            sendAudioData(data);
        }
    }
}

void VideoMeetingManager::initializeCamera()
{
    if (!_camera) {
        // 检查是否有可用的摄像头
        auto videoDevices = QMediaDevices::videoInputs();
        if (videoDevices.isEmpty()) {
            qWarning() << "No video input devices found!";
            return;
        }
        
        qDebug() << "Available video devices:" << videoDevices.size();
        for (const auto& device : videoDevices) {
            qDebug() << "Video device:" << device.description();
        }
        
        _camera = new QCamera(QMediaDevices::defaultVideoInput(), this);
        _captureSession = new QMediaCaptureSession(this);
        _imageCapture = new QImageCapture(this);
        
        // 连接摄像头错误信号
        connect(_camera, &QCamera::errorOccurred, this, [](QCamera::Error error, const QString &errorString) {
            qWarning() << "Camera error:" << error << errorString;
        });
        
        _captureSession->setCamera(_camera);
        _captureSession->setImageCapture(_imageCapture);
        
        // 优先使用QML的VideoOutput sink来显示视频
        if (_localVideoSink) {
            _captureSession->setVideoSink(_localVideoSink);
            qDebug() << "Using local video sink from QML";
            
            // 连接QML VideoOutput的sink到VideoSurface以捕获frames
            connect(_localVideoSink, &QVideoSink::videoFrameChanged,
                    this, &VideoMeetingManager::onCameraImageCaptured);
        } else {
            _captureSession->setVideoSink(_videoSurface->videoSink());
            qDebug() << "Using VideoSurface's video sink";
        }
        
        qDebug() << "Camera initialized successfully";
    }
}

void VideoMeetingManager::initializeAudio()
{
    if (!_audioInput) {
        QAudioFormat format;
        format.setSampleRate(8000);
        format.setChannelCount(1);
        format.setSampleFormat(QAudioFormat::Int16);
        
        QAudioDevice inputDevice = QMediaDevices::defaultAudioInput();
        QAudioDevice outputDevice = QMediaDevices::defaultAudioOutput();
        
        _audioInput = new QAudioInput(inputDevice, this);
        _audioOutput = new QAudioOutput(outputDevice, this);
        _audioSource = new QAudioSource(inputDevice, format, this);
        _audioSink = new QAudioSink(outputDevice, format, this);
    }
}

void VideoMeetingManager::sendVideoFrame(const QVideoFrame &frame)
{
    if (!frame.isValid() || !_inMeeting || !_cameraOn) {
        return;
    }
    
    QVideoFrame clonedFrame(frame);
    if (!clonedFrame.map(QVideoFrame::ReadOnly)) {
        qWarning() << "Failed to map video frame for sending";
        return;
    }
    
    QImage image = clonedFrame.toImage();
    clonedFrame.unmap(); // Always unmap immediately after conversion
    
    if (image.isNull()) {
        qWarning() << "Failed to convert video frame to image";
        return;
    }
    
    // Scale down image to reduce memory usage and network traffic
    if (image.width() > 640 || image.height() > 480) {
        image = image.scaled(640, 480, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    
    QByteArray imageData;
    QBuffer buffer(&imageData);
    if (!buffer.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open buffer for image data";
        return;
    }
    
    QImageWriter writer(&buffer, "JPEG");
    writer.setQuality(60); // Reduced quality to save memory and bandwidth
    
    if (!writer.write(image)) {
        qWarning() << "Failed to write image to buffer";
        buffer.close();
        return;
    }
    
    buffer.close();
    
    // Only send if we have valid data
    if (!imageData.isEmpty()) {
        _videoSocket->sendVideoMessage(VIDEO_IMG_SEND, imageData);
    }
}

void VideoMeetingManager::sendAudioData(const QByteArray &data)
{
    _videoSocket->sendVideoMessage(VIDEO_AUDIO_SEND, data);
}

void VideoMeetingManager::processReceivedMessage(VIDEO_MESG *msg)
{
    switch (msg->msg_type) {
        case VIDEO_CREATE_MEETING_RESPONSE:
        case VIDEO_JOIN_MEETING_RESPONSE:
            qDebug() << "Received meeting response, setting inMeeting=true";
            _inMeeting = true;
            emit isInMeetingChanged();
            _meetingId = QString::fromUtf8((char*)msg->data, msg->len);
            qDebug() << "Meeting joined with ID:" << _meetingId;
            emit meetingJoined(_meetingId);
            break;
            
        case VIDEO_PARTNER_JOIN:

            emit participantJoined(msg->ip);
            break;
            
        case VIDEO_PARTNER_EXIT:
            emit participantLeft(msg->ip);
            break;
            
        case VIDEO_IMG_RECV: {
            QByteArray imageData((char*)msg->data, msg->len);
            QImage image;
            if (image.loadFromData(imageData, "JPEG")) {
                qDebug() << "Received video frame from participant:" << msg->ip;
                
                // 如果有远程视频sink，将图像转换为QVideoFrame并显示
                if (_remoteVideoSink) {
                    // 将QImage转换为QVideoFrame
                    QVideoFrame frame(QVideoFrameFormat(image.size(), QVideoFrameFormat::Format_BGRA8888));
                    if (frame.map(QVideoFrame::WriteOnly)) {
                        // 将QImage转换为合适的格式
                        QImage convertedImage = image.convertToFormat(QImage::Format_RGBA8888);
                        convertedImage = convertedImage.rgbSwapped(); // RGBA -> BGRA
                        
                        // 复制图像数据到frame
                        memcpy(frame.bits(0), convertedImage.constBits(), convertedImage.sizeInBytes());
                        frame.unmap();
                        
                        // 发送到远程视频sink
                        _remoteVideoSink->setVideoFrame(frame);
                        qDebug() << "Remote video frame displayed";
                    }
                } else {
                    qDebug() << "No remote video sink available";
                }
            }
            break;
        }
        
        case VIDEO_AUDIO_RECV: {
            QByteArray audioData((char*)msg->data, msg->len);
            emit audioDataReceived(audioData);
            
            // 播放音频数据
            if (_audioOutput && _audioOutputDevice) {
                _audioOutputDevice->write(audioData);
            }
            break;
        }
        
        default:
            qDebug() << "Unknown video message type:" << msg->msg_type;
            break;
    }
} 
