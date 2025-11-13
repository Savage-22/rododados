## 🔌 Conectarse a MongoDB

### Opción 1: Terminal (mongosh)
```bash
docker exec -it rododados_mongodb mongosh rododados_mongo
```

### Opción 2: Interfaz Web (Mongo Express)
- URL: http://localhost:8081
- Usuario: `admin`
- Contraseña: `pass123`

---

## 📝 Sintaxis Básica

### **Insertar UN documento**
```javascript
db.nombre_coleccion.insertOne({ campo: "valor" })
```

### **Insertar MÚLTIPLES documentos**
```javascript
db.nombre_coleccion.insertMany([
    { campo: "valor1" },
    { campo: "valor2" }
])
```

---

## 🚌 Ejemplos con Datos del Proyecto

### Insertar una Línea de Bus
```javascript
db.linhas.insertOne({
    nome: "Linha 100 - Centro",
    codigo: "100",
    tarifa: 5.50,
    tipo: "urban",
    empresa: {
        nome: "Viação Central",
        cnpj: "12.345.678/0001-90"
    },
    paraderos: [
        { nome: "Terminal", ordem: 1, tarifa: 5.50 },
        { nome: "Shopping", ordem: 2, tarifa: 7.00 },
        { nome: "Aeroporto", ordem: 3, tarifa: 12.00 }
    ],
    ativa: true
})
```

### Insertar un Pasajero
```javascript
db.passageiros.insertOne({
    nome: "João Silva",
    cpf: "123.456.789-00",
    email: "joao@email.com",
    telefone: "(19) 98765-4321",
    estudante: false,
    pontos_fidelidade: 150
})
```

### Insertar Múltiples Pasajeros
```javascript
db.passageiros.insertMany([
    {
        nome: "Maria Santos",
        cpf: "987.654.321-00",
        email: "maria@email.com",
        estudante: true,
        dados_estudante: {
            universidade: "UNICAMP",
            matricula: "RA123456"
        }
    },
    {
        nome: "Pedro Costa",
        cpf: "111.222.333-44",
        email: "pedro@email.com",
        estudante: false,
        pontos_fidelidade: 50
    }
])
```

### Insertar un Vehículo con Datos Anidados
```javascript
db.veiculos.insertOne({
    placa: "ABC-1234",
    marca: "Mercedes-Benz",
    modelo: "O500",
    ano: 2023,
    capacidade: 50,
    empresa: { nome: "Viação Central" },
    asientos: [
        { numero: "1", piso: 1, disponible: true },
        { numero: "2", piso: 1, disponible: true },
        { numero: "3", piso: 1, disponible: true }
        // ... más asientos
    ],
    status: "active"
})
```

### Insertar una Viagem (Viaje)
```javascript
db.viagens.insertOne({
    linha: "Linha 100 - Centro",
    veiculo_placa: "ABC-1234",
    motorista: "Carlos Silva",
    data: new Date("2025-11-20"),
    horario_saida: "08:00",
    horario_chegada: "09:30",
    status: "scheduled",
    capacidade_disponivel: 50,
    tickets: []  // Array vacío para tickets
})
```

---

## 🔍 Ver lo que Insertaste

### Ver todos los documentos de una colección
```javascript
db.linhas.find()
```

### Ver de forma legible (pretty)
```javascript
db.passageiros.find().pretty()
```

### Ver solo uno
```javascript
db.veiculos.findOne()
```

### Buscar con filtro
```javascript
db.passageiros.find({ estudante: true })
```

### Contar documentos
```javascript
db.linhas.countDocuments()
```

---

## 🗑️ Comandos Útiles

### Listar todas las colecciones
```javascript
show collections
```

### Listar todas las bases de datos
```javascript
show dbs
```

### Cambiar de base de datos
```javascript
use rododados_mongo
```

### Borrar un documento
```javascript
db.passageiros.deleteOne({ cpf: "123.456.789-00" })
```

### Borrar toda una colección
```javascript
db.nombre_coleccion.drop()
```

