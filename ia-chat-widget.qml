import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    visibility: "Maximized"
    color: "#ff8833"

    // StackView Principal
    StackView {
        id: mainStack

        anchors.fill: parent
        initialItem: chatView
    }

    // Drawer lateral para historial
    Drawer {
        id: historyDrawer

        width: Math.min(parent.width * 0.66, 300)
        height: parent.height
        edge: Qt.LeftEdge

        Rectangle {
            anchors.fill: parent
            color: "#333333"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Historial de Chats"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: ListModel {
                        ListElement {
                            title: "Chat de Ayuda"
                        }

                        ListElement {
                            title: "Conversación #1"
                        }

                        ListElement {
                            title: "Dudas sobre Qt"
                        }

                    }

                    delegate: Item {
                        width: parent.width
                        height: 40

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            color: "#444444"
                            radius: 5

                            Text {
                                text: model.title
                                anchors.centerIn: parent
                                color: "white"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }

                        }

                    }

                }

            }

        }

    }

    // Cargar FontAwesome localmente
    FontLoader {
        id: faFont

        source: "resource/icons/fa-solid-900.ttf"
    }

    // Modelo de datos para el chat
    ListModel {
        id: chatModel

        ListElement {
            text: "Hola, ¿en qué puedo ayudarte?"
            isUser: false
        }

    }

    // --- Componente: Vista de Chat ---
    Component {
        id: chatView

        ColumnLayout {
            spacing: 10
            // Margenes del contendor
            anchors.fill: parent
            anchors.margins: 10

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#33000000"
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    // Botón Izquierdo: Menú
                    Button {
                        display: AbstractButton.TextOnly
                        onClicked: historyDrawer.open()

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.clicked()
                        }

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

                    Item {
                        Layout.fillWidth: true
                    }

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

                    Item {
                        Layout.fillWidth: true
                    }

                    // Botón Derecho: Configuración (Navegación)
                    Button {
                        display: AbstractButton.TextOnly
                        onClicked: mainStack.push(settingsView)

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.clicked()
                        }

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
                        // Navegación: Ir a Configuración

                    }

                }

            }

            // Chat Area
            Rectangle {
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

            // Input Area
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 20 // Subir un poco el input
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

    // --- Componente: Vista de Configuración ---
    Component {
        id: settingsView

        Rectangle {
            color: "#ff8833" // Fondo naranja (mismo que background principal)

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: 300

                Text {
                    text: "Configuración"
                    font.pixelSize: 24
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    placeholderText: "API Token"
                    Layout.fillWidth: true
                    passwordCharacter: "*"
                    echoMode: TextInput.Password

                    background: Rectangle {
                        implicitHeight: 40
                        radius: 5
                        color: "white"
                    }

                }

                Button {
                    text: "Cerrar"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: mainStack.pop()

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.clicked()
                    }

                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        color: parent.pressed ? "#cc0000" : "#ff0000"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // Navegación: Volver

                }

            }

        }

    }

}
