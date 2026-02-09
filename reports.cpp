#include "reports.h"

#include <QSqlQuery>

Reports::Reports(QSqlDatabase db, QObject *parent)
    : QObject(parent), m_db(db)
{
}

QVariantMap Reports::getReport(int collectionId)
{
    QString where = (collectionId == -1)
    ? ""
    : " WHERE collection_id=" + QString::number(collectionId);

    QSqlQuery q(m_db);

    int total = 0, unique = 0, rare = 0;

    q.exec("SELECT COUNT(*), SUM(count), SUM(rare='Yes') FROM stamps" + where);

    if (q.next()) {
        unique = q.value(0).toInt();
        total  = q.value(1).toInt();
        rare   = q.value(2).toInt();
    }

    QVariantList byCountry, byCategory;
    QVariantList pieCountry, pieCategory;

    q.exec("SELECT country, COUNT(*), SUM(count), SUM(rare='Yes') "
           "FROM stamps" + where + " GROUP BY country");

    while (q.next()) {

        QVariantMap m;

        m["name"] = q.value(0).toString();
        m["unique"] = q.value(1).toInt();
        m["total"] = q.value(2).toInt();
        m["rare"] = q.value(3).toInt();

        byCountry << m;

        pieCountry << QVariantMap{
            {"label", q.value(0).toString()},
            {"value", q.value(2).toInt()}
        };
    }

    q.exec("SELECT category, COUNT(*), SUM(count), SUM(rare='Yes') "
           "FROM stamps" + where + " GROUP BY category");

    while (q.next()) {

        QVariantMap m;

        m["name"] = q.value(0).toString();
        m["unique"] = q.value(1).toInt();
        m["total"] = q.value(2).toInt();
        m["rare"] = q.value(3).toInt();

        byCategory << m;

        pieCategory << QVariantMap{
            {"label", q.value(0).toString()},
            {"value", q.value(2).toInt()}
        };
    }

    QVariantMap report;

    report["total"] = total;
    report["unique"] = unique;
    report["rarePercent"] =
        unique ? (rare * 100.0 / unique) : 0;

    report["byCountry"] = byCountry;
    report["byCategory"] = byCategory;
    report["pieCountry"] = pieCountry;
    report["pieCategory"] = pieCategory;

    return report;
}
