#ifndef REPORTS_H
#define REPORTS_H

#include <QObject>
#include <QVariantMap>
#include <QSqlDatabase>

class Reports : public QObject
{
    Q_OBJECT

public:
    explicit Reports(QSqlDatabase db, QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap getReport(int collectionId);

private:
    QSqlDatabase m_db;
};

#endif // REPORTS_H
