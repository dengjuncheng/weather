#ifndef BACKGROUNDDOWNLOADER_H
#define BACKGROUNDDOWNLOADER_H

#include <QObject>
#include <QThread>

class QNetworkAccessManager;
class BackgroundDownloaderThread;
class BackgroundDownloader : public QObject
{
    Q_OBJECT
public:
    explicit BackgroundDownloader(QObject *parent = nullptr);

    virtual ~BackgroundDownloader();

    void startWork(QStringList* names);

signals:
    void downloadComplete();

private:
    QThread thread;
    BackgroundDownloaderThread * workObj;
};

class BackgroundDownloaderThread: public QObject
{
    Q_OBJECT
public:
    explicit BackgroundDownloaderThread(QObject *parent = nullptr);
    virtual ~BackgroundDownloaderThread();
signals:
    void downloadComplete();
public slots:
    void progress();
    void setValue(QStringList * list);
    void deleteValue();
private:
    QStringList* targetDownload;
    QNetworkAccessManager * networkManager;
};

#endif // BACKGROUNDDOWNLOADER_H
