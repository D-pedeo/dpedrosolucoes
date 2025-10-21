@echo off
echo =================================
echo   D.PEDRO SOLU??ES - SISTEMA
echo =================================
echo.

REM Verificar se o aplicativo existe
if not exist "dist\win-unpacked\D.Pedro Solu??es.exe" (
    echo ? Aplicativo n?o encontrado.
    echo ?? Verifique se o build foi realizado corretamente.
    pause
    exit /b 1
)

REM Iniciar servidor (opcional)
echo ?? Iniciando servidor (opcional)...
start cmd /k "npm run server"

REM Aguardar um pouco
timeout /t 2 /nobreak >nul

REM Iniciar aplicativo Electron
echo ?? Iniciando aplicativo D.Pedro Solu??es...
start "" "dist\win-unpacked\D.Pedro Solu??es.exe"

echo.
echo ? Sistema iniciado com sucesso!
echo.
echo ?? Se o servidor foi iniciado: http://localhost:3000
echo ?? Credenciais: admin@dpedrosolucoes.com / 123456
echo.
echo ?? Dica: Feche esta janela quando terminar de usar o sistema.
echo.
pause
