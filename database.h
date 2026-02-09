#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    Q_INVOKABLE bool connectToDatabase(const QString &path);
    Q_INVOKABLE void closeDatabase();

    QSqlDatabase db() const;

private:
    QSqlDatabase m_db;
};

#endif // DATABASE_H
