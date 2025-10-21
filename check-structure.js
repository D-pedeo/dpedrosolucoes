const fs = require('fs');
const path = require('path');

console.log('🔍 Verificando estrutura do projeto...');

// Verificar arquivos essenciais
const essentialFiles = [
    'main.js',
    'package.json',
    'src/server/app.js',
    'src/server/config/database.js',
    'src/frontend/DPS.html',
    'src/frontend/css/dps1.css',
    'src/frontend/js/dps1.js'
];

let allFilesExist = true;

essentialFiles.forEach(file => {
    if (fs.existsSync(file)) {
        console.log('✅ ' + file);
    } else {
        console.log('❌ ' + file + ' - FALTANDO');
        allFilesExist = false;
    }
});

// Verificar estrutura de pastas
const essentialFolders = [
    'src',
    'src/server',
    'src/server/routes',
    'src/server/models',
    'src/server/config',
    'src/frontend',
    'src/frontend/css',
    'src/frontend/js',
    'src/assets',
    'build',
    'data'
];

console.log('\n📁 Verificando pastas...');
essentialFolders.forEach(folder => {
    if (fs.existsSync(folder)) {
        console.log('✅ ' + folder);
    } else {
        console.log('❌ ' + folder + ' - FALTANDO');
        allFilesExist = false;
    }
});

// Verificar node_modules
console.log('\n📦 Verificando dependências...');
if (fs.existsSync('node_modules')) {
    console.log('✅ node_modules existe');
    
    // Verificar dependências críticas
    const criticalDeps = ['electron', 'express', 'sqlite3', 'bcryptjs'];
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    const allDeps = {...packageJson.dependencies, ...packageJson.devDependencies};
    
    criticalDeps.forEach(dep => {
        if (allDeps[dep]) {
            const depPath = path.join('node_modules', dep);
            if (fs.existsSync(depPath)) {
                console.log('✅ ' + dep);
            } else {
                console.log('❌ ' + dep + ' - Instalada mas pasta não encontrada');
                allFilesExist = false;
            }
        } else {
            console.log('❌ ' + dep + ' - Não listada no package.json');
            allFilesExist = false;
        }
    });
} else {
    console.log('❌ node_modules não existe - Execute npm install');
    allFilesExist = false;
}

console.log('\n' + (allFilesExist ? '🎉 Estrutura OK! Pode prosseguir com o build.' : '⚠️  Corrija os problemas acima antes do build.'));
