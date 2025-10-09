# 🚍 Guia Rápido: Configuração do Banco de Dados Rododados

Este guia mostra como configurar e popular o banco de dados do zero.

---

### ✅ Passo 0: Pré-requisitos

Você precisa ter **PostgreSQL** e **Python 3.7+** instalados.

<details>
<summary>Clique aqui para ver como verificar as versões</summary>

**Para verificar o PostgreSQL:**
Abra seu terminal e execute:
```bash
psql --version
```

**Para verificar o Python:**
```bash
# Em Windows
py --version

# Em macOS / Linux
python3 --version
```
</details>

---

### 🚀 Passo a Passo

#### 1. Clonar o Repositório
```bash
git clone https://github.com/Savage-22/rododados.git
cd rododados/newmodel
```

#### 2. Criar o Banco de Dados
```bash
# 1. Entre no psql (use seu usuário do PostgreSQL, 'postgres' é o padrão)
psql -U postgres

# 2. Crie o banco de dados e saia
CREATE DATABASE rododados;
\q
```

#### 3. Criar a Estrutura do Banco (Tabelas, Views, Triggers)
Use seu cliente de banco de dados preferido (DBeaver, DataGrip, etc.) ou o próprio `psql` para executar os seguintes arquivos **nesta ordem**:

1.  `new_model.sql` - Cria todas as tabelas.
2.  `triggers.sql` - Cria as funções e os gatilhos.
3.  `views.sql` - Cria as views para consulta.

#### 4. Configurar o Ambiente Python
```bash
# 1. Crie e ative um ambiente virtual
# Em macOS / Linux
python3 -m venv venv
source venv/bin/activate

# Em Windows (cmd)
python -m venv venv
venv\Scripts\activate

# 2. Instale as dependências
pip install -r injection/requirements.txt
```

#### 5. Configurar a Conexão
Abra o arquivo `injection/datas_injection.py` e edite o dicionário `DB_CONFIG` com seu usuário e senha do PostgreSQL.

```python
# Linhas 11-17 em injection/datas_injection.py
DB_CONFIG = {
    'host': 'localhost',
    'database': 'rododados',
    'user': 'seu_usuario',      # <-- MUDE AQUI
    'password': 'sua_senha',    # <-- MUDE AQUI
    'port': 5432
}
```

#### 6. Testar a Conexão
Execute o script de teste para garantir que tudo está correto.
```bash
python3 injection/test_connection.py
```
A saída esperada é:
> ✅ Conexão bem-sucedida!
> 📋 17 tabelas encontradas no banco de dados `rododados`.

#### 7. Inserir os Dados (Popular o Banco)
Agora, execute o script principal para encher o banco com dados fictícios.
```bash
python3 injection/datas_injection.py
```
Aguarde a conclusão. O script irá gerar milhares de registros.

---

### 🤔 Verificação e Solução de Problemas

**Para verificar se os dados foram inseridos:**
Conecte-se ao banco `rododados` e execute uma consulta simples:
```sql
SELECT * FROM Company;
-- ou
SELECT * FROM vw_ticket_details LIMIT 5;
```

**Se algo deu errado e você quer começar de novo:**
Use o script `clean_database.py` para apagar todos os dados. Depois, volte para o **Passo 3**.
```bash
# Certifique-se que a configuração em datas_injection.py está correta
python3 injection/clean_database.py
```

🎉 **Pronto! Seu ambiente está configurado.**