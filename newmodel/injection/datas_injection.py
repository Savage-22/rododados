#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de injeção de dados para o sistema de transporte rodoviário
Gera dados realistas para todas as tabelas do sistema
"""

import psycopg2
from psycopg2 import sql
from faker import Faker
import random
from datetime import datetime, date, timedelta, time
import re

# Configuração da conexão com PostgreSQL
DB_CONFIG = {
    'host': 'localhost',
    'database': 'rododados',  # Altere para o nome da sua database
    'user': 'pr_transporte',        # Altere para seu usuário
    'password': 'transporte',    # Altere para sua senha
    'port': 5432
}

# Inicializar Faker com locale pt_BR
fake = Faker('pt_BR')
Faker.seed(42)  # Para resultados reproduzíveis
random.seed(42)

def get_connection():
    """Estabelece conexão com o banco de dados"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None

def generate_cnpj():
    """Gera um CNPJ válido no formato brasileiro"""
    # Gera números aleatórios
    cnpj = [random.randint(0, 9) for _ in range(12)]
    
    # Calcula primeiro dígito verificador
    soma = sum(cnpj[i] * (5 - i if i < 4 else 13 - i) for i in range(12))
    digito1 = 11 - (soma % 11) if soma % 11 >= 2 else 0
    cnpj.append(digito1)
    
    # Calcula segundo dígito verificador
    soma = sum(cnpj[i] * (6 - i if i < 5 else 14 - i) for i in range(13))
    digito2 = 11 - (soma % 11) if soma % 11 >= 2 else 0
    cnpj.append(digito2)
    
    # Formata: 00.000.000/0000-00
    return f"{cnpj[0]}{cnpj[1]}.{cnpj[2]}{cnpj[3]}{cnpj[4]}.{cnpj[5]}{cnpj[6]}{cnpj[7]}/{cnpj[8]}{cnpj[9]}{cnpj[10]}{cnpj[11]}-{cnpj[12]}{cnpj[13]}"

def generate_cpf():
    """Gera um CPF válido no formato brasileiro"""
    # Gera 9 primeiros dígitos
    cpf = [random.randint(0, 9) for _ in range(9)]
    
    # Calcula primeiro dígito verificador
    soma = sum(cpf[i] * (10 - i) for i in range(9))
    digito1 = 11 - (soma % 11) if soma % 11 >= 2 else 0
    cpf.append(digito1)
    
    # Calcula segundo dígito verificador
    soma = sum(cpf[i] * (11 - i) for i in range(10))
    digito2 = 11 - (soma % 11) if soma % 11 >= 2 else 0
    cpf.append(digito2)
    
    # Formata: 000.000.000-00
    return f"{cpf[0]}{cpf[1]}{cpf[2]}.{cpf[3]}{cpf[4]}{cpf[5]}.{cpf[6]}{cpf[7]}{cpf[8]}-{cpf[9]}{cpf[10]}"

def insert_companies(conn, num=5):
    """Insere empresas de transporte"""
    print("Inserindo empresas...")
    cursor = conn.cursor()
    companies = []
    
    company_names = [
        "Viação Cometa", "Expresso Brasileiro", "Águia Branca",
        "Gontijo", "Util", "Santa Cruz", "Itapemirim",
        "Rápido Federal", "São Geraldo", "Penha"
    ]
    
    for i in range(num):
        name = company_names[i] if i < len(company_names) else f"Viação {fake.company()}"
        cnpj = generate_cnpj()
        email = f"contato@{name.lower().replace(' ', '').replace('ção', 'cao')}.com.br"
        phone = fake.phone_number()
        
        cursor.execute("""
            INSERT INTO company (name, cnpj, email, phone, is_active)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id_company
        """, (name, cnpj, email, phone, True))
        
        company_id = cursor.fetchone()[0]
        companies.append(company_id)
        print(f"  ✓ {name}")
    
    conn.commit()
    cursor.close()
    return companies

def insert_bus_stops(conn, num=30):
    """Insere paradas de ônibus"""
    print("Inserindo paradas de ônibus...")
    cursor = conn.cursor()
    stops = []
    
    cities = ["Campinas", "São Paulo", "Rio de Janeiro", "Belo Horizonte", 
              "Brasília", "Curitiba", "Porto Alegre", "Salvador"]
    
    stop_types = ["Terminal", "Rodoviária", "Praça", "Avenida", "Shopping"]
    
    for _ in range(num):
        city = random.choice(cities)
        stop_type = random.choice(stop_types)
        name = f"{stop_type} {fake.street_name()}" if stop_type not in ["Terminal", "Rodoviária"] else f"{stop_type} {city}"
        street = fake.street_name()
        number = str(random.randint(1, 9999))
        
        cursor.execute("""
            INSERT INTO bus_stop (name, street, number, city, is_active)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id_stop
        """, (name, street, number, city, True))
        
        stop_id = cursor.fetchone()[0]
        stops.append({'id': stop_id, 'city': city, 'name': name})
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {num} paradas inseridas")
    return stops

def insert_routes(conn, company_ids, num=10):
    """Insere rotas de transporte"""
    print("Inserindo rotas...")
    cursor = conn.cursor()
    routes = []
    
    route_types = ['urban', 'interurban', 'express']
    
    for i in range(num):
        company_id = random.choice(company_ids)
        route_code = f"R-{str(i+1).zfill(3)}"
        name = f"Linha {i+1} - {fake.street_name()} / {fake.street_name()}"
        description = f"Rota {route_code}"
        distance = round(random.uniform(5.0, 500.0), 2)
        route_type = random.choice(route_types)
        
        cursor.execute("""
            INSERT INTO route (id_company, route_code, name, description, 
                             total_distance, route_type, is_active)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING id_route
        """, (company_id, route_code, name, description, distance, route_type, True))
        
        route_id = cursor.fetchone()[0]
        routes.append({'id': route_id, 'type': route_type, 'company_id': company_id})
        print(f"  ✓ {name}")
    
    conn.commit()
    cursor.close()
    return routes

def insert_route_stops(conn, routes, stops):
    """Insere paradas nas rotas"""
    print("Inserindo paradas nas rotas...")
    cursor = conn.cursor()
    
    for route in routes:
        # Cada rota tem entre 4 e 10 paradas
        num_stops = random.randint(4, 10)
        route_stops = random.sample(stops, min(num_stops, len(stops)))
        
        accumulated_distance = 0
        accumulated_time = 0
        base_fare = 5.50
        accumulated_fare = 0
        
        for order, stop in enumerate(route_stops, 1):
            if order > 1:
                accumulated_distance += round(random.uniform(2.0, 25.0), 2)
                accumulated_time += random.randint(5, 30)
                accumulated_fare += round(random.uniform(1.50, 5.00), 2)
            
            cursor.execute("""
                INSERT INTO route_stop (id_route, id_stop, stop_order, 
                                       distance_from_origin, estimated_min, fare_from_origin)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING
            """, (route['id'], stop['id'], order, accumulated_distance, 
                  accumulated_time, base_fare + accumulated_fare))
    
    conn.commit()
    cursor.close()
    print(f"  ✓ Paradas vinculadas às rotas")

def insert_schedules(conn, routes, num_per_route=3):
    """Insere horários para as rotas"""
    print("Inserindo horários...")
    cursor = conn.cursor()
    schedules = []
    
    for route in routes:
        for _ in range(num_per_route):
            hour = random.randint(5, 22)
            minute = random.choice([0, 15, 30, 45])
            departure_time = time(hour, minute)
            
            # Tempo de viagem estimado
            trip_duration = timedelta(hours=random.randint(1, 8))
            arrival_time = (datetime.combine(date.today(), departure_time) + trip_duration).time()
            
            # Dias da semana (1=segunda, 7=domingo)
            if random.random() < 0.7:  # 70% operam todos os dias
                days = [1, 2, 3, 4, 5, 6, 7]
            else:  # 30% só dias úteis
                days = [1, 2, 3, 4, 5]
            
            cursor.execute("""
                INSERT INTO schedule (id_route, id_company, departure_time, 
                                     arrival_time, days_of_week, is_active)
                VALUES (%s, %s, %s, %s, %s::jsonb, %s)
                RETURNING id_schedule
            """, (route['id'], route['company_id'], departure_time, 
                  arrival_time, str(days), True))
            
            schedule_id = cursor.fetchone()[0]
            schedules.append({
                'id': schedule_id, 
                'route_id': route['id'],
                'route_type': route['type'],
                'company_id': route['company_id']
            })
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {len(schedules)} horários inseridos")
    return schedules

def insert_vehicles(conn, company_ids, num=15):
    """Insere veículos"""
    print("Inserindo veículos...")
    cursor = conn.cursor()
    vehicles = []
    
    brands = ["Mercedes-Benz", "Volvo", "Scania", "Marcopolo", "Comil"]
    models = ["O500", "B270F", "K310", "Paradiso", "Campione"]
    vehicle_types = ['urban_bus', 'microbus', 'coach']
    
    for _ in range(num):
        company_id = random.choice(company_ids)
        # Gera placa brasileira formato ABC-1234 ou ABC1D23
        letters = ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ', k=3))
        numbers = ''.join(random.choices('0123456789', k=4))
        license_plate = f"{letters}-{numbers}"
        
        brand = random.choice(brands)
        model = random.choice(models)
        year = random.randint(2015, 2024)
        vehicle_type = random.choice(vehicle_types)
        
        # Capacidade depende do tipo
        if vehicle_type == 'urban_bus':
            capacity = random.randint(40, 80)
            has_assigned_seating = False
        elif vehicle_type == 'microbus':
            capacity = random.randint(20, 35)
            has_assigned_seating = True
        else:  # coach
            capacity = random.randint(42, 50)
            has_assigned_seating = True
        
        cursor.execute("""
            INSERT INTO vehicle (id_company, license_plate, brand, model, year, 
                                capacity, vehicle_type, has_assigned_seating, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id_vehicle
        """, (company_id, license_plate, brand, model, year, capacity, 
              vehicle_type, has_assigned_seating, 'active'))
        
        vehicle_id = cursor.fetchone()[0]
        vehicles.append({
            'id': vehicle_id,
            'capacity': capacity,
            'has_assigned_seating': has_assigned_seating,
            'company_id': company_id
        })
        print(f"  ✓ {brand} {model} - {license_plate}")
    
    conn.commit()
    cursor.close()
    return vehicles

def insert_seats(conn, vehicles):
    """Insere assentos para veículos com assentos numerados"""
    print("Inserindo assentos...")
    cursor = conn.cursor()
    
    for vehicle in vehicles:
        if vehicle['has_assigned_seating']:
            capacity = vehicle['capacity']
            # Cria assentos numerados
            for seat_num in range(1, capacity + 1):
                floor = 1 if seat_num <= capacity // 2 else 2 if capacity > 45 else 1
                
                cursor.execute("""
                    INSERT INTO seat (id_vehicle, seat_number, floor, is_active)
                    VALUES (%s, %s, %s, %s)
                """, (vehicle['id'], str(seat_num), floor, True))
    
    conn.commit()
    cursor.close()
    print(f"  ✓ Assentos criados para veículos com numeração")

def insert_people(conn, num_passengers=50, num_employees=20):
    """Insere pessoas (passageiros e funcionários)"""
    print("Inserindo pessoas...")
    cursor = conn.cursor()
    passengers = []
    employees = []
    
    # Passageiros
    for _ in range(num_passengers):
        first_name = fake.first_name()
        last_name = fake.last_name()
        cpf = generate_cpf()
        email = fake.email()
        phone = fake.phone_number()
        birthday = fake.date_of_birth(minimum_age=18, maximum_age=80)
        
        cursor.execute("""
            INSERT INTO person (first_name, last_name, cpf, email, phone, 
                               birthday, person_type)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING id_person
        """, (first_name, last_name, cpf, email, phone, birthday, 'passenger'))
        
        person_id = cursor.fetchone()[0]
        
        # Inserir em Passenger
        is_student = random.random() < 0.3  # 30% são estudantes
        loyalty_points = random.randint(0, 1000)
        
        cursor.execute("""
            INSERT INTO passenger (id_person, loyalty_points, is_student)
            VALUES (%s, %s, %s)
        """, (person_id, loyalty_points, is_student))
        
        passengers.append({'id': person_id, 'is_student': is_student})
    
    # Funcionários
    for _ in range(num_employees):
        first_name = fake.first_name()
        last_name = fake.last_name()
        cpf = generate_cpf()
        email = fake.email()
        phone = fake.phone_number()
        birthday = fake.date_of_birth(minimum_age=21, maximum_age=65)
        
        cursor.execute("""
            INSERT INTO person (first_name, last_name, cpf, email, phone, 
                               birthday, person_type)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING id_person
        """, (first_name, last_name, cpf, email, phone, birthday, 'employee'))
        
        person_id = cursor.fetchone()[0]
        employees.append(person_id)
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {num_passengers} passageiros e {num_employees} funcionários")
    return passengers, employees

def insert_students(conn, passengers):
    """Insere estudantes"""
    print("Inserindo estudantes...")
    cursor = conn.cursor()
    
    universities = ["UNICAMP", "USP", "UFRJ", "UFMG", "UnB", "PUC", "UNESP"]
    
    for passenger in passengers:
        if passenger['is_student']:
            id_u = f"RA{random.randint(100000, 999999)}"
            university = random.choice(universities)
            status = random.choice(['active', 'active', 'active', 'inactive'])  # 75% ativos
            
            cursor.execute("""
                INSERT INTO student (id_person, id_u, university_name, status)
                VALUES (%s, %s, %s, %s)
            """, (passenger['id'], id_u, university, status))
    
    conn.commit()
    cursor.close()
    print(f"  ✓ Estudantes cadastrados")

def insert_employees_details(conn, employee_ids, company_ids):
    """Insere detalhes dos funcionários"""
    print("Inserindo detalhes de funcionários...")
    cursor = conn.cursor()
    drivers = []
    sellers = []
    
    employee_types = ['driver', 'seller', 'admin', 'mechanic']
    
    for emp_id in employee_ids:
        employee_code = f"EMP{random.randint(1000, 9999)}"
        company_id = random.choice(company_ids)
        hire_date = fake.date_between(start_date='-10y', end_date='today')
        salary = round(random.uniform(2000, 8000), 2)
        emp_type = random.choice(employee_types)
        
        cursor.execute("""
            INSERT INTO employee (id_person, employee_code, id_company, 
                                 hire_date, salary, employee_type, is_active)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (emp_id, employee_code, company_id, hire_date, salary, emp_type, True))
        
        if emp_type == 'driver':
            drivers.append(emp_id)
        elif emp_type == 'seller':
            sellers.append(emp_id)
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {len(employee_ids)} funcionários cadastrados")
    return drivers, sellers

def insert_drivers(conn, driver_ids):
    """Insere motoristas"""
    print("Inserindo motoristas...")
    cursor = conn.cursor()
    
    for driver_id in driver_ids:
        license_number = f"{random.randint(100000000, 999999999)}"
        license_category = random.choice(['D', 'E'])
        # Licença válida por 1-5 anos no futuro
        expiry_date = date.today() + timedelta(days=random.randint(365, 1825))
        
        cursor.execute("""
            INSERT INTO driver (id_person, license_number, license_category, 
                               license_expiry_date)
            VALUES (%s, %s, %s, %s)
        """, (driver_id, license_number, license_category, expiry_date))
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {len(driver_ids)} motoristas cadastrados")

def insert_sellers(conn, seller_ids):
    """Insere vendedores"""
    print("Inserindo vendedores...")
    cursor = conn.cursor()
    
    for seller_id in seller_ids:
        terminal_id = random.randint(1, 10)
        
        cursor.execute("""
            INSERT INTO seller (id_person, terminal_id)
            VALUES (%s, %s)
        """, (seller_id, terminal_id))
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {len(seller_ids)} vendedores cadastrados")
    return seller_ids

def insert_trips(conn, schedules, vehicles, drivers, num_days=30):
    """Insere viagens"""
    print("Inserindo viagens...")
    cursor = conn.cursor()
    trips = []
    
    start_date = date.today() - timedelta(days=15)
    
    for schedule in schedules:
        # Cria viagens para os próximos dias
        for day_offset in range(num_days):
            trip_date = start_date + timedelta(days=day_offset)
            
            # Seleciona veículo da mesma empresa
            company_vehicles = [v for v in vehicles if v['company_id'] == schedule['company_id']]
            if not company_vehicles:
                continue
                
            vehicle = random.choice(company_vehicles)
            driver = random.choice(drivers) if drivers else None
            
            if not driver:
                continue
            
            # Combina data com horário
            cursor.execute("SELECT departure_time, arrival_time FROM schedule WHERE id_schedule = %s", 
                          (schedule['id'],))
            times = cursor.fetchone()
            
            departure_datetime = datetime.combine(trip_date, times[0])
            
            # Se houver hora de chegada
            if times[1]:
                arrival_datetime = datetime.combine(trip_date, times[1])
                # Se a chegada é antes da saída, significa que cruza para o dia seguinte
                if arrival_datetime <= departure_datetime:
                    arrival_datetime = arrival_datetime + timedelta(days=1)
            else:
                arrival_datetime = None
            
            # Status da viagem
            if trip_date < date.today():
                status = random.choice(['completed', 'completed', 'completed', 'cancelled'])
            elif trip_date == date.today():
                status = random.choice(['in_progress', 'scheduled'])
            else:
                status = 'scheduled'
            
            # Capacidade disponível
            if status == 'completed':
                available = random.randint(0, vehicle['capacity'] // 3)
            elif status == 'cancelled':
                available = vehicle['capacity']
            else:
                available = random.randint(vehicle['capacity'] // 2, vehicle['capacity'])
            
            cursor.execute("""
                INSERT INTO trip (id_schedule, id_vehicle, id_driver, trip_date,
                                 departure_datetime, arrival_datetime, status, available_capacity)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id_trip
            """, (schedule['id'], vehicle['id'], driver, trip_date,
                  departure_datetime, arrival_datetime, status, available))
            
            trip_id = cursor.fetchone()[0]
            trips.append({
                'id': trip_id,
                'schedule_id': schedule['id'],
                'vehicle_id': vehicle['id'],
                'capacity': vehicle['capacity'],
                'available': available,
                'status': status,
                'has_assigned_seating': vehicle['has_assigned_seating'],
                'date': trip_date  # Añadir fecha para calcular purchase_datetime
            })
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {len(trips)} viagens criadas")
    return trips

def insert_tickets(conn, trips, passengers, sellers):
    """Insere tickets"""
    print("Inserindo tickets...")
    cursor = conn.cursor()
    
    # Buscar paradas por rota
    cursor.execute("""
        SELECT rs.id_route, rs.id_stop, rs.stop_order, rs.fare_from_origin
        FROM route_stop rs
        ORDER BY rs.id_route, rs.stop_order
    """)
    route_stops_data = cursor.fetchall()
    
    # Organizar paradas por rota
    route_stops = {}
    for row in route_stops_data:
        route_id = row[0]
        if route_id not in route_stops:
            route_stops[route_id] = []
        route_stops[route_id].append({
            'stop_id': row[1],
            'order': row[2],
            'fare': row[3]
        })
    
    # Buscar assentos por veículo
    cursor.execute("SELECT id_seat, id_vehicle FROM seat WHERE is_active = true")
    seats_data = cursor.fetchall()
    vehicle_seats = {}
    for seat_id, vehicle_id in seats_data:
        if vehicle_id not in vehicle_seats:
            vehicle_seats[vehicle_id] = []
        vehicle_seats[vehicle_id].append(seat_id)
    
    ticket_count = 0
    
    for trip in trips:
        if trip['status'] == 'cancelled':
            continue
        
        # Número de tickets vendidos
        tickets_sold = trip['capacity'] - trip['available']
        
        # Buscar rota e empresa do schedule
        cursor.execute("SELECT id_route, id_company FROM schedule WHERE id_schedule = %s", 
                      (trip['schedule_id'],))
        result = cursor.fetchone()
        if not result:
            continue
        route_id, company_id = result
        
        if route_id not in route_stops or len(route_stops[route_id]) < 2:
            continue
        
        stops = route_stops[route_id]
        available_seats = vehicle_seats.get(trip['vehicle_id'], []).copy()
        
        for _ in range(tickets_sold):
            passenger = random.choice(passengers)
            seller = random.choice(sellers) if random.random() < 0.7 else None  # 70% vendas presenciais
            
            # Seleciona paradas de embarque e destino
            boarding_idx = random.randint(0, len(stops) - 2)
            destination_idx = random.randint(boarding_idx + 1, len(stops) - 1)
            
            boarding_stop = stops[boarding_idx]['stop_id']
            destination_stop = stops[destination_idx]['stop_id']
            
            # Calcula preço baseado na diferença de tarifas
            price = float(stops[destination_idx]['fare'] - stops[boarding_idx]['fare'])
            
            # Desconto para estudantes
            discount = 0.0
            discount_reason = None
            if passenger['is_student'] and random.random() < 0.8:  # 80% usam desconto
                discount = round(price * 0.5, 2)  # 50% desconto
                discount_reason = 'student'
            
            # Assento (se aplicável)
            seat_id = None
            if trip['has_assigned_seating'] and available_seats:
                seat_id = available_seats.pop(random.randint(0, len(available_seats) - 1))
            
            payment_method = random.choice(['cash', 'card', 'pix', 'transfer'])
            status = 'used' if trip['status'] == 'completed' else 'paid'
            
            # Data e hora de compra do ticket (entre 1-30 dias antes da viagem)
            days_before = random.randint(1, 30)
            purchase_date = trip['date'] - timedelta(days=days_before)
            purchase_time = time(random.randint(8, 20), random.randint(0, 59))
            purchase_datetime = datetime.combine(purchase_date, purchase_time)
            
            try:
                cursor.execute("""
                    INSERT INTO ticket (id_trip, id_passenger, id_seller, id_company, id_seat,
                                       id_boarding_stop, id_destination_stop, price,
                                       discount_applied, discount_reason, payment_method, 
                                       status, purchase_datetime)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (trip['id'], passenger['id'], seller, company_id, seat_id,
                      boarding_stop, destination_stop, price,
                      discount, discount_reason, payment_method, status, purchase_datetime))
                ticket_count += 1
            except psycopg2.IntegrityError as e:
                # Ignora erros de constraint (assento já vendido, etc)
                conn.rollback()
                # Reinicia transação
                cursor.execute("BEGIN;")
                continue
            except Exception as e:
                # Para outros erros, imprime e continua
                print(f"\n⚠️  Erro ao inserir ticket: {e}")
                conn.rollback()
                cursor.execute("BEGIN;")
                continue
    
    conn.commit()
    cursor.close()
    print(f"  ✓ {ticket_count} tickets criados")

def main():
    """Função principal"""
    print("=" * 60)
    print("INJEÇÃO DE DADOS - SISTEMA DE TRANSPORTE RODOVIÁRIO")
    print("=" * 60)
    print()
    
    conn = get_connection()
    if not conn:
        print("❌ Não foi possível conectar ao banco de dados")
        return
    
    try:
        # 1. Empresas
        company_ids = insert_companies(conn, num=5)
        
        # 2. Paradas de ônibus
        stops = insert_bus_stops(conn, num=30)
        
        # 3. Rotas
        routes = insert_routes(conn, company_ids, num=10)
        
        # 4. Paradas nas rotas
        insert_route_stops(conn, routes, stops)
        
        # 5. Horários
        schedules = insert_schedules(conn, routes, num_per_route=3)
        
        # 6. Veículos
        vehicles = insert_vehicles(conn, company_ids, num=15)
        
        # 7. Assentos
        insert_seats(conn, vehicles)
        
        # 8. Pessoas
        passengers, employee_ids = insert_people(conn, num_passengers=50, num_employees=20)
        
        # 9. Estudantes
        insert_students(conn, passengers)
        
        # 10. Funcionários
        drivers, sellers = insert_employees_details(conn, employee_ids, company_ids)
        
        # 11. Motoristas
        insert_drivers(conn, drivers)
        
        # 12. Vendedores
        seller_ids = insert_sellers(conn, sellers)
        
        # 13. Viagens
        trips = insert_trips(conn, schedules, vehicles, drivers, num_days=30)
        
        # 14. Tickets
        insert_tickets(conn, trips, passengers, seller_ids)
        
        print()
        print("=" * 60)
        print("✅ INJEÇÃO DE DADOS CONCLUÍDA COM SUCESSO!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Erro durante a injeção de dados: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
