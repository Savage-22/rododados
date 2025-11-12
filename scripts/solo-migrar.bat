@echo off
REM Script para APENAS executar a migracao

echo Executando migracao...
docker-compose run --rm migrator python -u migrar.py

echo Migracao concluida
pause
