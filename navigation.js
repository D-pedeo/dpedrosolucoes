// navigation.js - Sistema de navegação unificado
class DPSNavigation {
    constructor() {
        this.currentPage = this.getCurrentPage();
        this.init();
    }
    
    getCurrentPage() {
        const path = window.location.pathname;
        return path.split('/').pop() || 'index.html';
    }
    
    init() {
        // Adicionar classe active ao menu atual
        this.highlightCurrentPage();
        
        // Configurar eventos de navegação
        this.setupNavigationEvents();
    }
    
    highlightCurrentPage() {
        const menuItems = document.querySelectorAll('.menu-item');
        menuItems.forEach(item => {
            const href = item.getAttribute('href');
            if (href === this.currentPage) {
                item.classList.add('active');
            }
        });
    }
    
    setupNavigationEvents() {
        // Interceptar cliques em links
        document.addEventListener('click', (e) => {
            if (e.target.tagName === 'A' || e.target.closest('a')) {
                const link = e.target.tagName === 'A' ? e.target : e.target.closest('a');
                const href = link.getAttribute('href');
                
                if (href && !href.startsWith('http') && !href.startsWith('#')) {
                    e.preventDefault();
                    this.navigateTo(href);
                }
            }
        });
    }
    
    navigateTo(page) {
        // Salvar estado atual antes de navegar
        this.savePageState();
        
        // Mostrar loader
        this.showLoader();
        
        // Navegar após breve delay para animação
        setTimeout(() => {
            window.location.href = page;
        }, 300);
    }
    
    savePageState() {
        // Salvar scroll position e outros estados
        const state = {
            scrollY: window.scrollY,
            timestamp: Date.now()
        };
        
        DPSystem.pageData.set('pageState', state, this.currentPage);
    }
    
    showLoader() {
        // Criar ou mostrar loader existente
        let loader = document.getElementById('page-loader');
        if (!loader) {
            loader = document.createElement('div');
            loader.id = 'page-loader';
            loader.innerHTML = `
                <div style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(255,255,255,0.9);z-index:9999;display:flex;align-items:center;justify-content:center;">
                    <div style="text-align:center;">
                        <div class="spinner" style="width:40px;height:40px;border:4px solid #f3f3f3;border-top:4px solid #3498db;border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 10px;"></div>
                        <p>Carregando...</p>
                    </div>
                </div>
            `;
            document.body.appendChild(loader);
        }
        loader.style.display = 'flex';
    }
}

// Inicializar navegação
document.addEventListener('DOMContentLoaded', () => {
    window.dpsNavigation = new DPSNavigation();
});