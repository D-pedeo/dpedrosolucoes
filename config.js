// config.js - Sistema centralizado de gerenciamento
const DPSystem = {
    // Configurações do sistema
    config: {
        appName: 'D.Pedro Soluções',
        version: '2.1.0',
        apiBaseUrl: window.location.origin,
        defaultAvatar: 'https://ui-avatars.com/api/?name=Usuario&background=3498db&color=fff'
    },
    
    // Banco de dados
    database: {
        name: 'DPSystemDB',
        version: 2,
        
        init: function() {
            if (!localStorage.getItem(this.name)) {
                const initialDB = {
                    users: [
                        {
                            id: 1,
                            name: "Daniel Pedro",
                            email: "daniel@dpedrosolucoes.com",
                            password: "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", // admin (SHA-256)
                            avatar: "https://i.postimg.cc/7YQvLZxX/user-avatar.jpg",
                            phone: "+244 923 456 789",
                            role: "admin",
                            preferences: {
                                language: "pt",
                                theme: "light",
                                notifications: { email: true, push: true }
                            },
                            createdAt: new Date().toISOString(),
                            lastLogin: new Date().toISOString(),
                            status: "active"
                        }
                    ],
                    sessions: [],
                    passwordResets: [],
                    userActivities: [],
                    systemLogs: [],
                    projects: [],
                    clients: [],
                    notifications: []
                };
                
                localStorage.setItem(this.name, JSON.stringify(initialDB));
                console.log('Banco de dados inicializado');
            }
            return this.get();
        },
        
        get: function() {
            return JSON.parse(localStorage.getItem(this.name) || '{}');
        },
        
        save: function(data) {
            localStorage.setItem(this.name, JSON.stringify(data));
        },
        
        updateUser: function(userId, updates) {
            const db = this.get();
            const userIndex = db.users.findIndex(u => u.id === userId);
            
            if (userIndex !== -1) {
                db.users[userIndex] = { ...db.users[userIndex], ...updates };
                this.save(db);
                
                // Atualizar usuário atual se for o mesmo
                const currentUser = this.auth.getCurrentUser();
                if (currentUser && currentUser.id === userId) {
                    localStorage.setItem('currentUser', JSON.stringify(db.users[userIndex]));
                }
                return true;
            }
            return false;
        },
        
        addActivity: function(userId, type, description, details = null) {
            const db = this.get();
            const activity = {
                id: Date.now(),
                userId: userId,
                type: type,
                description: description,
                details: details,
                timestamp: new Date().toISOString(),
                page: window.location.pathname
            };
            
            db.userActivities.push(activity);
            this.save(db);
            return activity;
        }
    },
    
    // Autenticação e Sessão
    auth: {
        isLoggedIn: function() {
            const user = localStorage.getItem('currentUser');
            const token = localStorage.getItem('sessionToken');
            return user !== null && token !== null;
        },
        
        getCurrentUser: function() {
            const userData = localStorage.getItem('currentUser');
            return userData ? JSON.parse(userData) : null;
        },
        
        login: async function(email, password) {
            const db = DPSystem.database.get();
            const user = db.users.find(u => u.email === email);
            
            if (!user) {
                return { success: false, message: "E-mail não encontrado" };
            }
            
            // Verificar senha
            const hashedPassword = await this.hashPassword(password);
            if (user.password !== hashedPassword) {
                return { success: false, message: "Senha incorreta" };
            }
            
            // Atualizar último login
            user.lastLogin = new Date().toISOString();
            DPSystem.database.save(db);
            
            // Criar sessão
            const session = {
                userId: user.id,
                token: Math.random().toString(36).substring(2) + Date.now().toString(36),
                createdAt: new Date().toISOString(),
                expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
            };
            
            db.sessions.push(session);
            DPSystem.database.save(db);
            
            // Salvar dados de sessão
            localStorage.setItem('currentUser', JSON.stringify(user));
            localStorage.setItem('sessionToken', session.token);
            localStorage.setItem('userLastLogin', new Date().toISOString());
            
            // Registrar atividade
            DPSystem.database.addActivity(user.id, 'login', 'Usuário fez login no sistema');
            
            return { success: true, user };
        },
        
        logout: function() {
            const user = this.getCurrentUser();
            if (user) {
                DPSystem.database.addActivity(user.id, 'logout', 'Usuário fez logout do sistema');
            }
            
            localStorage.removeItem('currentUser');
            localStorage.removeItem('sessionToken');
            localStorage.removeItem('userLastLogin');
            
            window.location.href = 'login.html';
        },
        
        requireAuth: function() {
            if (!this.isLoggedIn() && !window.location.pathname.includes('login.html')) {
                window.location.href = 'login.html';
                return false;
            }
            return true;
        },
        
        hashPassword: async function(password) {
            const encoder = new TextEncoder();
            const data = encoder.encode(password);
            const hashBuffer = await crypto.subtle.digest('SHA-256', data);
            const hashArray = Array.from(new Uint8Array(hashBuffer));
            return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        }
    },
    
    // Notificações
    notifications: {
        show: function(title, message, type = 'info', duration = 5000) {
            // Criar elemento de notificação
            const toast = document.createElement('div');
            toast.className = `notification-toast show ${type}`;
            toast.innerHTML = `
                <div class="notification-icon">
                    <i class="fas fa-${this.getIcon(type)}"></i>
                </div>
                <div class="notification-info">
                    <div class="notification-title">${title}</div>
                    <div class="notification-message">${message}</div>
                </div>
                <button class="notification-close">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            // Adicionar estilos se não existirem
            if (!document.querySelector('#notification-styles')) {
                const styles = document.createElement('style');
                styles.id = 'notification-styles';
                styles.textContent = `
                    .notification-toast {
                        position: fixed;
                        bottom: 20px;
                        right: 20px;
                        background: white;
                        border-radius: 10px;
                        padding: 15px;
                        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
                        display: flex;
                        align-items: center;
                        gap: 15px;
                        z-index: 10000;
                        max-width: 400px;
                        transform: translateX(100%);
                        transition: transform 0.3s ease;
                    }
                    .notification-toast.show {
                        transform: translateX(0);
                    }
                    .notification-icon {
                        width: 40px;
                        height: 40px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-size: 1.2rem;
                    }
                    .notification-toast.success .notification-icon { background: #27ae60; }
                    .notification-toast.error .notification-icon { background: #e74c3c; }
                    .notification-toast.warning .notification-icon { background: #f39c12; }
                    .notification-toast.info .notification-icon { background: #3498db; }
                    .notification-info { flex: 1; }
                    .notification-title { font-weight: 600; margin-bottom: 5px; }
                    .notification-message { font-size: 0.9rem; color: #666; }
                    .notification-close { 
                        background: none; 
                        border: none; 
                        font-size: 1.2rem; 
                        cursor: pointer; 
                        color: #999; 
                    }
                `;
                document.head.appendChild(styles);
            }
            
            document.body.appendChild(toast);
            
            // Auto-remover após duração
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.remove();
                }
            }, duration);
            
            // Fechar manualmente
            toast.querySelector('.notification-close').addEventListener('click', () => {
                toast.remove();
            });
        },
        
        getIcon: function(type) {
            const icons = {
                'success': 'check-circle',
                'error': 'exclamation-circle',
                'warning': 'exclamation-triangle',
                'info': 'info-circle'
            };
            return icons[type] || 'info-circle';
        }
    }
};

// Inicializar sistema
document.addEventListener('DOMContentLoaded', function() {
    DPSystem.database.init();
});