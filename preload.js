const { contextBridge, ipcRenderer } = require('electron');

// Expor APIs protegidas para o frontend
contextBridge.exposeInMainWorld('electronAPI', {
  // Controle de janela
  minimizeWindow: () => ipcRenderer.invoke('minimize-window'),
  maximizeWindow: () => ipcRenderer.invoke('maximize-window'),
  closeWindow: () => ipcRenderer.invoke('close-window'),
  
  // Informações da aplicação
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  
  // Eventos do menu
  onMenuNewProject: (callback) => ipcRenderer.on('menu-new-project', callback),
  onMenuAbout: (callback) => ipcRenderer.on('menu-about', callback)
});

// Expor API para comunicação com o backend
contextBridge.exposeInMainWorld('api', {
  // Health check
  healthCheck: () => fetch('http://localhost:3000/api/health').then(r => r.json()),
  
  // Dashboard
  getDashboardData: () => fetch('http://localhost:3000/api/dashboard').then(r => r.json()),
  
  // Projetos
  getProjects: () => fetch('http://localhost:3000/api/projects').then(r => r.json())
});
