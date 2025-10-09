#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para limpiar todos los datos de las tablas
"""

import psycopg2

DB_CONFIG = {
    'host': 'localhost',
    'database': '',
    'user': '',
    'password': '',
    'port': 5432
}

def clean_database():
    """Limpia todos los datos de las tablas"""
    print("🗑️  Limpiando base de datos...")
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Eliminar datos usando DELETE CASCADE
        tables_order = [
            'Ticket',
            'Trip', 
            'Seat',
            'Driver',
            'Seller',
            'Employee',
            'Student',
            'Passenger',
            'Person',
            'Schedule',
            'Route_Stop',
            'Route',
            'Vehicle',
            'Bus_Stop',
            'Company'
        ]
        
        for table in tables_order:
            cursor.execute(f"DELETE FROM {table};")
            # Reiniciar secuencia de IDs
            cursor.execute(f"""
                SELECT setval(pg_get_serial_sequence('{table.lower()}', 
                    CASE 
                        WHEN '{table}' = 'Company' THEN 'id_company'
                        WHEN '{table}' = 'Bus_Stop' THEN 'id_stop'
                        WHEN '{table}' = 'Route' THEN 'id_route'
                        WHEN '{table}' = 'Schedule' THEN 'id_schedule'
                        WHEN '{table}' = 'Vehicle' THEN 'id_vehicle'
                        WHEN '{table}' = 'Seat' THEN 'id_seat'
                        WHEN '{table}' = 'Person' THEN 'id_person'
                        WHEN '{table}' = 'Trip' THEN 'id_trip'
                        WHEN '{table}' = 'Ticket' THEN 'id_ticket'
                        ELSE NULL
                    END), 1, false)
                WHERE '{table}' IN ('Company', 'Bus_Stop', 'Route', 'Schedule', 
                                    'Vehicle', 'Seat', 'Person', 'Trip', 'Ticket');
            """)
            print(f"  ✓ {table} limpiada")
        
        conn.commit()
        cursor.close()
        conn.close()
        
        print("\n✅ Base de datos limpiada exitosamente!")
        print("   Ahora puedes ejecutar: python3 datas_injection.py")
        
    except Exception as e:
        print(f"\n❌ Error al limpiar base de datos: {e}")
        conn.rollback()

if __name__ == "__main__":
    clean_database()
