import "Database.js" as DB
import Qt.labs.settings 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    visible: true
    visibility: "Maximized"
    color: "#ff8833"
    opacity: appSettings.transparency // Nuevo Binding de Transparencia
    Component.onCompleted: {
        DB.init();
        DB.getMessages(chatModel);
    }

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
                    // Mocks eliminados

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: ListModel {
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

    // Configuración Persistente
    Settings {
        id: appSettings

        property string apiKey: ""
        property int modelIndex: 0
        property int langIndex: 0
        property real fontSize: 14
        // Nuevos Ajustes
        property real temperature: 0.7
        property string systemPrompt: "Eres un asistente útil y conciso."
        property bool persistChat: true
        property real transparency: 1
    }

    // Modelo de datos para el chat
    ListModel {
        // Mocks eliminados

        id: chatModel
    }

    // --- Componente: Vista de Chat ---
    Component {
        id: chatView

        Item {
            // Container principal que StackView redimensionará automáticamente.

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
                                // Guardar en la base de datos
                                DB.insertMessage(chatInput.text, true);
                                // Agregar visualmente al modelo
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

    }

    // --- Componente: Vista de Configuración ---
    Component {
        id: settingsView

        Rectangle {
            color: "#ff8833" // Fondo naranja

            ColumnLayout {
                id: settingsLayout

                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Cabecera con Botón Atrás
                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        display: AbstractButton.TextOnly
                        onClicked: mainStack.pop()

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.clicked()
                        }

                        background: Item {
                        }

                        contentItem: Text {
                            text: "\uf060" // fa-arrow-left
                            font.family: faFont.name
                            font.pixelSize: 22
                            color: "white"
                        }

                    }

                    Text {
                        text: "CONFIGURACIÓN"
                        font.bold: true
                        font.pixelSize: 20
                        color: "white"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Elemento invisible para equilibrar el layout (ancho del botón aprox)
                    Item {
                        width: 30
                    }

                }

                // --- SECCIÓN IA ---
                Label {
                    text: "API Key:"
                    color: "white"
                    font.bold: true
                }

                TextField {
                    id: apiKeyField

                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "sk-..."
                    text: appSettings.apiKey
                    // Guardar al escribir
                    onTextEdited: appSettings.apiKey = text

                    background: Rectangle {
                        implicitHeight: 40
                        radius: 5
                        color: "white"
                    }

                }

                Label {
                    text: "Modelo:"
                    color: "white"
                    font.bold: true
                }

                ComboBox {
                    id: modelCombo

                    Layout.fillWidth: true
                    model: ["GPT-4o", "GPT-4o-mini", "Claude 3.5 Sonnet"]
                    currentIndex: appSettings.modelIndex
                    onActivated: appSettings.modelIndex = currentIndex
                }

                Label {
                    text: "Temperatura: " + temperatureSlider.value.toFixed(1)
                    color: "white"
                    font.bold: true
                }

                Slider {
                    id: temperatureSlider

                    from: 0
                    to: 1
                    value: appSettings.temperature
                    Layout.fillWidth: true
                    onMoved: appSettings.temperature = value
                }

                Label {
                    text: "System Prompt:"
                    color: "white"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80

                    TextArea {
                        text: appSettings.systemPrompt
                        placeholderText: "Instrucciones para la IA..."
                        wrapMode: Text.WordWrap
                        onEditingFinished: appSettings.systemPrompt = text

                        background: Rectangle {
                            color: "white"
                            radius: 5
                        }

                    }

                }

                // --- SECCIÓN INTERFAZ ---
                Rectangle {
                    height: 1 // Separador
                    Layout.fillWidth: true
                    color: "#55ffffff"
                }

                Label {
                    text: "Idioma de la interfaz:"
                    color: "white"
                    font.bold: true
                }

                ComboBox {
                    id: languageCombo

                    Layout.fillWidth: true
                    model: ["Español", "English", "Português", "Français"]
                    currentIndex: appSettings.langIndex
                    onActivated: appSettings.langIndex = currentIndex
                }

                Label {
                    text: "Tamaño de letra: " + Math.round(fontSizeSlider.value)
                    color: "white"
                    font.bold: true
                }

                Slider {
                    id: fontSizeSlider

                    from: 10
                    to: 20
                    Layout.fillWidth: true
                    value: appSettings.fontSize
                    onMoved: appSettings.fontSize = value
                }

                Label {
                    text: "Transparencia: " + Math.round(transparencySlider.value * 100) + "%"
                    color: "white"
                    font.bold: true
                }

                Slider {
                    id: transparencySlider

                    from: 0.2
                    to: 1
                    value: appSettings.transparency
                    Layout.fillWidth: true
                    onMoved: appSettings.transparency = value
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: "Persistencia del chat"
                        color: "white"
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Switch {
                        checked: appSettings.persistChat
                        onToggled: appSettings.persistChat = checked
                    }

                }

                Button {
                    text: "Limpiar Historial"
                    Layout.fillWidth: true
                    onClicked: {
                        DB.clearMessages();
                        chatModel.clear();
                    }

                    background: Rectangle {
                        implicitHeight: 40
                        color: parent.pressed ? "#880000" : "#aa0000" // Rojo oscuro
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                // Espaciador
                Item {
                    Layout.fillHeight: true
                }

                Button {
                    text: "Guardar y Volver"
                    Layout.fillWidth: true
                    onClicked: mainStack.pop()

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.clicked()
                    }

                    background: Rectangle {
                        implicitHeight: 45
                        color: parent.pressed ? "#cc6622" : "white"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.pressed ? "white" : "#ff8833"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

        }

    }

}
