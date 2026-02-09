#include "stamps.h"

#include <QSqlQuery>
#include <QImage>
#include <QDir>
#include <QFileInfo>

Stamps::Stamps(QSqlDatabase db, QObject *parent)
    : QObject(parent), m_db(db)
{
}



QString Stamps::processAndSaveImage(const QString &sourcePath, int stampId)
{
    if (sourcePath.isEmpty())
        return "";

    QImage image(sourcePath);

    if (image.isNull())
        return "";

    QFileInfo dbInfo(m_db.databaseName());
    QDir dir(dbInfo.absolutePath());

    if (!dir.exists("stamps_images"))
        dir.mkdir("stamps_images");

    int side = qMin(image.width(), image.height());

    QRect crop(
        (image.width() - side) / 2,
        (image.height() - side) / 2,
        side,
        side
        );

    QImage cropped = image.copy(crop)
                         .scaled(155, 155,
                                 Qt::IgnoreAspectRatio,
                                 Qt::SmoothTransformation);

    QString filePath =
        dir.filePath("stamps_images/" +
                     QString::number(stampId) + ".jpeg");

    cropped.save(filePath, "JPEG", 90);

    return filePath;
}


bool Stamps::addStamp(const QString &title,
                      const QString &country,
                      int year,
                      const QString &category,
                      int count,
                      int collectionId,
                      const QString &image,
                      const QString &rare)
{
    QSqlQuery query(m_db);

    query.prepare(
        "INSERT INTO stamps "
        "(title,country,year,category,count,collection_id,image,rare) "
        "VALUES(?,?,?,?,?,?,'',?)"
        );

    query.addBindValue(title);
    query.addBindValue(country);
    query.addBindValue(year);
    query.addBindValue(category);
    query.addBindValue(count);
    query.addBindValue(collectionId);
    query.addBindValue(rare);

    if (!query.exec())
        return false;

    int id = query.lastInsertId().toInt();

    QString img = processAndSaveImage(image, id);

    if (!img.isEmpty()) {
        QSqlQuery q(m_db);
        q.prepare("UPDATE stamps SET image=? WHERE id=?");
        q.addBindValue(img);
        q.addBindValue(id);
        q.exec();
    }

    return true;
}

bool Stamps::updateStamp(int id,
                         const QString &title,
                         const QString &country,
                         int year,
                         const QString &category,
                         int count,
                         int collectionId,
                         const QString &image,
                         const QString &rare)
{
    QSqlQuery query(m_db);

    query.prepare(
        "UPDATE stamps SET "
        "title=?,country=?,year=?,category=?,"
        "count=?,collection_id=?,rare=? "
        "WHERE id=?"
        );

    query.addBindValue(title);
    query.addBindValue(country);
    query.addBindValue(year);
    query.addBindValue(category);
    query.addBindValue(count);
    query.addBindValue(collectionId);
    query.addBindValue(rare);
    query.addBindValue(id);

    if (!query.exec())
        return false;

    if (!image.isEmpty()) {
        QString img = processAndSaveImage(image, id);

        if (!img.isEmpty()) {
            QSqlQuery q(m_db);
            q.prepare("UPDATE stamps SET image=? WHERE id=?");
            q.addBindValue(img);
            q.addBindValue(id);
            q.exec();
        }
    }

    return true;
}

bool Stamps::deleteStamp(int id)
{
    QSqlQuery query(m_db);

    query.prepare("DELETE FROM stamps WHERE id=?");
    query.addBindValue(id);

    return query.exec();
}

QVariantList Stamps::getAllStamps()
{
    QVariantList list;

    QSqlQuery query(
        "SELECT stamps.*, collections.name AS collectionName "
        "FROM stamps "
        "LEFT JOIN collections "
        "ON stamps.collection_id=collections.id "
        "ORDER BY stamps.id DESC",
        m_db
        );

    while (query.next()) {

        QVariantMap s;

        s["stampId"] = query.value("id");
        s["title"] = query.value("title");
        s["country"] = query.value("country");
        s["year"] = query.value("year");
        s["category"] = query.value("category");
        s["count"] = query.value("count");
        s["collection"] = query.value("collectionName");
        s["collectionId"] = query.value("collection_id");
        s["image"] = query.value("image");
        s["rare"] = query.value("rare");

        list.append(s);
    }

    return list;
}

QVariantList Stamps::searchStamps(const QString &searchTerm)
{
    QVariantList list;

    QSqlQuery query(m_db);

    query.prepare(
        "SELECT stamps.*, collections.name AS collectionName "
        "FROM stamps "
        "LEFT JOIN collections "
        "ON stamps.collection_id=collections.id "
        "WHERE title LIKE ? OR country LIKE ? OR category LIKE ? "
        "ORDER BY stamps.id DESC"
        );

    QString p = "%" + searchTerm + "%";

    query.addBindValue(p);
    query.addBindValue(p);
    query.addBindValue(p);

    query.exec();

    while (query.next()) {

        QVariantMap s;

        s["stampId"] = query.value("id");
        s["title"] = query.value("title");
        s["country"] = query.value("country");
        s["year"] = query.value("year");
        s["category"] = query.value("category");
        s["count"] = query.value("count");
        s["collection"] = query.value("collectionName");
        s["collectionId"] = query.value("collection_id");
        s["image"] = query.value("image");
        s["rare"] = query.value("rare");

        list.append(s);
    }

    return list;
}

bool Stamps::moveStampsToCollection(int fromId, int toId)
{
    QSqlQuery query(m_db);

    query.prepare(
        "UPDATE stamps SET collection_id=? WHERE collection_id=?"
        );

    query.addBindValue(toId);
    query.addBindValue(fromId);

    return query.exec();
}

bool Stamps::deleteStampsByCollection(int collectionId)
{
    QSqlQuery query(m_db);

    query.prepare("DELETE FROM stamps WHERE collection_id=?");
    query.addBindValue(collectionId);

    return query.exec();
}
