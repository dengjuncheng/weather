#include "utils.h"
#include <QDebug>
#include <QSettings>
#include <QGuiApplication>
#include <QMap>

QMap<QString, QString> Utils::configMap = QMap<QString, QString>();

Utils::Utils()
{
}

QSettings* Utils::getSetting()
{
    static QSettings settings("setting.ini", QSettings::IniFormat);
    return &settings;
}

QString Utils::getBackgroundPath()
{
     return QGuiApplication::applicationDirPath() + "/background";
}

void Utils::setCurrentThumb(QString thumb)
{
    QSettings * setting = getSetting();
    setting->beginGroup("background");
    setting->setValue("currentBackground", thumb);
    setting->endGroup();
}

void Utils::setCoordinate(int x, int y)
{
    QSettings * setting = getSetting();
    setting->beginGroup("GeneralSetting");
    setting->setValue("x", x);
    setting->setValue("y", y);
    setting->endGroup();
}

void Utils::init()
{
    QSettings* setting = getSetting();
    setting->beginGroup("GeneralSetting");
    QString x = setting->value("x", "0").toString();
    QString y = setting->value("y", "0").toString();

    configMap.insert("x", x);
    configMap.insert("y", y);

    QString ip = setting->value("ip", "127.0.0.1").toString();
    configMap.insert("ip", ip);

    QString font = setting->value("font", "Wawati SC").toString();
    configMap.insert("font", font);

    QString fontColor = setting->value("fontColor", "#000000").toString();
    configMap.insert("fontColor", fontColor);

    QString autoLocation = setting->value("autoLocation", "T").toString();
    configMap.insert("autoLocation", autoLocation);

    QString provinceId = setting->value("provinceId", 1).toString();
    QString cityId = setting->value("cityId", 1).toString();
    configMap.insert("provinceId", provinceId);
    configMap.insert("cityId", cityId);

    setting->endGroup();

    setting->beginGroup("background");
    QString background = setting->value("currentBackground", "2.jpg").toString();
    setting->endGroup();
    configMap.insert("currentBackground", background);
    qDebug() << configMap;
}

QMap<QString, QString> Utils::getAllConfig()
{
    return Utils::configMap;
}

void Utils::setGeneralSetting(QString key, QString value)
{
    QSettings * setting = getSetting();
    setting->beginGroup("GeneralSetting");
    setting->setValue(key, value);
    setting->endGroup();
}

void Utils::setAutoLocation(bool flag)
{
    QSettings * setting = getSetting();
    setting->beginGroup("GeneralSetting");
    setting->setValue("autoLocation", flag ? "T" : "F");
    setting->endGroup();
}

void Utils::setLocalInfo(int provinceId, int cityId)
{
    QSettings * setting = getSetting();
    setting->beginGroup("GeneralSetting");
    setting->setValue("provinceId", provinceId);
    setting->setValue("cityId", cityId);
    setting->endGroup();
}
