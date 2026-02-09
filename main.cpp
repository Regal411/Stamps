#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

#include "database.h"
#include "stamps.h"
#include "collections.h"
#include "reports.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ---------- App data path ----------
    QString dataPath =
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QDir().mkpath(dataPath);

    QString dbPath = dataPath + "/stamps.db";


    Database database;

    if (!database.connectToDatabase(dbPath)) {
        qCritical() << "Failed to connect to database";
        return -1;
    }


    Stamps stamps(database.db());
    Collections collections(database.db());
    Reports reports(database.db());

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("database", &database);
    engine.rootContext()->setContextProperty("stamps", &stamps);
    engine.rootContext()->setContextProperty("collections", &collections);
    engine.rootContext()->setContextProperty("reports", &reports);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && objUrl == url) {
                qCritical() << "Failed to load QML:" << url;
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
        );

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root objects loaded. QML not found.";
        return -1;
    }

    return app.exec();
}
