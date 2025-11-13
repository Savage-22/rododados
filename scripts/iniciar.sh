#!/bin/bash
# Script para INICIAR TUDO (bancos de dados + migração)

echo "� Verificando e parando PostgreSQL e MongoDB locais..."

# Detectar sistema operacional
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "  → Sistema: Linux"
    
    # Tentar parar PostgreSQL
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        echo "  → PostgreSQL local detectado, parando..."
        sudo systemctl stop postgresql 2>/dev/null || sudo service postgresql stop 2>/dev/null
    fi
    
    # Tentar parar MongoDB
    if systemctl is-active --quiet mongod 2>/dev/null; then
        echo "  → MongoDB local detectado, parando..."
        sudo systemctl stop mongod 2>/dev/null || sudo service mongod stop 2>/dev/null
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "  → Sistema: macOS"
    
    # Tentar parar PostgreSQL
    if brew services list 2>/dev/null | grep -q "postgresql.*started"; then
        echo "  → PostgreSQL local detectado, parando..."
        brew services stop postgresql 2>/dev/null
    fi
    
    # Tentar parar MongoDB
    if brew services list 2>/dev/null | grep -q "mongodb.*started"; then
        echo "  → MongoDB local detectado, parando..."
        brew services stop mongodb-community 2>/dev/null
    fi
fi

# Verificar e matar processos nas portas (fallback)
echo "  → Verificando portas 5432 e 27017..."

# Porta 5432 (PostgreSQL)
PG_PID=$(lsof -ti:5432 2>/dev/null)
if [ ! -z "$PG_PID" ]; then
    echo "  ⚠️  Processo na porta 5432 detectado (PID: $PG_PID), finalizando..."
    kill -9 $PG_PID 2>/dev/null
fi

# Porta 27017 (MongoDB)
MONGO_PID=$(lsof -ti:27017 2>/dev/null)
if [ ! -z "$MONGO_PID" ]; then
    echo "  ⚠️  Processo na porta 27017 detectado (PID: $MONGO_PID), finalizando..."
    kill -9 $MONGO_PID 2>/dev/null
fi

echo "  ✅ Portas liberadas!"
echo ""

echo "�🚀 Iniciando bancos de dados com Docker..."
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
