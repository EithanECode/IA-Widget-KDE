.pragma library

function enviarAI(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper) {
    // Dispatch based on model name prefix or specific strings
    if (modelo.startsWith("gemini")) {
        callGemini(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper);
    } else if (modelo.startsWith("claude")) {
        callClaude(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper);
    } else {
        // Default to OpenAI for "gpt" or others
        callOpenAI(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper);
    }
}

function callOpenAI(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper) {
    var xhr = new XMLHttpRequest();
    var url = "https://api.openai.com/v1/chat/completions";

    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Authorization", "Bearer " + apiToken);

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                var respuestaIA = response.choices[0].message.content;

                chatModel.append({ "text": respuestaIA, "isUser": false });
                if (dbHelper) dbHelper.insertMessage(respuestaIA, false);

            } else {
                handleError(xhr, chatModel);
            }
        }
    };

    var data = JSON.stringify({
        "model": modelo,
        "temperature": temperature,
        "messages": [
            { "role": "system", "content": systemPrompt },
            { "role": "user", "content": mensajeUsuario }
        ]
    });

    xhr.send(data);
}

function callGemini(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper) {
    var xhr = new XMLHttpRequest();
    // Gemini url format: ...models/gemini-pro:generateContent?key=API_KEY
    var url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelo + ":generateContent?key=" + apiToken;

    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                // Gemini response structure is different
                try {
                    var respuestaIA = response.candidates[0].content.parts[0].text;
                    chatModel.append({ "text": respuestaIA, "isUser": false });
                    if (dbHelper) dbHelper.insertMessage(respuestaIA, false);
                } catch (e) {
                    chatModel.append({ "text": "Error parsíng Gemini response: " + e.message, "isUser": false });
                }
            } else {
                handleError(xhr, chatModel);
            }
        }
    };

    // Construct Gemini Prompt with System Instruction effectively
    // Gemini 1.5 allows system_instruction but simple prompt engineering works too for basic use
    // For simplicity/compatibility, we append system prompt to history or use system_instruction if supported
    // We will use the standard 'contents' array.

    var data = JSON.stringify({
        "contents": [{
            "parts": [{ "text": systemPrompt + "\n\nUser: " + mensajeUsuario }]
        }],
        "generationConfig": {
            "temperature": temperature
        }
    });

    xhr.send(data);
}

function callClaude(mensajeUsuario, apiToken, modelo, systemPrompt, temperature, chatModel, dbHelper) {
    var xhr = new XMLHttpRequest();
    var url = "https://api.anthropic.com/v1/messages";

    xhr.open("POST", url, true);
    xhr.setRequestHeader("x-api-key", apiToken);
    xhr.setRequestHeader("anthropic-version", "2023-06-01");
    xhr.setRequestHeader("content-type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                try {
                    var respuestaIA = response.content[0].text;
                    chatModel.append({ "text": respuestaIA, "isUser": false });
                    if (dbHelper) dbHelper.insertMessage(respuestaIA, false);
                } catch (e) {
                    chatModel.append({ "text": "Error parsing Claude response: " + e.message, "isUser": false });
                }
            } else {
                handleError(xhr, chatModel);
            }
        }
    };

    var data = JSON.stringify({
        "model": modelo,
        "max_tokens": 1024,
        "temperature": temperature,
        "system": systemPrompt,
        "messages": [
            { "role": "user", "content": mensajeUsuario }
        ]
    });

    xhr.send(data);
}

function handleError(xhr, chatModel) {
    var errorMsg = "Error: " + xhr.status;
    try {
        var errBody = JSON.parse(xhr.responseText);
        if (errBody.error && errBody.error.message) {
            errorMsg += "\n" + errBody.error.message;
        } else if (errBody.error) {
            errorMsg += "\n" + JSON.stringify(errBody.error);
        }
    } catch (e) {
        errorMsg += "\n" + xhr.responseText;
    }
    chatModel.append({
        "text": errorMsg,
        "isUser": false
    });
}
