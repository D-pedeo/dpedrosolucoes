// dps1.js atualizado para usar Electron/API

document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

async function initializeApp() {
    try {
        // Carregar dados iniciais
        await loadDashboardData();
        await loadProjects();
        await loadClients();
        await loadNotifications();

        // Configurar event listeners
        setupEventListeners();
        
        // Inicializar componentes
        initializeCharts();
        
        console.log('Aplicação D.Pedro Soluções inicializada com sucesso');
    } catch (error) {
        console.error('Erro ao inicializar aplicação:', error);
        showNotification('Erro', 'Falha ao carregar dados da aplicação', 'error');
    }
}

// Funções para carregar dados da API
async function loadDashboardData() {
    try {
        const response = await window.api.getDashboardData();
        if (response.success) {
            updateDashboardWidgets(response.data);
        }
    } catch (error) {
        console.error('Erro ao carregar dados do dashboard:', error);
    }
}

async function loadProjects(filters = {}) {
    try {
        const queryParams = new URLSearchParams(filters).toString();
        const response = await window.api.getProjects(queryParams ? `?${queryParams}` : '');
        
        if (response.success) {
            renderProjectsTable(response.data);
            updateProjectsCount(response.data.length);
        }
    } catch (error) {
        console.error('Erro ao carregar projetos:', error);
    }
}

async function loadClients() {
    try {
        const response = await window.api.getClients();
        if (response.success) {
            populateClientSelect(response.data);
        }
    } catch (error) {
        console.error('Erro ao carregar clientes:', error);
    }
}

async function loadNotifications() {
    try {
        const response = await window.api.getNotifications();
        if (response.success) {
            updateNotificationBadge(response.data.filter(n => !n.is_read).length);
            renderNotificationsDropdown(response.data);
        }
    } catch (error) {
        console.error('Erro ao carregar notificações:', error);
    }
}

// Função para criar novo projeto
async function createNewProject(projectData) {
    try {
        const response = await window.api.createProject(projectData);
        if (response.success) {
            showNotification('Sucesso', 'Projeto criado com sucesso!', 'success');
            await loadProjects(); // Recarregar lista
            return true;
        } else {
            throw new Error(response.message);
        }
    } catch (error) {
        console.error('Erro ao criar projeto:', error);
        showNotification('Erro', 'Falha ao criar projeto: ' + error.message, 'error');
        return false;
    }
}

// Configurar event listeners
function setupEventListeners() {
    // Botão novo projeto
    document.getElementById('newProjectBtn')?.addEventListener('click', showProjectModal);
    document.getElementById('addProjectBtn')?.addEventListener('click', showProjectModal);
    document.getElementById('saveProjectBtn')?.addEventListener('click', saveProject);
    
    // Filtros
    document.getElementById('searchInput')?.addEventListener('input', applyFilters);
    document.getElementById('categoryFilter')?.addEventListener('change', applyFilters);
    document.getElementById('statusFilter')?.addEventListener('change', applyFilters);
    document.getElementById('dateFilter')?.addEventListener('change', applyFilters);
    document.getElementById('clearFiltersBtn')?.addEventListener('click', clearFilters);
    
    // Atualizar atividades
    document.getElementById('refreshActivitiesBtn')?.addEventListener('click', refreshActivities);
    
    // Menu do Electron
    if (window.electronAPI) {
        window.electronAPI.onMenuNewProject(() => {
            showProjectModal();
        });
        
        window.electronAPI.onMenuAbout(() => {
            showAboutDialog();
        });
    }
}

// Função para aplicar filtros
function applyFilters() {
    const filters = {
        search: document.getElementById('searchInput').value,
        category: document.getElementById('categoryFilter').value,
        status: document.getElementById('statusFilter').value,
        date: document.getElementById('dateFilter').value
    };
    
    loadProjects(filters);
}

// Função auxiliar para mostrar notificações
function showNotification(title, message, type = 'info') {
    const toast = document.getElementById('notificationToast');
    const toastIcon = document.getElementById('toastIcon');
    const toastTitle = document.getElementById('toastTitle');
    const toastMessage = document.getElementById('toastMessage');
    
    if (toast && toastIcon && toastTitle && toastMessage) {
        // Configurar cores baseadas no tipo
        const colors = {
            success: 'var(--success-color)',
            error: 'var(--error-color)',
            warning: 'var(--warning-color)',
            info: 'var(--info-color)'
        };
        
        toastIcon.style.backgroundColor = colors[type] || colors.info;
        toastTitle.textContent = title;
        toastMessage.textContent = message;
        
        // Mostrar toast
        toast.classList.add('show');
        
        // Auto-esconder após 5 segundos
        setTimeout(() => {
            toast.classList.remove('show');
        }, 5000);
    }
}

// Adicione esta função para lidar com o fechamento do toast
document.getElementById('toastClose')?.addEventListener('click', function() {
    document.getElementById('notificationToast').classList.remove('show');
});