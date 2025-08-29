#ifndef VIDEOSURFACE_H
#define VIDEOSURFACE_H

#include <QObject>
#include <QVideoSink>
#include <QVideoFrame>
#include <QRect>
#include <QSize>
#include <QImage>
#include <QPainter>
#include <QTimer>

class VideoSurface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVideoSink* videoSink READ videoSink CONSTANT)
    
public:
    explicit VideoSurface(QObject *parent = nullptr);
    ~VideoSurface();
    
    QVideoSink* videoSink() const { return m_videoSink; }
    
    QRect videoRect() const;
    void updateVideoRect();
    void paint(QPainter *painter);

private slots:
    void onVideoFrameChanged(const QVideoFrame &frame);
    void processQueuedFrame();

private:
    QVideoSink* m_videoSink;
    QRect _targetRect;
    QSize _imageSize;
    QVideoFrame _currentFrame;
    QImage::Format _imageFormat;
    
    // Frame rate limiting
    QTimer* _frameTimer;
    QVideoFrame _queuedFrame;
    bool _hasQueuedFrame;
    static const int FRAME_RATE_MS = 100; // 10 FPS limit to reduce memory pressure
    
    QImage videoFrameToImage(const QVideoFrame &frame);

signals:
    void frameAvailable(QVideoFrame frame);
    void frameChanged();
};

#endif // VIDEOSURFACE_H 