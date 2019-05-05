#include "backgroundmanager.h"
#include <utils.h>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QDebug>
#include <QGuiApplication>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <backgrounddownloader.h>

/**
 * 构造函数读取本地背景图片列表名字
 * @brief BackgroundManager::BackgroundManager
 * @param parent
 */
BackgroundManager::BackgroundManager(QObject *parent) : QObject(parent), m_netWorkManager(new QNetworkAccessManager(this))
{
    QString url = Utils::getBackgroundPath();
    QDir dir;
    if(!dir.exists(url)){
        bool res = dir.mkdir(url);
        qDebug() << res;
    }

    dir.setPath(url);
    QStringList nameFilter;
    nameFilter << "*.jpg" << "*.png";
    m_localPicNames = dir.entryList(nameFilter, QDir::Files|QDir::Readable, QDir::Name);
    qDebug() << "已存在背景图片：" << m_localPicNames;

    //初始化下载器
    downloader = new BackgroundDownloader();

    connect(downloader, &BackgroundDownloader::downloadComplete, this, &BackgroundManager::downloadComplete);
}


QString BackgroundManager::getAllBackground()
{
    QString ip = Utils::getAllConfig().value("ip");
    QNetworkRequest request;
    request.setUrl(QUrl("http://" + ip + ":8080/api/weather/v1/background/list"));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QNetworkReply* reply = m_netWorkManager->get(request);

    //添加事件循环
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "request protobufHttp NoError";
    }
    else
    {
        qDebug()<<"request protobufHttp handle errors here";
        QVariant statusCodeV = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
        //statusCodeV是HTTP服务器的相应码，reply->error()是Qt定义的错误码，可以参考QT的文档
        qDebug( "request protobufHttp found error ....code: %d %d\n", statusCodeV.toInt(), (int)reply->error());
        qDebug(qPrintable(reply->errorString()));
    }

    QByteArray data = reply->readAll();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    QStringList nameList;
    QStringList *unsynchronizedFile = new QStringList;
    if(doc.isObject()){
        QJsonObject obj = doc.object();
        if(obj.contains("success")){
            QJsonValue value = obj.take("success");
            if(!value.toBool()){
                return "{}";
            }
        }
        if(obj.contains("data")){
            QJsonArray arr = obj.take("data").toArray();
            int size = arr.size();
            for(int i = 0 ; i < size ; ++i){
                QString v2 = arr.at(i).toString();
                nameList << v2;
                if(!this->m_localPicNames.contains(v2)){
                    unsynchronizedFile -> append(v2);
                }
            }

        }
    }

    downLoad(unsynchronizedFile);
    return data;
}

void BackgroundManager::downLoad(QStringList *nameList)
{
   downloader->startWork(nameList);
}

