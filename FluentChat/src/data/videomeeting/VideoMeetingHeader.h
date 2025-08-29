#ifndef VIDEOMEETINGHEADER_H
#define VIDEOMEETINGHEADER_H

#include <QMetaType>
#include <QMutex>
#include <QQueue>
#include <QImage>
#include <QWaitCondition>

#define QUEUE_MAXSIZE 1500
#ifndef MB
#define MB 1024*1024
#endif

#ifndef KB
#define KB 1024
#endif

#ifndef WAITSECONDS
#define WAITSECONDS 2
#endif

#ifndef MSG_HEADER
#define MSG_HEADER 11
#endif

enum VIDEO_MSG_TYPE
{
    VIDEO_CREATE_MEETING = 100,
    VIDEO_JOIN_MEETING = 101,
    VIDEO_EXIT_MEETING = 102,
    VIDEO_IMG_SEND = 103,
    VIDEO_AUDIO_SEND = 104,
    VIDEO_CLOSE_CAMERA = 105,
    VIDEO_TEXT_SEND = 106,
    VIDEO_IMG_RECV,
    VIDEO_AUDIO_RECV,
    VIDEO_TEXT_RECV,

    VIDEO_CREATE_MEETING_RESPONSE = 120,
    VIDEO_JOIN_MEETING_RESPONSE = 121,
    VIDEO_PARTNER_JOIN = 122,
    VIDEO_PARTNER_EXIT = 123,
    VIDEO_IMG_RECV_RESPONSE = 124,
    VIDEO_AUDIO_RECV_RESPONSE = 125,
    VIDEO_RemoteHostClosedError = 140,
    VIDEO_OtherNetError = 141
};
Q_DECLARE_METATYPE(VIDEO_MSG_TYPE);

struct VIDEO_MESG
{
    VIDEO_MSG_TYPE msg_type;
    uchar* data;
    long len;
    quint32 ip;
};
Q_DECLARE_METATYPE(VIDEO_MESG *);

template<class T>
struct VIDEO_QUEUE_DATA
{
private:
    QMutex send_queueLock;
    QWaitCondition send_queueCond;
    QQueue<T*> send_queue;
public:
    void push_msg(T* msg)
    {
        send_queueLock.lock();
        while(send_queue.size() > QUEUE_MAXSIZE)
        {
            send_queueCond.wait(&send_queueLock);
        }
        send_queue.push_back(msg);
        send_queueLock.unlock();
        send_queueCond.wakeOne();
    }

    T* pop_msg()
    {
        send_queueLock.lock();
        while(send_queue.size() == 0)
        {
            bool f = send_queueCond.wait(&send_queueLock, WAITSECONDS * 1000);
            if(f == false)
            {
                send_queueLock.unlock();
                return NULL;
            }
        }
        T* send = send_queue.front();
        send_queue.pop_front();
        send_queueLock.unlock();
        send_queueCond.wakeOne();
        return send;
    }

    void clear()
    {
        send_queueLock.lock();
        send_queue.clear();
        send_queueLock.unlock();
    }
};

#endif // VIDEOMEETINGHEADER_H 