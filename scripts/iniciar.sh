#!/bin/bash
# Script para INICIAR TUDO (bancos de dados + migração)

echo "🚀 Iniciando bancos de dados..."
docker-compose up -d postgres mongodb mongo-express

echo ""
echo "⏳ Aguardando bancos de dados ficarem prontos..."
sleep 8

echo ""
echo "🔄 Executando migração..."
docker-compose run --rm migrator python -u migrar.py

echo ""
echo "✅ Pronto! Você pode ver os dados em:"
echo "   📊 Mongo Express: http://localhost:8081"
