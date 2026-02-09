#include "database.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

Database::Database(QObject *parent)
    : QObject(parent)
{
}

Database::~Database()
{
    closeDatabase();
}

bool Database::connectToDatabase(const QString &path)
{
    if (QSqlDatabase::contains("stamps_connection"))
        m_db = QSqlDatabase::database("stamps_connection");
    else
        m_db = QSqlDatabase::addDatabase("QSQLITE", "stamps_connection");

    m_db.setDatabaseName(path);

    if (!m_db.open()) {
        qDebug() << m_db.lastError().text();
        return false;
    }

    QSqlQuery query(m_db);

    query.exec(
        "CREATE TABLE IF NOT EXISTS collections ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT UNIQUE)"
        );

    query.exec(
        "CREATE TABLE IF NOT EXISTS stamps ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "country TEXT,"
        "year INTEGER,"
        "category TEXT,"
        "count INTEGER,"
        "collection_id INTEGER,"
        "image TEXT,"
        "rare TEXT,"
        "FOREIGN KEY(collection_id) REFERENCES collections(id))"
        );

    return true;
}

void Database::closeDatabase()
{
    if (m_db.isOpen())
        m_db.close();
}

QSqlDatabase Database::db() const
{
    return m_db;
}
