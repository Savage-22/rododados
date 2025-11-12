# 🚍 Guia Completo: Migração PostgreSQL → MongoDB com Docker

Este guia vai te ajudar a executar o projeto do zero, mesmo que você nunca tenha usado Docker antes.

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

### **Passo 2: Verificar os Arquivos**
Certifique-se de que existem estes arquivos principais:
- ✅ `docker-compose.yml`
- ✅ `db.sql`
- ✅ `seed_db.sql`
- ✅ `migracion/migrar.py`
- ✅ `migracion/Dockerfile`

### **Passo 3: Entender a Estrutura**
```
rododados/
├── docker-compose.yml    # Orquestra todos os containers
├── db.sql               # Esquema do PostgreSQL
├── seed_db.sql          # Dados iniciais
├── migracion/
│   ├── Dockerfile       # Imagem do migrador
│   ├── migrar.py        # Script de migração
│   └── requirements.txt # Dependências Python
├── newmodel/            # Novo modelo NoSQL
└── scripts/             # Scripts auxiliares
    ├── iniciar.sh       # Linux/Mac
    ├── iniciar.bat      # Windows
    ├── solo-migrar.sh   # Apenas migração (Linux/Mac)
    ├── solo-migrar.bat  # Apenas migração (Windows)
    ├── detener.sh       # Parar tudo (Linux/Mac)
    └── detener.bat      # Parar tudo (Windows)
```

---

## 🎯 Execução: Opção Simples (Recomendada)

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

**O que esse script faz?**
1. ✅ Inicia PostgreSQL e MongoDB
2. ✅ Aguarda 8 segundos para que estejam prontos
3. ✅ Executa a migração automaticamente
4. ✅ Mostra a URL do Mongo Express

---

## 🎯 Execução: Opção Manual (Passo a Passo)

Se você prefere entender cada passo:

### **1. Iniciar os Bancos de Dados**
```bash
docker-compose up -d postgres mongodb mongo-express
```

**O que isso faz?**
- Baixa as imagens do Docker (apenas na primeira vez)
- Inicia 3 containers:
  - `postgres`: Banco PostgreSQL com os dados iniciais
  - `mongodb`: Banco MongoDB (vazio, pronto para receber dados)
  - `mongo-express`: Interface web para visualizar o MongoDB

**Aguarde ~10 segundos** para que os bancos iniciem completamente.

### **2. Executar a Migração**
```bash
docker-compose up migrator
```

**O que acontece?**
- Conecta no PostgreSQL
- Lê todos os dados das tabelas
- Transforma e insere no MongoDB
- Mostra logs do progresso

### **3. Verificar os Dados Migrados**

Abra seu navegador em: **http://localhost:8081**

**Credenciais do Mongo Express:**
- Usuário: `admin`
- Senha: `pass123`

Você verá:
- Database: `rododados`
- Collections: `linhas`, `paraderos`, `onibus`, `viagens`, etc.

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

### **Re-executar apenas a migração:**
```bash
docker-compose up migrator
```

Ou use o script:
- **Windows**: `scripts\solo-migrar.bat`
- **Linux/Mac**: `./scripts/solo-migrar.sh`

### **Limpar tudo e começar do zero:**
```bash
docker-compose down -v          # Remove containers e volumes
docker-compose up -d postgres mongodb mongo-express
docker-compose up migrator
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

## 🐛 Solução de Problemas

### **Erro: "port is already allocated"**
**Problema:** Outra aplicação está usando a porta.

**Solução:**
```bash
docker-compose down
# Encontre o processo usando a porta
sudo lsof -i :5432  # PostgreSQL
sudo lsof -i :27017 # MongoDB
sudo lsof -i :8081  # Mongo Express
# Mate o processo ou mude a porta no docker-compose.yml
```

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

## 📊 Estrutura dos Dados

### **PostgreSQL (Modelo Relacional)**
```
linhas → onibus → viagens → paraderos
```

### **MongoDB (Modelo NoSQL)**
Documentos com estruturas aninhadas:
- `linhas`: Informações das linhas de ônibus
- `paraderos`: Paradas com localização geográfica
- `onibus`: Frota de veículos
- `viagens`: Histórico de viagens com referências

---

## 📝 Próximos Passos

Após a migração bem-sucedida:

1. **Explore os dados** no Mongo Express (http://localhost:8081)
2. **Execute queries** no MongoDB Shell
3. **Teste as views e triggers** (verifique `newmodel/views.sql` e `newmodel/triggers.sql`)
4. **Execute consultas de busca** (veja `newmodel/search_queries.sql`)

---

## 👥 Contribuindo

Se encontrar problemas ou tiver sugestões:
1. Abra uma issue no GitHub
2. Faça um fork e envie um Pull Request

---

## 📄 Licença

Este projeto é parte de um trabalho acadêmico da disciplina MC536.

---

## 🆘 Precisa de Ajuda?

Se algo não funcionar:
1. Verifique os logs: `docker-compose logs`
2. Certifique-se de que o Docker está rodando
3. Tente limpar tudo: `docker-compose down -v` e comece novamente

**Boa migração! 🚀**
