@echo off
REM Script para PARAR TUDO e LIMPAR (sem deixar arquivos basura)

echo Parando todos os conteineres e removendo volumes...
docker-compose down -v

echo.
echo Tudo parado e limpo (sem arquivos basura)
echo Para iniciar novamente, execute: scripts\iniciar.bat
pause
