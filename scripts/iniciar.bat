@echo off
REM Script para INICIAR TUDO (bancos de dados + migracao)

echo Iniciando bancos de dados...
docker-compose up -d postgres mongodb mongo-express

echo.
echo Aguardando bancos de dados ficarem prontos...
timeout /t 8 /nobreak >nul

echo.
echo Executando migracao...
docker-compose run --rm migrator python -u migrar.py

echo.
echo Pronto! Voce pode ver os dados em:
echo    Mongo Express: http://localhost:8081
pause
