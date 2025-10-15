#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de teste de conexão com PostgreSQL
"""

import psycopg2

# Configuração de conexão - ALTERE CONFORME NECESSÁRIO
DB_CONFIG = {
    'host': 'localhost',
    'database': 'rododados',
    'user': 'pr_transporte',
    'password': 'transporte',
    'port': 5432
}

def test_connection():
    """Testa a conexão com o banco de dados"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Contar tabelas
        cursor.execute("""
            SELECT COUNT(*) 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)
        num_tables = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        print("✅ Conexão bem-sucedida!")
        print(f"📋 {num_tables} tabelas encontradas no banco de dados")
        return True
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

if __name__ == "__main__":
    test_connection()
