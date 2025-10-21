
const { app, BrowserWindow } = require('electron');
const path = require('path');

// Iniciar servidor Express.js
const expressApp = require('./server');
const EXPRESS_PORT = process.env.PORT || 3000;
expressApp.listen(EXPRESS_PORT, () => {
  console.log(`Servidor Express rodando na porta ${EXPRESS_PORT}`);
});

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
    icon: path.join(__dirname, 'DPS.ico'),
  });

  // Carregar a aplicação via servidor Express
  win.loadURL(`http://localhost:${EXPRESS_PORT}/index.html`);
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
