New-Item -Path "install.js" -ItemType File -Value @"
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Configurando D.Pedro Soluções...');

// Criar diretório de dados se não existir
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
    console.log('✅ Diretório de dados criado');
}

// Criar diretório de assets se não existir
const assetsDir = path.join(__dirname, 'src', 'assets', 'icons');
if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
    console.log('✅ Diretório de assets criado');
}

console.log('✅ Configuração concluída!');
console.log('👉 Execute "npm start" para iniciar a aplicação');
"@