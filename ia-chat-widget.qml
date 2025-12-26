import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    visibility: "Maximized"
    color: "#ff8833"

    // Cargar FontAwesome desde CDN (Versión 6 Free Solid)
    FontLoader {
        id: faFont

        source: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/webfonts/fa-solid-900.ttf"
    }

    // Modelo de datos para el chat
    ListModel {
        id: chatModel

        ListElement {
            text: "Hola, ¿en qué puedo ayudarte?"
            isUser: false
        }

    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#33000000" // Gris oscuro/Negro con transparencia
            radius: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                // Botón Izquierdo: Menú (FontAwesome)
                Button {
                    display: AbstractButton.TextOnly
                    onClicked: console.log("Abrir Menú")

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.clicked()
                    }

                    // Flat style
                    background: Item {
                    }

                    contentItem: Text {
                        text: "\uf0c9" // fa-bars
                        font.family: faFont.name
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                // Espaciador flexible
                Item {
                    Layout.fillWidth: true
                }

                // Centro: Título y Estado
                ColumnLayout {
                    spacing: 0

                    Text {
                        text: "Asistente Virtual"
                        Layout.alignment: Qt.AlignHCenter
                        font.bold: true
                        font.pixelSize: 14
                        color: "white"
                    }

                    Text {
                        text: "En línea - Modelo GPT-4"
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 8
                        color: "#cccccc"
                    }

                }

                // Espaciador flexible
                Item {
                    Layout.fillWidth: true
                }

                // Botón Derecho: Configuración (FontAwesome)
                Button {
                    display: AbstractButton.TextOnly
                    onClicked: console.log("Abrir Configuración")

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.clicked()
                    }

                    // Flat style
                    background: Item {
                    }

                    contentItem: Text {
                        text: "\uf013" // fa-cog
                        font.family: faFont.name
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

        }

        Rectangle {
            id: chatArea

            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#EF5350"
            clip: true
            radius: 10

            ListView {
                id: chatList

                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                model: chatModel
                onCountChanged: Qt.callLater(function() {
                    positionViewAtEnd();
                })

                delegate: Item {
                    readonly property bool isUser: model.isUser
                    readonly property string msgText: model.text

                    width: ListView.view.width
                    height: bubble.height

                    Rectangle {
                        id: bubble

                        width: Math.min(messageText.implicitWidth + 24, parent.width * 0.8)
                        height: messageText.implicitHeight + 20
                        radius: 12
                        color: isUser ? "#0084ff" : "#333333"
                        anchors.right: isUser ? parent.right : undefined
                        anchors.left: isUser ? undefined : parent.left

                        Text {
                            id: messageText

                            text: msgText
                            anchors.centerIn: parent
                            width: parent.width - 24
                            wrapMode: Text.WordWrap
                            color: "white"
                        }

                    }

                }

            }

        }

        // Barra de entrada
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: chatInput

                Layout.fillWidth: true
                placeholderText: "Escribe un mensaje aquí..."
                selectByMouse: true
                focus: true
                onAccepted: sendButton.clicked()

                background: Rectangle {
                    implicitHeight: 40
                    radius: 10
                    color: "#f0f0f0"
                    border.color: chatInput.activeFocus ? "#ff8833" : "#cccccc"
                }

            }

            Button {
                id: sendButton

                display: AbstractButton.TextOnly
                onClicked: {
                    if (chatInput.text.trim() !== "") {
                        chatModel.append({
                            "text": chatInput.text,
                            "isUser": true
                        });
                        chatInput.text = "";
                    }
                }

                background: Rectangle {
                    implicitWidth: 40
                    implicitHeight: 40
                    color: sendButton.pressed ? "#cc6622" : "#ff8833"
                    radius: 20
                    border.color: "white"
                    border.width: 1
                }

                contentItem: Text {
                    text: "\uf1d8" // fa-paper-plane
                    font.family: faFont.name
                    font.pixelSize: 18
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

        }

    }

}
