@echo off
chcp 65001 > nul
echo ===========================================
echo   D.PEDRO SOLUÇÕES - INICIALIZAÇÃO AUTOMÁTICA
echo ===========================================
echo.

echo 1. Parando processos existentes na porta 3000...
for /f "tokens=5" %%i in ('netstat -aon ^| findstr ":3000"') do (
    taskkill /PID %%i /F > nul 2>&1
)

echo 2. Iniciando servidor...
start "Servidor D.Pedro Soluções" /min cmd /c "npm run server"
timeout /t 5 /nobreak > nul

echo 3. Verificando servidor...
curl -s http://localhost:3000/api/health > nul
if %errorlevel% equ 0 (
    echo   ✅ Servidor iniciado com sucesso
) else (
    echo   ❌ Servidor não iniciou corretamente
    echo   💡 Verifique manualmente com: npm run server
    pause
    exit /b 1
)

echo 4. Iniciando aplicativo...
if exist "dist\win-unpacked\D.Pedro Soluções.exe" (
    start "" "dist\win-unpacked\D.Pedro Soluções.exe"
    echo   ✅ Aplicativo iniciado
) else (
    echo   ❌ Aplicativo não encontrado
    echo   💡 Execute: npm run build
    pause
    exit /b 1
)

echo.
echo 🎉 SISTEMA INICIADO COM SUCESSO!
echo.
echo 📊 Servidor: http://localhost:3000
echo 👤 Login: admin@dpedrosolucoes.com
echo 🔑 Senha: 123456
echo.
echo 💡 Dica: Mantenha esta janela aberta enquanto usar o sistema
echo.
pause
