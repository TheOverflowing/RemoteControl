#include "VideoSurface.h"
#include <QPainter>
#include <QDebug>

VideoSurface::VideoSurface(QObject *parent)
    : QObject(parent)
    , m_videoSink(new QVideoSink(this))
    , _imageFormat(QImage::Format_Invalid)
    , _frameTimer(new QTimer(this))
    , _hasQueuedFrame(false)
{
    connect(m_videoSink, &QVideoSink::videoFrameChanged, 
            this, &VideoSurface::onVideoFrameChanged);
    
    // Setup frame rate limiting timer
    _frameTimer->setSingleShot(true);
    connect(_frameTimer, &QTimer::timeout, this, &VideoSurface::processQueuedFrame);
}

VideoSurface::~VideoSurface()
{
    // Stop timer and clear frames to prevent memory leaks
    if (_frameTimer && _frameTimer->isActive()) {
        _frameTimer->stop();
    }
    
    // Clear stored frames
    _currentFrame = QVideoFrame();
    _queuedFrame = QVideoFrame();
    _hasQueuedFrame = false;
}

void VideoSurface::onVideoFrameChanged(const QVideoFrame &frame)
{
    if (!frame.isValid()) {
        return;
    }

    // Store the latest frame but don't process it immediately
    _queuedFrame = frame;
    _hasQueuedFrame = true;
    
    // Only start timer if it's not already running (frame rate limiting)
    if (!_frameTimer->isActive()) {
        processQueuedFrame();
    }
}

void VideoSurface::processQueuedFrame()
{
    if (!_hasQueuedFrame || !_queuedFrame.isValid()) {
        return;
    }
    
    // Clear previous frame explicitly to avoid memory buildup
    if (_currentFrame.isValid()) {
        _currentFrame = QVideoFrame(); // Clear old frame
    }
    
    _currentFrame = _queuedFrame;
    _imageSize = _currentFrame.size();
    updateVideoRect();
    
    // Send frame to VideoSink for QML VideoOutput
    if (m_videoSink) {
        m_videoSink->setVideoFrame(_currentFrame);
    }
    
    emit frameAvailable(_currentFrame);
    emit frameChanged();
    
    // Clear the queued frame to free memory
    _queuedFrame = QVideoFrame();
    _hasQueuedFrame = false;
    
    // Start timer for next frame processing
    _frameTimer->start(FRAME_RATE_MS);
}

QImage VideoSurface::videoFrameToImage(const QVideoFrame &frame)
{
    if (!frame.isValid()) {
        return QImage();
    }

    QVideoFrame cloneFrame(frame);
    if (!cloneFrame.map(QVideoFrame::ReadOnly)) {
        qWarning() << "Failed to map video frame";
        return QImage();
    }
    
    QImage image = cloneFrame.toImage();
    
    cloneFrame.unmap();
    return image;
}

QRect VideoSurface::videoRect() const
{
    return _targetRect;
}

void VideoSurface::updateVideoRect()
{
    if (_imageSize.isEmpty()) {
        _targetRect = QRect();
        return;
    }
    
    _targetRect = QRect(QPoint(0, 0), _imageSize);
}

void VideoSurface::paint(QPainter *painter)
{
    if (!_currentFrame.isValid()) {
        return;
    }

    QImage image = videoFrameToImage(_currentFrame);
    if (!image.isNull()) {
        painter->drawImage(_targetRect, image);
    }
} 