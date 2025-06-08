#include "xmlUnloading.h"
#include <QObject>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>

XmlUnloading::XmlUnloading(QObject *parent) : QObject(parent) {}

QVariantList XmlUnloading::loadCommands(const QString &filePath) {
    QVariantList commands;
    QFile file(filePath);

    if (!file.exists()) return commands; // Если файла нет, вернем пустой список

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Ошибка загрузки файла:" << file.errorString();
        return commands;
    }

    QXmlStreamReader xml(&file);
    QVariantMap currentCommand;

    while (!xml.atEnd() && !xml.hasError()) {
        xml.readNext();

        if (xml.isStartElement() && xml.name() == "Command") {
            currentCommand.clear();
        } else if (xml.isStartElement() && !xml.name().isEmpty()) {
            currentCommand[xml.name().toString()] = xml.readElementText();
        } else if (xml.isEndElement() && xml.name() == "Command") {
            commands.append(currentCommand);
        }
    }

    file.close();
    return commands;
}

void XmlUnloading::saveCommands(const QVariantList &commands, const QString &filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Ошибка сохранения:" << file.errorString();
        return;
    }

    QXmlStreamWriter xml(&file);
    xml.setAutoFormatting(true);
    xml.writeStartDocument();
    xml.writeStartElement("Commands"); // Корневой элемент для списка

    for (const QVariant &cmd : commands) {
        QVariantMap command = cmd.toMap();
        xml.writeStartElement("Command");

        for (auto it = command.begin(); it != command.end(); ++it) {
            xml.writeTextElement(it.key(), it.value().toString());
        }

        xml.writeEndElement(); // Command
    }

    xml.writeEndElement(); // Commands
    xml.writeEndDocument();
    file.close();
}
