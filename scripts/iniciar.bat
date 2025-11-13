@echo off
REM Script para INICIAR TUDO (bancos de dados + migracao)

echo Verificando e parando PostgreSQL e MongoDB locais...
echo.

REM Parar servicio PostgreSQL
echo   Parando PostgreSQL local...
net stop postgresql* 2>nul
sc stop postgresql* 2>nul
echo.

REM Parar servicio MongoDB
echo   Parando MongoDB local...
net stop MongoDB 2>nul
sc stop MongoDB 2>nul
echo.

REM Verificar y liberar puerto 5432 (PostgreSQL)
echo   Verificando porta 5432 (PostgreSQL)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :5432 ^| findstr LISTENING') do (
    echo   Finalizando proceso en puerto 5432 (PID: %%a)...
    taskkill /F /PID %%a 2>nul
)

REM Verificar y liberar puerto 27017 (MongoDB)
echo   Verificando porta 27017 (MongoDB)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :27017 ^| findstr LISTENING') do (
    echo   Finalizando proceso en puerto 27017 (PID: %%a)...
    taskkill /F /PID %%a 2>nul
)

echo   Portas liberadas!
echo.

echo Iniciando bancos de dados com Docker...
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
