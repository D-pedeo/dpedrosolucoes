# Script de Inicialização Automática
Write-Host "🚀 INICIANDO SISTEMA D.PEDRO SOLUÇÕES" -ForegroundColor Green

# Parar processos na porta 3000
Write-Host "1. 🛑 Parando processos..." -ForegroundColor Yellow
try {
    Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
} catch { }

# Iniciar servidor
Write-Host "2. 🌐 Iniciando servidor..." -ForegroundColor Yellow
Start-Process -FilePath "node" -ArgumentList "src/server/app.js" -WindowStyle Hidden
Start-Sleep -Seconds 5

# Verificar servidor
Write-Host "3. 🔍 Verificando..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -TimeoutSec 5
    Write-Host "   ✅ Servidor ONLINE" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Servidor não responde" -ForegroundColor Red
}

Write-Host "`n🎯 Sistema pronto! Acesse: http://localhost:3000" -ForegroundColor Green
