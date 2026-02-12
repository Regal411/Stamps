#ifndef STAMPS_H
#define STAMPS_H

#include <QObject>
#include <QVariantList>
#include <QSqlDatabase>

class Stamps : public QObject
{
    Q_OBJECT

public:
    explicit Stamps(QSqlDatabase db, QObject *parent = nullptr);

    Q_INVOKABLE bool addStamp(const QString &title,
                              const QString &country,
                              int year,
                              const QString &category,
                              int count,
                              int collectionId,
                              const QString &image,
                              const QString &rare);

    Q_INVOKABLE bool updateStamp(int id,
                                 const QString &title,
                                 const QString &country,
                                 int year,
                                 const QString &category,
                                 int count,
                                 int collectionId,
                                 const QString &image,
                                 const QString &rare);

    Q_INVOKABLE bool deleteStamp(int id);

    Q_INVOKABLE QVariantList getAllStamps();
    Q_INVOKABLE QVariantList searchStamps(const QString &searchTerm);

    Q_INVOKABLE bool moveStampsToCollection(int fromId, int toId);
    Q_INVOKABLE bool deleteStampsByCollection(int collectionId);

signals:
    void stampImageUpdated(int stampId);

private:
    QString processAndSaveImage(const QString &sourcePath, int stampId);

    QSqlDatabase m_db;
};

#endif // STAMPS_H
