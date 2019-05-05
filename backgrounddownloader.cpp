#include "backgrounddownloader.h"
#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <utils.h>
#include <QNetworkReply>
#include <QFile>
#include <QEventLoop>

BackgroundDownloader::BackgroundDownloader(QObject *parent) : QObject(parent), workObj(new BackgroundDownloaderThread(this))
{
    connect(&thread, &QThread::started, workObj, &BackgroundDownloaderThread::progress);
    connect(workObj, &BackgroundDownloaderThread::downloadComplete, this, &BackgroundDownloader::downloadComplete);
    qDebug() << "下载器初始化成功";
}

void BackgroundDownloaderThread::progress()
{
    qDebug() << "开启新线程xx：" << QThread::currentThreadId();
    QNetworkRequest request;
    int length = targetDownload->length();
    qDebug() << length;
    for(int i = 0 ; i < length ; ++i){
        request.setUrl(QUrl("http://" + Utils::getAllConfig().value("ip") + "/" + targetDownload->at(i)));
        QNetworkReply * reply = networkManager->get(request);

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
            continue;
        }

        QByteArray data = reply->readAll();

        QFile file;
        file.setFileName(Utils::getBackgroundPath() + "/" + targetDownload->at(i));
        if(file.open(QIODevice::WriteOnly)){
            file.write(data);
            file.close();
            qDebug() << "已下载图片：" << targetDownload->at(i);
        }
    }

    emit downloadComplete();
}

void BackgroundDownloader::startWork(QStringList* names)
{
    if(thread.isRunning()){
        qDebug() << "下载线程正在执行,线程无需执行...";
        return;
    }

    workObj->deleteValue();
    workObj->setValue(names);
    workObj->moveToThread(&thread);
    thread.start();
}


BackgroundDownloader::~BackgroundDownloader()
{
    thread.quit();
    thread.wait();
}

BackgroundDownloaderThread::BackgroundDownloaderThread(QObject *parent): QObject(parent), networkManager(new QNetworkAccessManager(this))
{
    targetDownload = nullptr;
}

void BackgroundDownloaderThread::setValue(QStringList *list)
{
    this->targetDownload = list;
}

void BackgroundDownloaderThread::deleteValue()
{
    if(targetDownload == nullptr){
        return;
    }
    delete targetDownload;
}

BackgroundDownloaderThread:: ~BackgroundDownloaderThread(){
    deleteValue();
}
