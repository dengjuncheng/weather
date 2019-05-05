#ifndef INTERACTIONCENTER_H
#define INTERACTIONCENTER_H

#include <QObject>
#include <backgroundmanager.h>

class InteractionCenter : public QObject
{
    Q_OBJECT
public:
    explicit InteractionCenter(QObject *parent = nullptr);

signals:
    void backgroundDownloadComplete();
    void readyExit();
public slots:
    QString getServerIp();
    QString getAllBackground();
    QString currentBackground();
    void setCurrentThumb(QString name);
    void saveConfig(QString config);
    QString getCoordinate();
    void setFont(QString font);
    QString getFont();
    void setFontColor(QString color);
    QString getFontColor();
    bool getAutoLocaltion();
    void setAutoLocation(bool flag);
    void saveLocalInfo(int provinceId, int cityId);
    QString getProvinceId();
    QString getCityId();
private:
    BackgroundManager backgroundManager;
};

#endif // INTERACTIONCENTER_H
