#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para limpiar todos los datos de las tablas
"""

import psycopg2

DB_CONFIG = {
    'host': 'localhost',
    'database': 'rododados',
    'user': 'pr_transporte',
    'password': 'transporte',
    'port': 5432
}

def clean_database():
    """Elimina todas las tablas de la base de datos"""
    print("🗑️  Eliminando todas las tablas...")
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Eliminar tablas usando DROP CASCADE (elimina las tablas completamente)
        tables_order = [
            'ticket',
            'trip', 
            'seat',
            'driver',
            'seller',
            'employee',
            'student',
            'passenger',
            'person',
            'schedule',
            'route_stop',
            'route',
            'vehicle',
            'bus_stop',
            'company'
        ]
        
        for table in tables_order:
            cursor.execute(f"DROP TABLE IF EXISTS {table} CASCADE;")
            print(f"  ✓ {table} eliminada")
        
        conn.commit()
        cursor.close()
        conn.close()
        
        print("\n✅ Todas las tablas eliminadas exitosamente!")
        print("   Ahora debes:")
        print("   1. Ejecutar el script new_model.sql para recrear las tablas")
        print("   2. Ejecutar: python3 datas_injection.py")
        
    except Exception as e:
        print(f"\n❌ Error al eliminar tablas: {e}")
        if 'conn' in locals():
            conn.rollback()

if __name__ == "__main__":
    clean_database()
