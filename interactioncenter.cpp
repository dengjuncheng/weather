#include "interactioncenter.h"
#include <utils.h>
#include <backgroundmanager.h>
#include <QDebug>

InteractionCenter::InteractionCenter(QObject *parent) : QObject(parent)
{
    Utils::init();
    connect(&backgroundManager, &BackgroundManager::downloadComplete, this, &InteractionCenter::backgroundDownloadComplete);
}

QString InteractionCenter::getServerIp()
{
    return Utils::getAllConfig().value("ip", "127.0.0.1");
}

QString InteractionCenter::getAllBackground()
{
    return backgroundManager.getAllBackground();
}

QString InteractionCenter::currentBackground()
{
    return Utils::getAllConfig().value("currentBackground", "default.jpg");
}

void InteractionCenter::setCurrentThumb(QString name)
{
    Utils::setCurrentThumb(name);
}

void InteractionCenter::saveConfig(QString config)
{
    QStringList temp = config.split(",");
    Utils::setCoordinate(temp.at(0).toInt(), temp.at(1).toInt());
}

QString InteractionCenter::getCoordinate()
{
    return Utils::getAllConfig().value("x", 0) + "," + Utils::getAllConfig().value("y", 0);
}

void InteractionCenter::setFont(QString font)
{
    Utils::setGeneralSetting("font", font);
}

QString InteractionCenter::getFont()
{
    return Utils::getAllConfig().value("font", "Wawati SC");
}

void InteractionCenter::setFontColor(QString color)
{
    Utils::setGeneralSetting("fontColor", color);
}

QString InteractionCenter::getFontColor()
{
    return Utils::getAllConfig().value("fontColor", "#FFFFFF");
}

bool InteractionCenter::getAutoLocaltion()
{
    return Utils::getAllConfig().value("autoLocation", "T") == "T" ? true : false;
}

void InteractionCenter::setAutoLocation(bool flag)
{
    Utils::setAutoLocation(flag);
}

void InteractionCenter::saveLocalInfo(int provinceId, int cityId)
{
    Utils::setLocalInfo(provinceId, cityId);
}

QString InteractionCenter::getProvinceId()
{
    return Utils::getAllConfig().value("provinceId", "1");
}

QString InteractionCenter::getCityId()
{
    return Utils::getAllConfig().value("cityId", "1");
}
