#ifndef XMLUNLOADING_H
#define XMLUNLOADING_H

#include <QObject>
#include <QFile>
#include <QXmlStreamWriter>
#include <QXmlStreamReader>
#include <QVariant>       // Добавлено для работы с QVariant
#include <QVariantList>   // Добавлено для работы со списками
#include <QVariantMap>    // Добавлено для работы с map
#include <QDebug>         // Для отладки

class XmlUnloading : public QObject  // Имя класса с большой буквы (стандарт Qt)
{
    Q_OBJECT
public:
    explicit XmlUnloading(QObject *parent = nullptr);

    // Методы для работы с командами
    Q_INVOKABLE QVariantList loadCommands(const QString &filePath);
    Q_INVOKABLE void saveCommands(const QVariantList &commands, const QString &filePath);
};

#endif // XMLUNLOADING_H
