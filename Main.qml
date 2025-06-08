import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import XmlUnloading 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Test")
    color: "lightblue"

    property bool flag: false

    // Объявляем модель данных в корневом элементе
    ListModel {
        id: commandsModel
    }

    // Компонент первой страницы
    Component {
        id: commands
        Page {
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 50
                color: "lightblue"
            }

            Button {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                width: 120
                height: 40
                text: flag ? "Русский" : "English"
                font.pixelSize: 16
                onClicked: flag = !flag
            }

            // Диалог для отображения активации
            Dialog {
                id: activationDialog
                modal: true
                title: flag ? "Activation" : "Активация"
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    id: dialogLabel
                    text: ""
                }

                Timer {
                    id: autoCloseTimer
                    interval: 500
                    onTriggered: activationDialog.close()
                }
            }

            Column {
                anchors.fill: parent
                anchors.topMargin: 50
                spacing: 20

                Label {
                    text: flag ? "Commands" : "Команды"
                    font.pixelSize: 24
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    width: 120
                    height: 40
                    text: flag ? "Add" : "Добавить"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: swipeView.currentIndex = 1
                }

                ListView {
                    width: parent.width
                    height: parent.height - 150
                    model: commandsModel

                    delegate: RowLayout {
                        width: ListView.view.width
                        spacing: 15

                        // 1. Иконка
                        Image {
                            source: "file:///" + iconSource
                            width: 24
                            height: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        // 2. Название
                        Text {
                            text: commandName
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }

                        // 3. Кнопка активации
                        Button {
                            width: 120
                            height: 50
                            text: flag ? "Activation" : "Активировать"
                            font.pixelSize: 16
                            onClicked: {
                                let randomInt = Math.floor(Math.random() * 100); // от 0 до 99
                                if (randomInt>50)
                                {
                                dialogLabel.text = flag ? "Command activated: " : "Активирована команда: " + commandName;
                                activationDialog.open();
                                autoCloseTimer.start();
                                }
                                else
                                {
                                    dialogLabel.text = flag ? "Command execution error: " : "Ошибка выполнения команды: " + commandName;
                                    activationDialog.open();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Компонент второй страницы
    Component {
        id: addition
        Page {
            Rectangle {
                anchors.fill: parent
                color: "lightgreen"
            }

            // Диалог для отображения ошибки
            Dialog {
                id: errorDialog
                modal: true
                title: flag ? "Error" : "Ошибка"
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    id: errorLabel
                    text: ""
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                XmlUnloading {
                      id: xmlHandler
                  }

                Label {
                    text: flag ? "Adding command" : "Добавление команды"
                    font.pixelSize: 24
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Поле для пути к иконке
                TextField {
                    id: iconSourceField
                    width: parent.width
                    placeholderText: flag ? "Enter the path to the icon" : "Напишите путь до иконки"
                    font.pixelSize: 16
                    selectByMouse: true
                }

                // Поле для названия команды
                TextField {
                    id: commandNameField
                    width: parent.width
                    placeholderText: flag ? "Enter the command name" : "Напишите название команды"
                    font.pixelSize: 16
                    selectByMouse: true
                }

                // Кнопка сохранения
                Button {
                    text: flag ? "Save" : "Сохранить"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120
                    height: 40
                    font.pixelSize: 16

                    onClicked: {
                        // Проверка заполнения полей
                        if (commandNameField.text === "") {
                            errorLabel.text = flag ? "Fill in the command name field!" : "Заполните поле названия команды!";
                            errorDialog.open();
                            return
                        }

                        // Создаем объект с данными новой команды
                            var newCommand = {
                                "Name": commandNameField.text,
                                "IconPath": iconSourceField.text
                            };

                            // Добавляем новую команду в модель (без перезагрузки XML)
                            commandsModel.append({
                                "commandName": commandNameField.text,
                                "iconSource": iconSourceField.text
                            });

                            // Сохраняем ВСЮ модель в XML (включая новую команду)
                            var commandsToSave = [];
                            for (var i = 0; i < commandsModel.count; i++) {
                                commandsToSave.push({
                                    "Name": commandsModel.get(i).commandName,
                                    "IconPath": commandsModel.get(i).iconSource
                                });
                            }
                            xmlHandler.saveCommands(commandsToSave, "C:/Users/Aster/Desktop/test/commands.xml");

                        // Возврат на предыдущую страницу
                        swipeView.currentIndex = 0

                        // Очистка полей
                        commandNameField.text = ""
                        iconSourceField.text = ""
                    }
                }
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: 0

        Loader { sourceComponent: commands }
        Loader { sourceComponent: addition }
    }

    PageIndicator {
        visible: false
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: swipeView.count
        currentIndex: swipeView.currentIndex
    }
}
