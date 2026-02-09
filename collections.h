#ifndef COLLECTIONS_H
#define COLLECTIONS_H

#include <QObject>
#include <QVariantList>
#include <QSqlDatabase>

class Collections : public QObject
{
    Q_OBJECT

public:
    explicit Collections(QSqlDatabase db, QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getAllCollections();
    Q_INVOKABLE bool addCollection(const QString &name);
    Q_INVOKABLE bool deleteCollection(int id);
    Q_INVOKABLE bool renameCollection(int id, const QString &newName);
    Q_INVOKABLE int getStampsCountInCollection(int collectionId);

private:
    QSqlDatabase m_db;
};

#endif // COLLECTIONS_H
