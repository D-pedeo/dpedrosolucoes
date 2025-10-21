@echo off
echo ===========================================
echo   TESTE DO SISTEMA D.PEDRO SOLU??ES
echo ===========================================
echo.

echo 1. Verificando servidor...
curl -s http://localhost:3000/api/health > nul
if %errorlevel% equ 0 (
    echo   ? Servidor est? rodando
) else (
    echo   ? Servidor n?o est? rodando
    echo   Execute: npm run server
    pause
    exit /b 1
)

echo.
echo 2. Verificando aplicativo...
if exist "dist\win-unpacked\D.Pedro Solu??es.exe" (
    echo   ? Aplicativo encontrado
) else (
    echo   ? Aplicativo n?o encontrado
    echo   Execute: npm run build
    pause
    exit /b 1
)

echo.
echo 3. Iniciando aplicativo...
echo   ?? Iniciando D.Pedro Solu??es...
start "" "dist\win-unpacked\D.Pedro Solu??es.exe"

echo.
echo ? Sistema iniciado com sucesso!
echo.
echo ?? Servidor: http://localhost:3000
echo ?? Login: admin@dpedrosolucoes.com
echo ?? Senha: 123456
echo.
echo ?? Dica: Mantenha o servidor rodando enquanto usa o aplicativo
echo.
pause
