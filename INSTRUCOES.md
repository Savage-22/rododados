# Sistema de Transporte Rodoviário 🚍

## 📋 Pré-requisitos

- PostgreSQL instalado e rodando
- Python 3.7+
- Git (para clonar o repositório)

## 🚀 Passo a Passo

### Clonar o Repositório

```bash
git clone https://github.com/Savage-22/rododados.git
cd rododados
```

### Criar o Banco de Dados

```bash
# Entrar no PostgreSQL (ajuste o usuário conforme necessário)
psql -U postgres

# Criar o banco
CREATE DATABASE rododados;

# Criar usuário (opcional, se não existir)
CREATE USER <> WITH PASSWORD '';
GRANT ALL PRIVILEGES ON DATABASE rododados TO <>;

# Sair
\q

### Configurar Python (Ambiente Virtual)

```bash
# Criar ambiente virtual
python3 -m venv venv

# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

### Configurar Conexão

Edite o arquivo `datas_injection.py` (linhas 15-21) e ajuste os dados de conexão:

```python
DB_CONFIG = {
    'host': 'localhost',
    'database': 'rododados',
    'user': '',      # Seu usuário PostgreSQL
    'password': '',     # Sua senha
    'port': 5432
}
```

### Testar Conexão

```bash
python3 test_connection.py
```

Você deve ver:
```
✅ Conexão bem-sucedida!
📋 17 tabelas encontradas no banco de dados
```

### Popular o Banco de Dados

```bash
python3 datas_injection.py
```

Isso irá criar:
- 5 empresas de transporte
- 30 paradas de ônibus
- 10 rotas
- 15 veículos
- 50 passageiros (15 estudantes)
- 20 funcionários (motoristas e vendedores)
- ~300 viagens
- Milhares de tickets

## 🔍 Consultas Úteis

### Ver todas as empresas
```sql
SELECT * FROM Company;
```

### Ver viagens de hoje
```sql
SELECT * FROM vw_trip_details 
WHERE trip_date = CURRENT_DATE;
```

### Ver tickets vendidos
```sql
SELECT * FROM vw_ticket_details 
LIMIT 10;
```

### Ver ocupação das viagens
```sql
SELECT 
    route_name,
    trip_date,
    total_capacity,
    available_capacity,
    ROUND((total_capacity - available_capacity)::NUMERIC / total_capacity * 100, 2) as ocupacao_pct
FROM vw_trip_details
WHERE trip_status = 'scheduled'
ORDER BY trip_date;
```

## ⚠️ Problemas Comuns

### Erro de conexão
- Verifique se o PostgreSQL está rodando: `sudo service postgresql status`
- Verifique usuário e senha no `datas_injection.py`

### Erro ao instalar psycopg2
```bash
pip install --upgrade psycopg2-binary
```

### Limpar e recomeçar
```bash
pyhton3 clean_database.py

# Popular novamente
python3 datas_injection.py
```

## � Estrutura do Projeto

```
rododados/
├── new:model.sql          # Definição das tabelas
├── views.sql              # Views do sistema
├── triggers.sql           # Triggers e funções
├── datas_injection.py     # Script para popular o banco
├── clean_database.py      # Limpa o banco
├── test_connection.py     # Script de teste de conexão
├── requirements.txt       # Dependências Python
└── INSTRUCOES.md         # Este arquivo
```

## 🎉 Pronto!

Seu banco de dados está configurado e populado com dados realistas
