Świetnie — skoro chcesz dokończyć to jako **pełne rozwiązanie** (do demo i produkcji), poniżej masz:

---

## ✅ **PLAN DZIAŁANIA — KROK PO KROKU**

---

### 🔧 **1. STRUKTURA PROJEKTU**

```
automatyzer/
├── app/                        # Aplikacja desktopowa (Electron)
│   ├── main.js                 # Bootstrap Electron
│   ├── llm-router.js          # API proxy do lokalnych LLM-ów (Ollama / Bielik)
│   ├── n8n_setup.sh           # Autostart n8n z parametrami
│   ├── ui/
│   │   └── index.html         # Prosty frontend do LLM
│   ├── workflows/
│   │   └── email_to_response.json  # Przykładowy workflow n8n
│   └── .env                   # Dane logowania (IMAP/SMTP, modele)
├── install.sh                 # Skrypt do lokalnej instalacji zależności
├── package.json               # Node/Electron config
└── README.md                  # Instrukcja uruchomienia
```

---

### 🧩 **2. CO JESZCZE TRZEBA DODAĆ**

---

#### 🟡 A. `install.sh` – instalacja wszystkiego lokalnie

```bash
#!/bin/bash

echo "[*] Instaluję zależności Node i n8n..."
npm install
npm install -g n8n

echo "[*] Tworzę katalogi i ustawienia..."
mkdir -p app/workflows
cp sample.env app/.env

echo "[*] Gotowe. Uruchom: npm start"
```

---

#### 🟡 B. `package.json` – konfiguracja Node/Electron

```json
{
  "name": "automatyzer",
  "version": "1.0.0",
  "main": "app/main.js",
  "scripts": {
    "start": "electron .",
    "llm": "node app/llm-router.js"
  },
  "dependencies": {
    "axios": "^1.6.0",
    "body-parser": "^1.20.2",
    "electron": "^29.0.0",
    "express": "^4.18.2"
  }
}
```

---

#### 🟡 C. `sample.env` – dane środowiskowe (kopiowane jako `.env`)

```
IMAP_HOST=imap.gmail.com
IMAP_PORT=993
IMAP_USER=twoj_email@gmail.com
IMAP_PASS=twoje_haslo

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=twoj_email@gmail.com
SMTP_PASS=twoje_haslo

LLM_DEFAULT_MODEL=ollama
```

---

#### 🟡 D. `email_to_response.json` – przykładowy workflow n8n

```json
{
  "nodes": [
    {
      "parameters": {
        "port": 993,
        "secure": true,
        "host": "imap.gmail.com",
        "user": "{{ $env.IMAP_USER }}",
        "password": "{{ $env.IMAP_PASS }}",
        "mailbox": "INBOX",
        "action": "search"
      },
      "name": "Read Email",
      "type": "n8n-nodes-base.imapEmail",
      "typeVersion": 1,
      "position": [200, 300]
    },
    {
      "parameters": {
        "url": "http://localhost:7000/llm",
        "method": "POST",
        "sendBody": true,
        "jsonParameters": true,
        "bodyParametersJson": "{\"prompt\":\"{{$json[\"text\"]}}\",\"model\":\"ollama\"}"
      },
      "name": "Call LLM",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [400, 300]
    },
    {
      "parameters": {
        "fromEmail": "{{ $env.SMTP_USER }}",
        "toEmail": "{{$json[\"from\"]}}",
        "subject": "Re: {{$json[\"subject\"]}}",
        "text": "{{$json[\"response\"]}}",
        "host": "{{ $env.SMTP_HOST }}",
        "port": 587,
        "secure": false,
        "user": "{{ $env.SMTP_USER }}",
        "password": "{{ $env.SMTP_PASS }}"
      },
      "name": "Send Email",
      "type": "n8n-nodes-base.emailSend",
      "typeVersion": 1,
      "position": [600, 300]
    }
  ],
  "connections": {
    "Read Email": {
      "main": [["Call LLM"]]
    },
    "Call LLM": {
      "main": [["Send Email"]]
    }
  }
}
```

---

## ✅ **3. CO ZOSTAJE DO ROZBUDOWY (opcjonalnie)**

---

### 🚀 **Dalsze opcje rozwoju:**

| Funkcja              | Stack / Notatka                  |
| -------------------- | -------------------------------- |
| Webscraping z URL    | Node + puppeteer / axios         |
| Parsowanie Excela    | `xlsx` npm package               |
| Zapis do PDF         | `pdfkit` albo `puppeteer` + HTML |
| UI z Swagger/OpenAPI | Swagger UI / Redoc               |
| Przejście na VPS     | PM2 + nginx reverse proxy na VPS |
| Autoryzacja          | JWT / local login + hasło        |

---

## 📦 **4. GOTOWY PRODUKT DO DEMO**

- ✅ działa lokalnie (n8n, LLM, IMAP/SMTP)
- ✅ wybór modelu AI przez interfejs
- ✅ proste odp. na maile
- ✅ automatyczne odpowiedzi do klienta
- ✅ frontend do pokazania

---

- 📦 plik `.exe`/`.AppImage`?
- 🧠 dodac workflow z webscrapingiem lub Excela

// Projekt: Lokalna aplikacja desktopowa do przetwarzania danych z emaili z odpowiedziami generowanymi przez lokalne LLM

// Stack: Node.js + Electron + n8n (lokalnie) + OpenAPI UI + Ollama/Bielik jako silniki LLM

// Główne funkcje:
// - przetwarzanie maili (IMAP)
// - ekstrakcja danych (np. faktury, zapytania)
// - przetwarzanie przez LLM (lokalne, wybieralne przez UI)
// - generowanie odpowiedzi + wysyłka maila (SMTP)

// STRUKTURA:
// /app
// - main.js (Electron bootstrap)
// - n8n_setup.sh (skrypt auto-instalacyjny n8n)
// - llm-router.js (obsługa lokalnych LLM)
// - api.yaml (OpenAPI spec do UI)
// - ui/ (prosty frontend)
// - workflows/

// ======== plik: main.js =========
const { app, BrowserWindow } = require('electron');
const { exec } = require('child_process');
const path = require('path');

function createWindow() {
const win = new BrowserWindow({
width: 1200,
height: 800,
webPreferences: {
nodeIntegration: true,
contextIsolation: false
}
});

win.loadFile('ui/index.html');

// Start n8n
exec('bash ./n8n_setup.sh', (err, stdout, stderr) => {
if (err) console.error(`n8n error: ${stderr}`);
else console.log(`n8n started: ${stdout}`);
});
}

app.whenReady().then(() => {
createWindow();
});

// ========== plik: n8n_setup.sh =========
#!/bin/bash

# Uruchamia lokalny n8n (wymaga Node.js i n8n zainstalowanego globalnie)

export DB_TYPE=sqlite
export GENERIC_TIMEZONE=Europe/Warsaw
n8n start --tunnel

// ========== plik: llm-router.js =========
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const app = express();

app.use(bodyParser.json());

app.post('/llm', async (req, res) => {
const { prompt, model } = req.body;
let endpoint = '';
if (model === 'ollama') endpoint = 'http://localhost:11434/api/generate';
else if (model === 'bielik') endpoint = 'http://localhost:3000/api'; // założmy, że proxy

try {
const response = await axios.post(endpoint, {
prompt,
model: model === 'ollama' ? 'llama3' : undefined
});
res.json(response.data);
} catch (e) {
res.status(500).json({ error: e.message });
}
});

app.listen(7000, () => console.log('LLM router listening on port 7000'));

// ========== plik: ui/index.html =========

<!DOCTYPE html>
<html>
  <head>
    <title>Mail LLM App</title>
  </head>
  <body>
    <h2>Mail Processor</h2>
    <form id="llmForm">
      <textarea name="prompt" placeholder="Wprowadź zapytanie z maila..."></textarea><br />
      <select name="model">
        <option value="ollama">Ollama</option>
        <option value="bielik">Bielik</option>
      </select>
      <button type="submit">Wyślij do LLM</button>
    </form>
    <pre id="result"></pre>

    <script>
      document.getElementById('llmForm').onsubmit = async (e) => {
        e.preventDefault();
        const form = e.target;
        const res = await fetch('http://localhost:7000/llm', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            prompt: form.prompt.value,
            model: form.model.value
          })
        });
        const data = await res.json();
        document.getElementById('result').innerText = JSON.stringify(data, null, 2);
      };
    </script>

  </body>
</html>

// ========== plik: workflows/email_to_response.json =========
// przykładowy workflow do n8n:
// - IMAP: pobierz maila
// - Node: wyślij prompt do localhost:7000/llm
// - SMTP: wyślij odpowiedź do nadawcy

// Do skonfigurowania w n8n GUI po instalacji

// TODO:
// - Dodanie webscrapera do workflowa
// - Parsowanie Excela (Node + XLSX)
// - Export do PDF
// - Rozszerzenie do wersji VPS

// Gotowe do demo lokalnie, z opcją skalowania

Świetnie! Masz już backend (`llm-router.js`) i prosty HTML UI — teraz rozbudujemy frontend jako **pełną aplikację w React** z UI do wysyłania promptów do lokalnych modeli (Ollama i Bielik) oraz podglądem odpowiedzi.

---

## ✅ CO DODAJEMY:

**Nowy folder: `ui-react/`**, zawierający aplikację React z:

- Formą wyboru modelu (dropdown: Ollama / Bielik),
- Polem promptu,
- Przycisk "Wyślij do LLM",
- Sekcją podglądu odpowiedzi (ładne formatowanie),
- Kompatybilnością z Electronem (brak serwera dev),
- Możliwością łatwego rozbudowania (np. dodanie historii zapytań).

---

## 📁 STRUKTURA `ui-react/`

```
ui-react/
├── public/
│   └── index.html
├── src/
│   ├── App.jsx
│   ├── api.js
│   └── index.js
├── package.json
└── vite.config.js
```

---

## 1. 📦 `package.json`

```json
{
  "name": "ui-react",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "vite": "^5.2.0",
    "@vitejs/plugin-react": "^4.0.0"
  }
}
```

---

## 2. ⚙️ `vite.config.js`

```js
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  root: "./",
  plugins: [react()],
  build: {
    outDir: "../app/ui-react-dist",
    emptyOutDir: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

---

## 3. 🌐 `public/index.html`

```html
<!DOCTYPE html>
<html lang="pl">
  <head>
    <meta charset="UTF-8" />
    <title>LLM Lokalny</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/index.js"></script>
  </body>
</html>
```

---

## 4. ⚛️ `src/index.js`

```js
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
```

---

## 5. 🧠 `src/api.js`

```js
export async function sendPrompt(prompt, model) {
  const res = await fetch("http://localhost:7000/llm", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ prompt, model }),
  });
  return res.json();
}
```

---

## 6. 💡 `src/App.jsx`

```jsx
import React, { useState } from "react";
import { sendPrompt } from "./api";

const App = () => {
  const [prompt, setPrompt] = useState("");
  const [model, setModel] = useState("ollama");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    const response = await sendPrompt(prompt, model);
    setResult(response);
    setLoading(false);
  };

  return (
    <div style={{ padding: 20, fontFamily: "sans-serif" }}>
      <h2>🧠 Lokalny LLM Interfejs</h2>
      <form onSubmit={handleSubmit}>
        <textarea
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          rows={6}
          placeholder="Wpisz prompt z maila..."
          style={{ width: "100%", marginBottom: 10 }}
        />
        <br />
        <select value={model} onChange={(e) => setModel(e.target.value)}>
          <option value="ollama">Ollama</option>
          <option value="bielik">Bielik</option>
        </select>
        <button type="submit" style={{ marginLeft: 10 }}>
          Wyślij
        </button>
      </form>
      <hr />
      {loading && <p>⏳ Przetwarzanie...</p>}
      {result && (
        <div>
          <h3>📥 Odpowiedź:</h3>
          <pre style={{ background: "#eee", padding: 10 }}>
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  );
};

export default App;
```

---

## 🚀 DALSZE KROKI

1. Przejdź do `ui-react/` i zainstaluj paczki:

   ```bash
   cd ui-react
   npm install
   npm run build
   ```

2. Skopiuj zawartość `app/ui-react-dist/` jako nowy frontend aplikacji Electron:

   W `main.js`:

   ```js
   win.loadFile("ui-react-dist/index.html");
   ```

3. Od teraz masz **interaktywny, rozszerzalny frontend React + LLM router lokalny**.

---

Chcesz dorzucić:

- 🧠 historię rozmów / logi?
- 💼 integrację z mailem przez n8n z poziomu GUI?
- 🔌 plugin do przetwarzania Excela lub PDF?

Daj znać — mogę zbudować gotowe bloki.
