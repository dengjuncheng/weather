#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <interactioncenter.h>

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    //把当前程序路径注册到qml中
    engine.rootContext()->setContextProperty("appDir", QGuiApplication::applicationDirPath());

    InteractionCenter interactionCenter;

    QObject::connect(&app, &QGuiApplication::lastWindowClosed, &interactionCenter, &InteractionCenter::readyExit);

    engine.rootContext()->setContextProperty("interactionCenter", &interactionCenter);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
