.import QtQuick.LocalStorage 2.0 as Sql

// Variable interna para la conexión
var db;

// Inicializa la Base de Datos y crea la tabla si no existe
function init() {
    db = Sql.LocalStorage.openDatabaseSync("ChatDB", "1.0", "Historial del Chat", 1000000);

    db.transaction(function (tx) {
        // Tabla simple: texto del mensaje y booleano (como string/int) de si es usuario
        tx.executeSql('CREATE TABLE IF NOT EXISTS messages(text TEXT, isUser TEXT)');
    });
}

// Carga los mensajes de la DB al Modelo
function getMessages(model) {
    if (!db) return;

    db.transaction(function (tx) {
        var rs = tx.executeSql('SELECT * FROM messages');

        // Si hay mensajes guardados, limpiar el modelo (para no duplicar el mensaje de bienvenida por defecto si se desea)
        // Ojo: Si quieres conservar el mensaje de bienvenida y solo añadir historia, comenta la línea de abajo.
        if (rs.rows.length > 0) {
            model.clear();
        }

        for (var i = 0; i < rs.rows.length; i++) {
            var item = rs.rows.item(i);
            // Convertir 'true'/'false' string a booleano real
            var isUserBool = (item.isUser === "true");

            model.append({
                "text": item.text,
                "isUser": isUserBool
            });
        }
    });
}

// Inserta un nuevo mensaje
function insertMessage(text, isUser) {
    if (!db) return;

    var isUserStr = isUser ? "true" : "false";

    db.transaction(function (tx) {
        tx.executeSql('INSERT INTO messages VALUES(?, ?)', [text, isUserStr]);
    });
}
