# 🚍 RodoDados - Sistema de Transporte Público: SQL vs NoSQL

## 📖 Sobre o Projeto

Este projeto implementa um **sistema completo de gerenciamento de transporte público** usando **duas abordagens de banco de dados**:

### 🗄️ **Modelo Relacional (PostgreSQL)**
- Estrutura normalizada com tabelas relacionadas
- Integridade referencial com foreign keys
- Ideal para consultas complexas com JOINs
- **Explore:** Triggers, Views, Stored Procedures

### 📦 **Modelo NoSQL (MongoDB)**
- Documentos aninhados e flexíveis
- Desnormalização intencional
- Ideal para escalabilidade e consultas rápidas
- **Explore:** Agregações, Índices Geoespaciais, Queries complexas

---

## 🎯 O Que Você Pode Fazer Com Este Projeto

### 1️⃣ **Explorar o Modelo SQL**
- ✅ Ver o esquema de banco de dados relacional (`db.sql`)
- ✅ Analisar as relações entre tabelas
- ✅ Executar queries SQL complexas
- ✅ Testar triggers e views

### 2️⃣ **Explorar o Modelo NoSQL** (Opcional)
- ✅ Ver a transformação dos dados para documentos
- ✅ Comparar a estrutura com o modelo SQL
- ✅ Executar agregações no MongoDB
- ✅ Testar queries geoespaciais

### 3️⃣ **Comparar Ambos Modelos**
- 📊 Performance de consultas
- 🔄 Complexidade de queries
- 📈 Escalabilidade
- 💾 Uso de espaço

---

## 🚀 Guia de Início Rápido

**Este guia te ajuda a:**
1. Levantar o banco PostgreSQL com dados reais
2. (Opcional) Migrar para MongoDB para comparação
3. Explorar ambos os modelos através de interfaces web

**Tempo estimado:** 10-15 minutos (primeira vez) | 2-3 minutos (execuções seguintes)

**Pré-requisitos:**
- ✅ Docker instalado
- ✅ PostgreSQL e MongoDB locais **desativados** (importante!)
- ✅ 10 GB de espaço livre no disco

---

## 📋 Dados do Sistema

O projeto modela um sistema real de transporte público com:

- 🚌 **Linhas de Ônibus:** Rotas, horários, tarifas
- 📍 **Paraderos (Paradas):** Localização geográfica, nome, código
- 🚍 **Frota de Ônibus:** Veículos, capacidade, status
- 🛣️ **Viagens:** Histórico de viagens, motoristas, horários
- 👥 **Passageiros e Motoristas:** Dados pessoais e operacionais

**Objetivo:** Comparar como esses dados são estruturados e consultados em SQL vs NoSQL.

---

## 🎮 Formas de Usar Este Projeto

Escolha o caminho que mais se adequa aos seus objetivos:

### **Caminho 1: 🗄️ Apenas SQL** (Foco em Banco Relacional)
```bash
docker-compose up -d postgres
```
✅ Rápido e simples  
✅ Explora apenas o modelo relacional  
✅ Ideal para estudar SQL, triggers, views  

---

### **Caminho 2: 🔄 SQL + NoSQL** (Comparação Completa)
```bash
./scripts/iniciar.sh    # Linux/Mac
scripts\iniciar.bat     # Windows
```
✅ Experiência completa  
✅ Compara ambos os paradigmas  
✅ Ideal para o projeto completo da disciplina  

---

### **Caminho 3: 🧪 Customizado** (Controle Total)
```bash
docker-compose up -d postgres        # Só PostgreSQL
docker-compose up -d mongodb         # Adicionar MongoDB
docker-compose up migrator           # Migrar quando quiser
```
✅ Controle total sobre cada etapa  
✅ Perfeito para experimentação  
✅ Entender cada componente  

---

## 📋 Pré-requisitos

Antes de começar, você precisa ter instalado:

### 1. **Docker Desktop**
- **Windows/Mac**: Baixe em [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- **Linux**: 
  ```bash
  sudo apt-get update
  sudo apt-get install docker.io docker-compose
  ```

**Verifique a instalação:**
```bash
docker --version
docker-compose --version
```

### 2. **Git** (para clonar o repositório)
```bash
git --version
```

---

## 🚀 Passos para Executar o Projeto

### **Passo 1: Clonar o Repositório**
```bash
git clone https://github.com/Savage-22/rododados.git
cd rododados
```

**✅ Você está pronto para continuar!** Agora siga os próximos passos.

### **Passo 2: Verificar os Arquivos**
Certifique-se de que existem estes arquivos principais:
- ✅ `docker-compose.yml`
- ✅ `db.sql`
- ✅ `seed_db.sql`
- ✅ `migracion/migrar.py`
- ✅ `migracion/Dockerfile`

### **Passo 3: ⚠️ IMPORTANTE - PostgreSQL e MongoDB Locales

**¡Buenas noticias!** Los scripts de iniciar (`iniciar.sh` / `iniciar.bat`) **detectan y detienen automáticamente** PostgreSQL y MongoDB si están corriendo localmente.

**Esto significa:**
- ✅ No necesitas hacer nada manualmente
- ✅ El script verifica y libera las portas 5432 y 27017
- ✅ Si hay conflictos, los resuelve automáticamente

**Pero si prefieres hacerlo manualmente antes:**

#### **No Linux/Mac:**
```bash
# Parar PostgreSQL
sudo systemctl stop postgresql
# ou (dependendo da instalação)
sudo service postgresql stop

# Parar MongoDB
sudo systemctl stop mongod
# ou
sudo service mongod stop
```

#### **No Windows:**
1. Abra **Serviços** (pressione `Win + R`, digite `services.msc`)
2. Procure por **PostgreSQL** e **MongoDB**
3. Clique com botão direito → **Parar**

**Nota:** Los scripts de iniciar hacen esto automáticamente, por lo que este paso manual es **OPCIONAL**.

### **Passo 4: Entender a Estrutura**
```
rododados/
├── 📊 MODELO SQL (PostgreSQL)
│   ├── db.sql               # ⭐ Esquema completo (CREATE TABLE, FK, etc.)
│   └── seed_db.sql          # ⭐ Dados iniciais (milhares de registros)
│
├── 📦 MODELO NoSQL (MongoDB) - Explorar após migração
│   └── newmodel/
│       ├── INSTRUCOES.md        # 📖 Documentação do modelo NoSQL
│       ├── new_model.sql        # Descrição do modelo de documentos
│       ├── views.sql            # Views adaptadas para MongoDB
│       ├── triggers.sql         # Lógica de triggers no NoSQL
│       ├── search_queries.sql   # ⭐ Queries de exemplo (SQL vs NoSQL)
│       └── DIAGRAMA_NOSQL.md    # Visualização do modelo
│
├── 🔄 MIGRAÇÃO (SQL → NoSQL)
│   └── migracion/
│       ├── migrar.py            # ⭐ Script de transformação
│       ├── Dockerfile           # Container do migrador
│       └── requirements.txt     # Dependências Python
│
├── 🐳 INFRAESTRUTURA
│   ├── docker-compose.yml   # ⭐ Orquestra todos os containers
│   └── scripts/             # Scripts auxiliares
│       ├── iniciar.sh           # Inicia tudo (Linux/Mac)
│       ├── iniciar.bat          # Inicia tudo (Windows)
│       ├── solo-migrar.sh       # Apenas migração
│       ├── solo-migrar.bat      # Apenas migração (Windows)
│       ├── detener.sh           # Para e limpa tudo
│       └── detener.bat          # Para e limpa (Windows)
│
└── 📖 DOCUMENTAÇÃO
    └── README.md            # Este arquivo

⭐ = Arquivos principais para explorar
```

---

## 🎯 Execução: Opção Simples (Recomendada)

### **Opção A: Solo PostgreSQL (Explorar Modelo SQL)**

Se você quer apenas explorar o modelo relacional:

```bash
docker-compose up -d postgres
```

**Acesso:**
- Host: `localhost:5432`
- Database: `rododados`
- User: `postgres`
- Password: `postgres`

**Use um cliente SQL:** DBeaver, pgAdmin, ou `psql`

---

### **Opção B: PostgreSQL + MongoDB (Comparar Ambos Modelos)**

Se você quer explorar e comparar SQL vs NoSQL:

### **No Windows:**
1. Abra o **PowerShell** ou **CMD** na pasta do projeto
2. Execute:
   ```batch
   scripts\iniciar.bat
   ```

### **No Linux/Mac:**
1. Abra o **Terminal** na pasta do projeto
2. Dê permissões de execução:
   ```bash
   chmod +x scripts/iniciar.sh
   ```
3. Execute:
   ```bash
   ./scripts/iniciar.sh
   ```

### **Opção B: PostgreSQL + MongoDB (Comparar Ambos Modelos)**

Se você quer explorar e comparar SQL vs NoSQL:

#### **No Windows:**
1. Abra o **PowerShell** ou **CMD** na pasta do projeto
2. Execute:
   ```batch
   scripts\iniciar.bat
   ```

#### **No Linux/Mac:**
1. Abra o **Terminal** na pasta do projeto
2. Dê permissões de execução:
   ```bash
   chmod +x scripts/iniciar.sh
   ```
3. Execute:
   ```bash
   ./scripts/iniciar.sh
   ```

---

### 📊 **O Que Acontece Quando Você Executa o Script:**

#### **Fase 0: Preparación Automática (NUEVO!)**

0. 🛑 **Detiene PostgreSQL y MongoDB locales automáticamente**
   - Verifica si están corriendo en tu computador
   - Detiene los servicios automáticamente (systemctl/brew/net stop)
   - Libera las portas 5432 y 27017 si están ocupadas
   - **¡No necesitas hacer nada manualmente!**

#### **Fase 1: Preparación del PostgreSQL (Base de Datos SQL)**

1. ✅ **Crea el container PostgreSQL**
2. ✅ **Executa `db.sql`:** Cria o esquema relacional
   - Tabelas: `linhas`, `paraderos`, `onibus`, `viagens`, `motoristas`, `passageiros`, etc.
   - Foreign keys, constraints, índices
3. ✅ **Executa `seed_db.sql`:** Insere dados reais AUTOMATICAMENTE
   - **Milhares de registros** de transporte público já prontos!
   - **Não precisa executar scripts Python da pasta `injection/`** - isso é OPCIONAL
4. ✅ **PostgreSQL está PRONTO para ser explorado com dados reais!**

#### **Fase 2: Preparação do MongoDB (Base de Dados NoSQL)** - OPCIONAL

5. ✅ **Cria o container MongoDB** (vazio inicialmente)
6. ✅ **Cria o Mongo Express** (interface web)
7. ⏳ **Aguarda 8 segundos** para estabilização

#### **Fase 3: Migração (Transformação SQL → NoSQL)** - OPCIONAL

8. ✅ **Executa `migrar.py`:**
   - Lê os dados do PostgreSQL (modelo relacional)
   - Transforma para o modelo NoSQL (documentos aninhados)
   - Insere no MongoDB
9. 🎉 **MongoDB está PRONTO para comparação!**

---

### � **Acessar as Interfaces:**

**PostgreSQL:**
- Use um cliente SQL (DBeaver, pgAdmin, TablePlus)
- Ou via terminal: `docker exec -it rododados-postgres-1 psql -U postgres -d rododados`

**MongoDB (se migrou):**
- Interface Web: **http://localhost:8081**
- Usuário: `admin` | Senha: `pass123`
- Ou via terminal: `docker exec -it rododados-mongodb-1 mongosh rododados`

---

## 🎯 Execução: Opção Manual (Passo a Passo)

Se você prefere entender cada passo ou quer **apenas PostgreSQL**:

### **1. Iniciar Apenas o PostgreSQL (Modelo SQL)**
```bash
docker-compose up -d postgres
```

**Pronto!** Agora você pode explorar o modelo relacional.

### **2. (Opcional) Adicionar MongoDB para Comparação**
```bash
docker-compose up -d mongodb mongo-express
```

**Aguarde ~10 segundos** para que os bancos iniciem completamente.

### **3. (Opcional) Executar a Migração SQL → NoSQL**
```bash
docker-compose up migrator
```

**O que acontece?**
- Conecta no PostgreSQL
- Lê todos os dados das tabelas
- Transforma e insere no MongoDB
- Mostra logs do progresso

### **4. Explorar os Dados**

**PostgreSQL:**
```bash
docker exec -it rododados-postgres-1 psql -U postgres -d rododados
```

**MongoDB (se migrou):**
- Abra: **http://localhost:8081**
- Credenciais: `admin` / `pass123`

---

## 🔍 Explorando o Projeto

### **📂 Arquivos Importantes:**

#### **Modelo SQL (PostgreSQL):**
- 📄 `db.sql` - **Esquema completo** (CREATE TABLE, constraints, foreign keys)
- 📄 `seed_db.sql` - **Dados iniciais reais** (INSERT statements automáticos)
  - ⚠️ **Estes dados são inseridos AUTOMATICAMENTE ao iniciar o PostgreSQL via Docker**
  - Não precisa executar nada manualmente!

#### **Modelo NoSQL (MongoDB):**
- 📁 `newmodel/` - Novo modelo NoSQL
  - 📄 `new_model.sql` - Descrição do modelo de documentos
  - 📄 `views.sql` - Views equivalentes no MongoDB
  - 📄 `triggers.sql` - Lógica de triggers adaptada
  - 📄 `search_queries.sql` - Queries de exemplo
  - 📄 `INSTRUCOES.md` - Documentação do modelo NoSQL
  - 📁 `injection/` - **Scripts Python para gerar dados FAKE adicionais** (opcional)
    - ⚠️ **NÃO usado no Docker automático**
    - Use apenas se quiser adicionar mais dados de teste manualmente

#### **Migração:**
- 📁 `migracion/`
  - 📄 `migrar.py` - Script de transformação SQL → NoSQL
  - 📄 `Dockerfile` - Container do migrador

#### **Diagramas:**
- 📄 `DIAGRAMA_NOSQL.md` - Visualização do modelo NoSQL

---

## 💡 Casos de Uso

### **Para Estudantes:**
- 📚 Aprender diferenças entre SQL e NoSQL
- 🔬 Experimentar com queries em ambos modelos
- 📊 Comparar performance e complexidade

### **Para Professores:**
- 🎓 Demonstrar modelagem relacional vs documental
- 🧪 Exercícios práticos de migração
- 📈 Análise de trade-offs

### **Para Desenvolvedores:**
- 🛠️ Template para projetos de migração
- 🐳 Exemplo de Docker Compose multi-database
- 🔄 Padrões de transformação de dados

---

## 🛠️ Comandos Úteis

### **Ver logs dos containers:**
```bash
docker-compose logs postgres    # Logs do PostgreSQL
docker-compose logs mongodb     # Logs do MongoDB
docker-compose logs migrator    # Logs da migração
```

### **Parar todos os containers:**
```bash
docker-compose down
```

Ou use o script:
- **Windows**: `scripts\detener.bat`
- **Linux/Mac**: `./scripts/detener.sh`

**⚠️ IMPORTANTE:** Para **limpar completamente** (sem deixar arquivos basura):
```bash
docker-compose down -v
```

O parâmetro `-v` remove também os **volumes** (dados armazenados). Use isso quando:
- ❌ Quiser começar do zero
- ❌ Os dados estiverem corrompidos
- ❌ Quiser liberar espaço no disco

**Diferença:**
- `docker-compose down` → Para os containers (dados persistem)
- `docker-compose down -v` → Para tudo e **apaga os dados** (recomendado para limpeza total)

### **Re-executar apenas a migração:**

**Quando usar:** Se você já tem os bancos rodando e só quer migrar novamente.

```bash
docker-compose up migrator
```

Ou use o script:
- **Windows**: `scripts\solo-migrar.bat`
- **Linux/Mac**: `./scripts/solo-migrar.sh`

**💡 Nota:** Isso assume que PostgreSQL e MongoDB já estão rodando.

### **Limpar tudo e começar do zero:**
```bash
docker-compose down -v          # Remove containers e volumes (LIMPIEZA TOTAL)
docker-compose up -d postgres mongodb mongo-express
# Aguardar ~10 segundos
docker-compose up migrator
```

**Ou use o script de iniciar novamente:**
```bash
./scripts/iniciar.sh  # Linux/Mac
scripts\iniciar.bat   # Windows
```

### **Entrar no container PostgreSQL:**
```bash
docker exec -it rododados-postgres-1 psql -U postgres -d rododados
```

### **Entrar no container MongoDB:**
```bash
docker exec -it rododados-mongodb-1 mongosh rododados
```

---

---

## ❓ Perguntas Frequentes (FAQ)

### **1. Os dados são inseridos automaticamente no PostgreSQL?**
✅ **SIM!** Quando você inicia o Docker, o PostgreSQL:
1. Executa `db.sql` (cria as tabelas)
2. Executa `seed_db.sql` (insere os dados)
3. Tudo automático, **você não precisa fazer nada!**

### **2. Para que serve a pasta `newmodel/injection/`?**
📁 Contém scripts Python para **gerar dados FAKE adicionais** (usando biblioteca Faker).
- ⚠️ **NÃO é usada automaticamente pelo Docker**
- Use apenas se quiser adicionar mais dados de teste manualmente
- Útil para testes de carga ou experimentação

### **3. Preciso executar scripts Python para ter dados?**
❌ **NÃO!** Os dados já estão em `seed_db.sql` e são inseridos automaticamente.
- Scripts Python em `injection/` são **opcionais** para dados extras

### **4. Como sei que os dados foram inseridos?**
🔍 Conecte ao PostgreSQL e execute:
```sql
SELECT COUNT(*) FROM linhas;
SELECT COUNT(*) FROM onibus;
SELECT COUNT(*) FROM viagens;
```
Você verá milhares de registros! ✅

### **5. A migração para MongoDB é obrigatória?**
❌ **NÃO!** A migração é **opcional**.
- Você pode trabalhar apenas com PostgreSQL
- Migre para MongoDB **só se quiser comparar** os modelos

### **6. Os scripts param automaticamente o PostgreSQL/MongoDB local?**
✅ **SIM!** Os scripts `iniciar.sh` e `iniciar.bat` agora:
- Detectam se PostgreSQL ou MongoDB estão rodando localmente
- Param os serviços automaticamente
- Liberam as portas 5432 e 27017
- **Você não precisa fazer nada manualmente!**

### **7. Como adiciono mais dados além dos que vêm no `seed_db.sql`?**
Você tem 3 opções:
1. **Manualmente:** Conecte ao PostgreSQL e execute INSERT statements
2. **Scripts Python:** Use `newmodel/injection/datas_injection.py`
3. **Modifique `seed_db.sql`:** Adicione mais INSERT statements

---

## 🐛 Solução de Problemas

### **Erro: "port is already allocated"**
**Problema:** PostgreSQL ou MongoDB estão rodando localmente.

**Solução Automática (Recomendado):**
```bash
# Os scripts de iniciar JÁ fazem isso automaticamente!
./scripts/iniciar.sh    # Linux/Mac
scripts\iniciar.bat     # Windows
```

**Solução Manual (se o automático falhar):**
```bash
# OPÇÃO 1: Parar os serviços locais
sudo systemctl stop postgresql
sudo systemctl stop mongod

# OPÇÃO 2: Encontrar e matar os processos
sudo lsof -ti :5432  # PostgreSQL
sudo lsof -ti :27017 # MongoDB
# Depois: kill -9 <PID>
```

**💡 Nota:** A partir de agora, os scripts de iniciar **resolvem isso automaticamente**!

### **Erro: "Cannot connect to the Docker daemon"**
**Problema:** Docker não está rodando.

**Solução:**
- No Windows/Mac: Abra o Docker Desktop
- No Linux: `sudo systemctl start docker`

### **Erro: "connection refused" durante a migração**
**Problema:** Os bancos ainda não estão prontos.

**Solução:** Aguarde mais tempo antes de executar o migrador:
```bash
docker-compose up -d postgres mongodb mongo-express
sleep 15  # Aguarda 15 segundos
docker-compose up migrator
```

### **Os dados não aparecem no MongoDB**
**Verificações:**
1. Confira os logs: `docker-compose logs migrator`
2. Verifique se o PostgreSQL tem dados: 
   ```bash
   docker exec -it rododados-postgres-1 psql -U postgres -d rododados -c "SELECT COUNT(*) FROM linhas;"
   ```
3. Re-execute a migração: `docker-compose up migrator`

---

## 📊 Flujo de Dados: ¿Cómo Funciona?

### **Arquitectura del Sistema:**

```
┌─────────────────────────────────────────────────────────┐
│  FASE 1: MODELO RELACIONAL (PostgreSQL)                │
│  ─────────────────────────────────────────────          │
│  1. Docker crea container PostgreSQL                    │
│  2. db.sql → Crea tablas (CREATE TABLE...)             │
│  3. seed_db.sql → INSERT automático (datos reales)     │
│     ↳ Milhares de registros já prontos!                 │
│     ↳ NÃO precisa executar scripts Python!              │
│  ✅ BASE SQL PRONTA PARA EXPLORAR                       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│  (OPCIONAL) Scripts Python em newmodel/injection/      │
│  ────────────────────────────────────────────────────   │
│  • datas_injection.py → Gera dados FAKE extras (Faker)  │
│  • Uso: Apenas se quiser MAIS dados de teste            │
│  • Conexão: localhost (fora do Docker)                  │
│  ⚠️  NÃO usado automaticamente!                         │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│  FASE 2 (OPCIONAL): COMPARAÇÃO COM NoSQL               │
│  ─────────────────────────────────────────────────     │
│  4. Docker crea container MongoDB (vacío)               │
│  5. migrar.py (Python) transforma:                      │
│     • Lê dados do PostgreSQL (seed_db.sql)              │
│     • Tablas relacionadas → Documentos aninhados        │
│     • Foreign Keys → Referencias/Embedding              │
│     • JOINs → Agregações                                │
│  ✅ BASE NoSQL PRONTA PARA COMPARAR                     │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│  EXPLORAÇÃO E ANÁLISE                                   │
│  ────────────────────────                               │
│  • Queries SQL vs Agregações MongoDB                    │
│  • Performance                                           │
│  • Complexidade                                          │
│  • Trade-offs                                            │
└─────────────────────────────────────────────────────────┘
```

**Importante:** 
- ✅ `seed_db.sql` → Dados inseridos **AUTOMATICAMENTE** no PostgreSQL (via Docker)
- ⚠️ `newmodel/injection/*.py` → Scripts **OPCIONAIS** para dados extras (execução MANUAL)

---

## 📊 Estrutura dos Dados

### **PostgreSQL (Modelo Relacional)**
```sql
-- Tabelas principais com relacionamentos
linhas (id_linha, nome, tarifa, ...) 
    ↓ 1:N
onibus (id_onibus, id_linha, placa, ...)
    ↓ 1:N  
viagens (id_viagem, id_onibus, id_motorista, ...)
    ↓ N:M
paraderos (id_paradero, nome, latitud, longitud, ...)
```

**Características:**
- ✅ Normalizado (evita redundância)
- ✅ Integridade referencial
- ✅ Queries com JOINs
- ❌ Múltiplas tabelas por consulta

### **MongoDB (Modelo NoSQL)** - Após Migração

```javascript
// Documentos aninhados e desnormalizados
{
  _id: ObjectId("..."),
  linha: "Linha 100 - Centro",
  tarifa: 4.50,
  onibus: [  // Embedded
    {
      placa: "ABC-1234",
      viagens: [...]  // Nested
    }
  ],
  paraderos: [  // Referências ou Embedded
    { nome: "Terminal Central", coords: [lat, lng] }
  ]
}
```

**Características:**
- ✅ Queries rápidas (um documento tem tudo)
- ✅ Escalabilidade horizontal
- ✅ Flexibilidade de schema
- ❌ Possível redundância de dados

---

## 🔬 Queries de Exemplo

### **SQL (PostgreSQL):**
```sql
-- Buscar viagens de uma linha específica
SELECT v.*, o.placa, m.nome as motorista
FROM viagens v
JOIN onibus o ON v.id_onibus = o.id_onibus
JOIN motoristas m ON v.id_motorista = m.id_motorista
JOIN linhas l ON o.id_linha = l.id_linha
WHERE l.nome = 'Linha 100';
```

### **NoSQL (MongoDB):**
```javascript
// Mesma consulta, mais simples
db.linhas.find(
  { "nome": "Linha 100" },
  { "onibus.viagens": 1, "onibus.placa": 1 }
)
```

**📂 Mais exemplos em:** `newmodel/search_queries.sql`

---

## 📝 Próximos Passos

Após executar o projeto, você pode:

### **🔍 Explorar o PostgreSQL:**
1. Conectar com um cliente SQL (DBeaver, pgAdmin)
2. Analisar o esquema (`db.sql`)
3. Executar queries complexas
4. Modificar dados e ver triggers em ação
5. Criar suas próprias views

### **🔍 Explorar o MongoDB** (se migrou):
1. Acessar Mongo Express (http://localhost:8081)
2. Comparar a estrutura com o PostgreSQL
3. Executar agregações (`newmodel/search_queries.sql`)
4. Testar índices geoespaciais
5. Modificar documentos e ver a flexibilidade

### **📊 Comparar e Analisar:**
1. Executar a mesma query em SQL e NoSQL
2. Medir performance
3. Analisar complexidade das queries
4. Documentar trade-offs
5. Decidir qual modelo é melhor para cada caso de uso

### **🧪 Experimentar:**
1. Adicionar novos dados
2. Criar novos relacionamentos
3. Testar cenários de alta carga
4. Modificar o esquema

---

---

## 📄 Licença e Contexto Académico

Este projeto foi desenvolvido como trabalho da disciplina **MC536 - Bancos de Dados: Teoria e Prática** da Unicamp.

**Objetivos do Projeto:**
- 🎯 Implementar um sistema completo em modelo relacional
- 🎯 Transformar para modelo NoSQL
- 🎯 Comparar abordagens
- 🎯 Analisar trade-offs entre SQL e NoSQL
- 🎯 Demonstrar proficiência em ambos paradigmas

**Autores:** [Seus nomes aqui]

---

## 🆘 Precisa de Ajuda?

### **Problemas Comuns:**

**❌ "Port already allocated"**
→ PostgreSQL/MongoDB locais rodando. Veja seção de troubleshooting.

**❌ "Cannot connect to Docker daemon"**
→ Docker Desktop não está rodando.

**❌ "Migration failed"**
→ Aguarde mais tempo antes de migrar (PostgreSQL pode não estar pronto).

### **Suporte:**
1. Verifique os logs: `docker-compose logs`
2. Certifique-se de que o Docker está rodando
3. Tente limpar tudo: `docker-compose down -v` e comece novamente
4. Consulte a seção **🐛 Solução de Problemas** acima

---

## 🌟 Recursos Adicionais

- 📖 [Documentação PostgreSQL](https://www.postgresql.org/docs/)
- 📖 [Documentação MongoDB](https://docs.mongodb.com/)
- 🐳 [Docker Compose](https://docs.docker.com/compose/)
- 📚 [SQL vs NoSQL](https://www.mongodb.com/nosql-explained/nosql-vs-sql)

**Boa exploração! 🚀**
