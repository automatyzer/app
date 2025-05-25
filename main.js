const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { exec } = require('child_process');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '.env') });

let mainWindow;
let n8nProcess;

function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
  });

  // Load the index.html file
  mainWindow.loadFile(path.join(__dirname, 'ui', 'index.html'));

  // Start n8n process
  startN8N();

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function startN8N() {
  const n8nScript = path.join(__dirname, 'n8n_setup.sh');
  
  n8nProcess = exec(`bash ${n8nScript}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing n8n: ${error}`);
      return;
    }
    console.log(`n8n: ${stdout}`);
    console.error(`n8n errors: ${stderr}`);
  });

  n8nProcess.on('exit', (code) => {
    console.log(`n8n process exited with code ${code}`);
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    // Clean up n8n process when app is closed
    if (n8nProcess) {
      n8nProcess.kill();
    }
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// IPC handlers for LLM communication
ipcMain.handle('llm-request', async (event, { prompt, model = 'llama2' }) => {
  // This will be implemented in llm-router.js
  const { handleLLMRequest } = require('./llm-router');
  return handleLLMRequest(prompt, model);
});
