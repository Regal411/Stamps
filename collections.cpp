#include "collections.h"

#include <QSqlQuery>

Collections::Collections(QSqlDatabase db, QObject *parent)
    : QObject(parent), m_db(db)
{
}

QVariantList Collections::getAllCollections()
{
    QVariantList list;

    QSqlQuery query("SELECT * FROM collections ORDER BY name", m_db);

    while (query.next()) {
        QVariantMap c;
        c["id"] = query.value("id").toInt();
        c["name"] = query.value("name").toString();
        list.append(c);
    }

    return list;
}

bool Collections::addCollection(const QString &name)
{
    QSqlQuery query(m_db);

    query.prepare("INSERT INTO collections (name) VALUES (?)");
    query.addBindValue(name);

    return query.exec();
}

bool Collections::deleteCollection(int id)
{
    QSqlQuery query(m_db);

    query.prepare("DELETE FROM collections WHERE id=?");
    query.addBindValue(id);

    return query.exec();
}

bool Collections::renameCollection(int id, const QString &newName)
{
    QSqlQuery query(m_db);

    query.prepare("UPDATE collections SET name=? WHERE id=?");
    query.addBindValue(newName);
    query.addBindValue(id);

    return query.exec();
}

int Collections::getStampsCountInCollection(int collectionId)
{
    QSqlQuery query(m_db);

    query.prepare("SELECT COUNT(*) FROM stamps WHERE collection_id=?");
    query.addBindValue(collectionId);

    if (!query.exec() || !query.next())
        return 0;

    return query.value(0).toInt();
}
