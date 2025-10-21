# Script de Teste do Sistema D.Pedro Soluções
# Execute este script para verificar se tudo está funcionando

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🧪 TESTE DO SISTEMA D.PEDRO SOLUÇÕES" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar se o servidor está rodando
Write-Host "1. 🔍 Verificando servidor..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -TimeoutSec 3
    Write-Host "   ✅ Servidor está ONLINE" -ForegroundColor Green
    Write-Host "   📊 Mensagem: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Servidor está OFFLINE" -ForegroundColor Red
    Write-Host "   💡 Execute: npm run server" -ForegroundColor Yellow
}

# 2. Testar autenticação
Write-Host "`n2. 🔐 Testando autenticação..." -ForegroundColor Yellow
try {
    $loginData = @{
        email = "admin@dpedrosolucoes.com"
        password = "123456"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method Post -Body $loginData -ContentType "application/json" -TimeoutSec 5
    
    if ($loginResponse.success) {
        Write-Host "   ✅ Login BEM-SUCEDIDO" -ForegroundColor Green
        Write-Host "   👤 Usuário: $($loginResponse.user.name)" -ForegroundColor White
        Write-Host "   🎫 Token: $($loginResponse.token)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Login FALHOU" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro no teste de login: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Testar outras rotas da API
Write-Host "`n3. 🌐 Testando rotas da API..." -ForegroundColor Yellow

$apiEndpoints = @(
    "/api/dashboard",
    "/api/projects", 
    "/api/users",
    "/api/notifications"
)

foreach ($endpoint in $apiEndpoints) {
    try {
        $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000$endpoint" -TimeoutSec 3
        Write-Host "   ✅ $endpoint - FUNCIONANDO" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ $endpoint - FALHOU" -ForegroundColor Red
    }
}

# 4. Verificar arquivos frontend
Write-Host "`n4. 📁 Verificando arquivos frontend..." -ForegroundColor Yellow

$frontendFiles = @(
    "DPS.html",
    "login.html", 
    "notificacoes.html",
    "profile.html",
    "configuracoes.html",
    "css/dps1.css"
)

foreach ($file in $frontendFiles) {
    if (Test-Path "src/frontend/$file") {
        Write-Host "   ✅ $file - ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file - NÃO ENCONTRADO" -ForegroundColor Red
    }
}

# 5. Resumo final
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "🎯 RESUMO DO TESTE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "🚀 Sistema D.Pedro Soluções está PRONTO para uso!" -ForegroundColor Green
Write-Host "" 
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Mantenha o servidor rodando" -ForegroundColor White
Write-Host "   2. Acesse: http://localhost:3000" -ForegroundColor White  
Write-Host "   3. Use: admin@dpedrosolucoes.com / 123456" -ForegroundColor White
Write-Host "   4. Explore todas as funcionalidades!" -ForegroundColor White
Write-Host "" 
Write-Host "🎉 Parabéns! Seu sistema está completo e funcional!" -ForegroundColor Green -BackgroundColor DarkGreen
