#!/bin/bash
# Script para APENAS executar a migração (se já tem os bancos rodando)

echo "🔄 Executando migração..."
docker-compose run --rm migrator python -u migrar.py

echo ""
echo "✅ Migração concluída"
