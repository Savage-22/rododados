#!/usr/bin/env python3
"""
MIGRAÇÃO DE POSTGRESQL PARA MONGODB
====================================
Este script copia todos os dados do PostgreSQL para MongoDB
de forma automática.

O que faz?
- Lê tabelas do PostgreSQL
- Converte para documentos MongoDB
- Cria relações entre dados
"""

import psycopg2
from pymongo import MongoClient
from dotenv import load_dotenv
import os
from datetime import datetime
from bson import ObjectId

# Carregar configuração do arquivo .env
load_dotenv()

# === CONFIGURAÇÃO DOS BANCOS DE DADOS ===
POSTGRES = {
    'host': os.getenv('PG_HOST', 'postgres'),
    'database': os.getenv('PG_DATABASE', 'rododados'),
    'user': os.getenv('PG_USER', 'pr_transporte'),
    'password': os.getenv('PG_PASSWORD', 'transporte'),
    'port': os.getenv('PG_PORT', '5432')
}

MONGODB_URI = os.getenv('MONGO_URI', 'mongodb://mongodb:27017/')
MONGODB_NOME = os.getenv('MONGO_DATABASE', 'rododados_mongo')


class Migrador:
    """Classe que faz a migração de PostgreSQL para MongoDB"""
    
    def __init__(self):
        # Conectar ao PostgreSQL
        self.pg_conn = psycopg2.connect(**POSTGRES)
        self.pg_cursor = self.pg_conn.cursor()
        
        # Conectar ao MongoDB
        self.mongo_client = MongoClient(MONGODB_URI)
        self.mongo_db = self.mongo_client[MONGODB_NOME]
        
        # Dicionários para converter IDs do PostgreSQL para MongoDB
        self.empresas = {}      # cnpj -> ObjectId
        self.paradas = {}       # id -> ObjectId
        self.rotas = {}         # id -> ObjectId
        self.veiculos = {}      # license_plate -> ObjectId
        self.passageiros = {}   # cpf -> ObjectId
        self.funcionarios = {}  # cpf -> ObjectId
        self.horarios = {}      # id -> ObjectId
    
    def mostrar(self, mensagem, tipo="INFO"):
        """Mostra mensagens no console com ícones"""
        hora = datetime.now().strftime("%H:%M:%S")
        icones = {
            "INFO": "ℹ️",
            "OK": "✅",
            "ERRO": "❌",
            "AVISO": "⚠️"
        }
        icone = icones.get(tipo, "•")
        print(f"[{hora}] {icone} {mensagem}")
    
    def limpar_mongodb(self):
        """Apaga todos os dados anteriores do MongoDB"""
        self.mostrar("Limpando MongoDB...", "AVISO")
        for colecao in self.mongo_db.list_collection_names():
            self.mongo_db[colecao].drop()
        self.mostrar("MongoDB limpo", "OK")
    
    def converter_data(self, data):
        """Converte datas do PostgreSQL para formato MongoDB"""
        if data is None:
            return None
        if isinstance(data, datetime):
            return data
        return datetime.combine(data, datetime.min.time())
    
    def migrar_empresas(self):
        """Migra tabela Company -> coleção empresas"""
        self.mostrar("Migrando empresas...")
        
        self.pg_cursor.execute("SELECT cnpj, name FROM company ORDER BY cnpj")
        empresas = self.pg_cursor.fetchall()
        
        documentos = []
        for cnpj, nome in empresas:
            id_mongo = ObjectId()
            self.empresas[cnpj] = id_mongo
            
            documentos.append({
                "_id": id_mongo,
                "cnpj": cnpj.strip() if cnpj else cnpj,
                "nome": nome
            })
        
        if documentos:
            self.mongo_db.empresas.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} empresas migradas", "OK")
        return len(documentos)
    
    def migrar_paradas(self):
        """Migra tabela BusStop -> coleção paradas"""
        self.mostrar("Migrando paradas...")
        
        self.pg_cursor.execute("SELECT id, name, location FROM busstop ORDER BY id")
        paradas = self.pg_cursor.fetchall()
        
        documentos = []
        for id_parada, nome, localizacao in paradas:
            id_mongo = ObjectId()
            self.paradas[id_parada] = id_mongo
            
            documentos.append({
                "_id": id_mongo,
                "nome": nome,
                "localizacao": localizacao
            })
        
        if documentos:
            self.mongo_db.paradas.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} paradas migradas", "OK")
        return len(documentos)
    
    def migrar_rotas(self):
        """Migra tabela Route -> coleção rotas"""
        self.mostrar("Migrando rotas...")
        
        self.pg_cursor.execute("""
            SELECT id, origin_id, destination_id, distance
            FROM route ORDER BY id
        """)
        rotas = self.pg_cursor.fetchall()
        
        documentos = []
        for id_rota, origem_id, destino_id, distancia in rotas:
            id_mongo = ObjectId()
            self.rotas[id_rota] = id_mongo
            
            # Buscar quais empresas operam esta rota
            self.pg_cursor.execute("""
                SELECT cnpj FROM companyroute WHERE route_id = %s
            """, (id_rota,))
            cnpjs = [linha[0] for linha in self.pg_cursor.fetchall()]
            empresas_ids = [self.empresas.get(cnpj) for cnpj in cnpjs if cnpj in self.empresas]
            
            documentos.append({
                "_id": id_mongo,
                "origem": self.paradas.get(origem_id),
                "destino": self.paradas.get(destino_id),
                "distancia_km": distancia,
                "empresas": empresas_ids
            })
        
        if documentos:
            self.mongo_db.rotas.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} rotas migradas", "OK")
        return len(documentos)
    
    def migrar_veiculos(self):
        """Migra tabela Vehicle + Seat -> coleção veiculos (com assentos dentro)"""
        self.mostrar("Migrando veículos...")
        
        self.pg_cursor.execute("""
            SELECT license_plate, brand, model
            FROM vehicle ORDER BY license_plate
        """)
        veiculos = self.pg_cursor.fetchall()
        
        documentos = []
        total_assentos = 0
        
        for placa, marca, modelo in veiculos:
            id_mongo = ObjectId()
            self.veiculos[placa] = id_mongo
            
            # Obter assentos deste veículo
            self.pg_cursor.execute("""
                SELECT id, seat_row, seat_column
                FROM seat
                WHERE license_plate = %s
                ORDER BY seat_row, seat_column
            """, (placa,))
            assentos = self.pg_cursor.fetchall()
            
            assentos_docs = []
            for id_assento, fileira, coluna in assentos:
                total_assentos += 1
                assentos_docs.append({
                    "fileira": fileira.strip() if fileira else fileira,
                    "coluna": coluna.strip() if coluna else coluna
                })
            
            documentos.append({
                "_id": id_mongo,
                "placa": placa.strip() if placa else placa,
                "marca": marca,
                "modelo": modelo,
                "assentos": assentos_docs  # Assentos guardados dentro do veículo
            })
        
        if documentos:
            self.mongo_db.veiculos.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} veículos com {total_assentos} assentos", "OK")
        return len(documentos)
    
    def migrar_passageiros(self):
        """Migra tabela Passenger -> coleção passageiros"""
        self.mostrar("Migrando passageiros...")
        
        self.pg_cursor.execute("""
            SELECT cpf, first_name, last_name, birthday, email, phone, type_passenger
            FROM passenger ORDER BY cpf
        """)
        passageiros = self.pg_cursor.fetchall()
        
        documentos = []
        for cpf, nome, sobrenome, data_nasc, email, telefone, tipo in passageiros:
            id_mongo = ObjectId()
            self.passageiros[cpf] = id_mongo
            
            documentos.append({
                "_id": id_mongo,
                "cpf": cpf.strip() if cpf else cpf,
                "nome": nome,
                "sobrenome": sobrenome,
                "data_nascimento": self.converter_data(data_nasc),
                "email": email,
                "telefone": telefone,
                "tipo": tipo
            })
        
        if documentos:
            self.mongo_db.passageiros.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} passageiros migrados", "OK")
        return len(documentos)
    
    def migrar_funcionarios(self):
        """Migra tabela Employee -> coleção funcionarios"""
        self.mostrar("Migrando funcionários...")
        
        self.pg_cursor.execute("""
            SELECT cpf, first_name, last_name, birthday, email, phone, role, n_license
            FROM employee ORDER BY cpf
        """)
        funcionarios = self.pg_cursor.fetchall()
        
        documentos = []
        for cpf, nome, sobrenome, data_nasc, email, telefone, cargo, licenca in funcionarios:
            id_mongo = ObjectId()
            self.funcionarios[cpf] = id_mongo
            
            documentos.append({
                "_id": id_mongo,
                "cpf": cpf.strip() if cpf else cpf,
                "nome": nome,
                "sobrenome": sobrenome,
                "data_nascimento": self.converter_data(data_nasc),
                "email": email,
                "telefone": telefone,
                "cargo": cargo,
                "numero_licenca": licenca
            })
        
        if documentos:
            self.mongo_db.funcionarios.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} funcionários migrados", "OK")
        return len(documentos)
    
    def migrar_horarios(self):
        """
        Migra Schedule + SeatOnSchedule + Ticket -> coleção horarios
        (com assentos e tickets dentro)
        """
        self.mostrar("Migrando horários...")
        
        self.pg_cursor.execute("""
            SELECT id, departure_time, arrival_time, travel_time, route_id
            FROM schedule ORDER BY id
        """)
        horarios = self.pg_cursor.fetchall()
        
        documentos = []
        total_tickets = 0
        
        for id_horario, saida, chegada, tempo_viagem, id_rota in horarios:
            id_mongo = ObjectId()
            self.horarios[id_horario] = id_mongo
            
            # Funcionários designados para este horário
            self.pg_cursor.execute("""
                SELECT employee_cpf FROM scheduleemployee WHERE schedule_id = %s
            """, (id_horario,))
            cpfs_funcionarios = [linha[0] for linha in self.pg_cursor.fetchall()]
            funcionarios_ids = [self.funcionarios.get(cpf) for cpf in cpfs_funcionarios if cpf in self.funcionarios]
            
            # Assentos disponíveis neste horário
            self.pg_cursor.execute("""
                SELECT sos.id, sos.seat_id, sos.is_available, s.seat_row, s.seat_column
                FROM seatonschedule sos
                JOIN seat s ON s.id = sos.seat_id
                WHERE sos.schedule_id = %s
            """, (id_horario,))
            assentos_horario = self.pg_cursor.fetchall()
            
            assentos_docs = []
            for id_sos, id_assento, disponivel, fileira, coluna in assentos_horario:
                # Tickets vendidos para este assento
                self.pg_cursor.execute("""
                    SELECT id, price, passenger_cpf
                    FROM ticket WHERE seat_on_schedule_id = %s
                """, (id_sos,))
                tickets = self.pg_cursor.fetchall()
                
                tickets_docs = []
                for id_ticket, preco, cpf_passageiro in tickets:
                    total_tickets += 1
                    tickets_docs.append({
                        "preco": float(preco) if preco else None,
                        "passageiro": self.passageiros.get(cpf_passageiro)
                    })
                
                assentos_docs.append({
                    "fileira": fileira.strip() if fileira else fileira,
                    "coluna": coluna.strip() if coluna else coluna,
                    "disponivel": disponivel,
                    "tickets": tickets_docs  # Tickets dentro de cada assento
                })
            
            documentos.append({
                "_id": id_mongo,
                "hora_saida": saida,
                "hora_chegada": chegada,
                "tempo_viagem": str(tempo_viagem),
                "rota": self.rotas.get(id_rota),
                "funcionarios": funcionarios_ids,
                "assentos": assentos_docs
            })
        
        if documentos:
            self.mongo_db.horarios.insert_many(documentos)
        self.mostrar(f"✓ {len(documentos)} horários com {total_tickets} tickets", "OK")
        return len(documentos)
    
    def criar_indices(self):
        """Cria índices para buscas rápidas"""
        self.mostrar("Criando índices...")
        
        # Índices únicos (não podem repetir)
        self.mongo_db.empresas.create_index("cnpj", unique=True)
        self.mongo_db.paradas.create_index("localizacao", unique=True)
        self.mongo_db.veiculos.create_index("placa", unique=True)
        self.mongo_db.passageiros.create_index("cpf", unique=True)
        self.mongo_db.passageiros.create_index("email", unique=True)
        self.mongo_db.funcionarios.create_index("cpf", unique=True)
        self.mongo_db.funcionarios.create_index("email", unique=True)
        
        # Índices normais (para buscas rápidas)
        self.mongo_db.empresas.create_index("nome")
        self.mongo_db.rotas.create_index([("origem", 1), ("destino", 1)])
        self.mongo_db.horarios.create_index("rota")
        self.mongo_db.horarios.create_index("hora_saida")
        
        self.mostrar("✓ Índices criados", "OK")
    
    def executar(self):
        """Executa toda a migração passo a passo"""
        try:
            inicio = datetime.now()
            print("\n" + "="*60)
            print("🔄 MIGRAÇÃO: PostgreSQL → MongoDB")
            print("="*60)
            print(f"Início: {inicio.strftime('%Y-%m-%d %H:%M:%S')}\n")
            
            # 1. Limpar MongoDB
            self.limpar_mongodb()
            print()
            
            # 2. Migrar dados (em ordem de dependências)
            estatisticas = {}
            estatisticas['empresas'] = self.migrar_empresas()
            estatisticas['paradas'] = self.migrar_paradas()
            estatisticas['rotas'] = self.migrar_rotas()
            estatisticas['veiculos'] = self.migrar_veiculos()
            estatisticas['passageiros'] = self.migrar_passageiros()
            estatisticas['funcionarios'] = self.migrar_funcionarios()
            estatisticas['horarios'] = self.migrar_horarios()
            
            # 3. Criar índices
            print()
            self.criar_indices()
            
            # 4. Mostrar resumo
            fim = datetime.now()
            tempo = (fim - inicio).total_seconds()
            
            print("\n" + "="*60)
            print("📊 RESUMO")
            print("="*60)
            for colecao, quantidade in estatisticas.items():
                print(f"  • {colecao:15s}: {quantidade:4d} documentos")
            print(f"\n⏱️  Tempo: {tempo:.2f} segundos")
            print("="*60)
            print("✅ Migração concluída!\n")
            
        except Exception as erro:
            self.mostrar(f"Erro: {erro}", "ERRO")
            import traceback
            traceback.print_exc()
            raise
        finally:
            # Fechar conexões
            self.pg_cursor.close()
            self.pg_conn.close()
            self.mongo_client.close()


# === PONTO DE INÍCIO ===
if __name__ == "__main__":
    migrador = Migrador()
    migrador.executar()
