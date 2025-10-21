const { app, BrowserWindow, Menu, ipcMain, dialog } = require('electron');
const path = require('path');
const isDev = process.argv.includes('--dev');

let mainWindow;

function createWindow() {
  try {
    console.log('🚀 Iniciando D.Pedro Soluções...');
    
    mainWindow = new BrowserWindow({
      width: 1400,
      height: 900,
      minWidth: 1200,
      minHeight: 800,
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        enableRemoteModule: false,
        webSecurity: false  // Permitir acesso ao localhost
      },
      icon: path.join(__dirname, 'build/icon.ico'),
      title: 'D.Pedro Soluções - Sistema Integrado',
      show: false
    });

    // SEMPRE carregar do servidor local para garantir que a API funcione
    const serverUrl = 'http://localhost:3000';
    console.log('🌐 Conectando ao servidor:', serverUrl);
    
    mainWindow.loadURL(serverUrl).catch(err => {
      console.error('❌ Erro ao conectar com servidor:', err);
      showErrorPage('Não foi possível conectar ao servidor local. Certifique-se de que o servidor está rodando na porta 3000.');
    });

    mainWindow.once('ready-to-show', () => {
      mainWindow.show();
      console.log('✅ Aplicativo carregado com sucesso');
      
      if (isDev) {
        mainWindow.webContents.openDevTools();
      }
    });

    mainWindow.on('closed', () => {
      mainWindow = null;
    });

    // Lidar com erros de carregamento
    mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
      console.error('❌ Falha ao carregar:', errorDescription);
      showErrorPage('Erro ao carregar a aplicação: ' + errorDescription);
    });

    // Lidar com certificados SSL (se necessário)
    mainWindow.webContents.session.setCertificateVerifyProc((request, callback) => {
      callback(0); // Aceitar todos os certificados para desenvolvimento
    });

    createApplicationMenu();
    
  } catch (error) {
    console.error('❌ Erro crítico ao criar janela:', error);
    dialog.showErrorBox('Erro de Inicialização', 'Não foi possível iniciar o D.Pedro Soluções: ' + error.message);
  }
}

function showErrorPage(message) {
  const errorHtml = \
<!DOCTYPE html>
<html>
<head>
    <title>Erro - D.Pedro Soluções</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            max-width: 500px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { margin-bottom: 20px; }
        button { 
            background: white; 
            color: #667eea; 
            border: none; 
            padding: 10px 20px; 
            border-radius: 5px; 
            cursor: pointer;
            margin: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚨 Erro no Sistema</h1>
        <p>\</p>
        <p>Por favor, verifique se o servidor está rodando.</p>
        <button onclick="window.location.reload()">🔄 Tentar Novamente</button>
        <button onclick="window.close()">❌ Fechar</button>
    </div>
</body>
</html>
  \;
  
  mainWindow.loadURL(\data:text/html;charset=utf-8,\\);
}

function createApplicationMenu() {
  const template = [
    {
      label: 'Arquivo',
      submenu: [
        {
          label: 'Recarregar',
          accelerator: 'Ctrl+R',
          click: () => {
            if (mainWindow) {
              mainWindow.reload();
            }
          }
        },
        { type: 'separator' },
        {
          label: 'Sair',
          accelerator: 'Ctrl+Q',
          click: () => {
            app.quit();
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// Eventos da aplicação
app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
