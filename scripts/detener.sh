#!/bin/bash
# Script para PARAR TUDO e LIMPAR (sem deixar arquivos basura)

echo "🛑 Parando todos os contêineres e removendo volumes..."
docker-compose down -v

echo "✅ Tudo parado e limpo (sem arquivos basura)"
echo "💡 Para iniciar novamente, execute: ./scripts/iniciar.sh"
