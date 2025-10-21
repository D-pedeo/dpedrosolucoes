document.addEventListener('DOMContentLoaded', function() {
  // Controles de janela
  document.getElementById('minimize-btn').addEventListener('click', () => {
    window.electronAPI.minimizeApp();
  });
  
  document.getElementById('maximize-btn').addEventListener('click', () => {
    window.electronAPI.maximizeApp();
  });
  
  document.getElementById('close-btn').addEventListener('click', () => {
    window.electronAPI.closeApp();
  });
  
  // Carregar versão do app
  window.electronAPI.getAppVersion().then(version => {
    console.log('Versão do aplicativo:', version);
  });
  
  // Modificar lógica para usar API em vez de localStorage
  async function loadData() {
    try {
      const response = await fetch('http://localhost:3000/api/data');
      const data = await response.json();
      
      // Use os dados no seu aplicativo
      window.database = data;
      
      // Inicialize seus gráficos e tabelas aqui
      initCharts();
      loadProjects();
      loadActivities();
      loadClients();
      updateNotificationCount();
      
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      // Fallback para dados locais se necessário
    }
  }
  
  async function saveData() {
    try {
      const response = await fetch('http://localhost:3000/api/data', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(window.database)
      });
      
      const result = await response.json();
      console.log('Dados salvos:', result);
      
    } catch (error) {
      console.error('Erro ao salvar dados:', error);
    }
  }
  
  // Substitua as chamadas de localStorage por estas funções
  loadData();
  
  // Modifique suas funções de save para chamar saveData()
});