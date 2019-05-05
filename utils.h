#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QMap>

class QSettings;

class Utils
{
public:
    explicit Utils();
    static QString getBackgroundPath();
    static void setCurrentThumb(QString thumb);
    static void setCoordinate(int x, int y);

    static QMap<QString, QString> getAllConfig();
    static void init();
    static void setGeneralSetting(QString key, QString value);
    static void setAutoLocation(bool flag);
    static void setLocalInfo(int provinceId, int cityId);
private:
    static QSettings* getSetting();
    static QMap<QString, QString> configMap;
};

#endif // UTILS_H
