#ifndef BACKGROUNDMANAGER_H
#define BACKGROUNDMANAGER_H

#include <QObject>


class QNetworkAccessManager;
class BackgroundDownloader;
class BackgroundManager : public QObject
{
    Q_OBJECT
public:
    explicit BackgroundManager(QObject *parent = nullptr);
    QString getAllBackground();
signals:
    void downloadComplete();
public slots:

private:
    QNetworkAccessManager * m_netWorkManager;
    BackgroundDownloader * downloader;
    QStringList m_localPicNames;
private:
    void downLoad(QStringList *nameList);
};

#endif // BACKGROUNDMANAGER_H
