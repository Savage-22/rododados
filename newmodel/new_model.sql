-- Eliminar tabelas se existirem (para reiniciar o BD limpo)
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS trip CASCADE;
DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS route_stop CASCADE;
DROP TABLE IF EXISTS seat CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS seller CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS vehicle CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS bus_stop CASCADE;
DROP TABLE IF EXISTS company CASCADE;

-- =====================================================
-- TABELA: Company
-- Armazena as empresas de transporte que operam no sistema
-- =====================================================
CREATE TABLE company (
    id_company SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE, -- Identificação fiscal Brasil (formato: 00.000.000/0000-00)
    email VARCHAR(150),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_cnpj_format CHECK (cnpj ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$')
);

-- Índice para buscas por nome
CREATE INDEX idx_company_name ON company(name);

COMMENT ON TABLE company IS 'Empresas operadoras de transporte público';
COMMENT ON COLUMN company.cnpj IS 'Cadastro Nacional da Pessoa Jurídica - identificação fiscal';

-- =====================================================
-- TABELA: Bus_Stop
-- Paradas de ônibus independentes que podem ser utilizadas por múltiplas rotas
-- =====================================================
CREATE TABLE bus_stop (
    id_stop SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    street VARCHAR(200),
    number VARCHAR(20),
    city VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATE DEFAULT CURRENT_DATE
);

-- Índices para buscas
CREATE INDEX idx_bus_stop_city ON bus_stop(city);
CREATE INDEX idx_bus_stop_name ON bus_stop(name);
CREATE INDEX idx_bus_stop_active ON bus_stop(is_active);

COMMENT ON TABLE bus_stop IS 'Paradas de ônibus reutilizáveis entre diferentes rotas';

-- =====================================================
-- TABELA: Route
-- Rotas gerais operadas pelas empresas (ex: "Centro - Terminal Norte")
-- =====================================================
CREATE TABLE route (
    id_route SERIAL PRIMARY KEY,
    id_company INT NOT NULL,
    route_code VARCHAR(50) NOT NULL, -- Código único da rota (ex: "R-001")
    name VARCHAR(200) NOT NULL, -- Nome descritivo
    description TEXT,
    total_distance DECIMAL(8, 2), -- Distância total em quilômetros
    route_type VARCHAR(20) NOT NULL DEFAULT 'urban', -- 'urban', 'interurban', 'express'
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_company) REFERENCES Company(id_company) ON DELETE RESTRICT,
    
    CONSTRAINT chk_route_type CHECK (route_type IN ('urban', 'interurban', 'express')),
    CONSTRAINT chk_distance CHECK (total_distance IS NULL OR total_distance > 0),
    UNIQUE (id_company, route_code) -- O código deve ser único por empresa
);

-- Índices
CREATE INDEX idx_route_company ON route(id_company);
CREATE INDEX idx_route_active ON route(is_active);
CREATE INDEX idx_route_type ON route(route_type);

COMMENT ON TABLE route IS 'Rotas de transporte operadas pelas empresas';
COMMENT ON COLUMN route.route_type IS 'Tipo de rota: urban (urbano), interurban (intermunicipal), express (expresso)';

-- =====================================================
-- TABELA: Route_Stop
-- Tabela intermediária: define o PERCURSO de cada rota
-- Conecta Route com Bus_Stop e define ordem e tarifas
-- =====================================================
CREATE TABLE route_stop (
    id_route INT NOT NULL,
    id_stop INT NOT NULL,
    stop_order INT NOT NULL, -- Ordem da parada no percurso (1, 2, 3...)
    distance_from_origin DECIMAL(8, 2) NOT NULL DEFAULT 0, -- Km desde a origem
    estimated_min INT NOT NULL DEFAULT 0, -- Minutos estimados desde a origem
    fare_from_origin DECIMAL(8, 2) NOT NULL DEFAULT 0.00, -- Preço acumulado desde a origem
    
    PRIMARY KEY (id_route, id_stop),
    FOREIGN KEY (id_route) REFERENCES route(id_route) ON DELETE CASCADE,
    FOREIGN KEY (id_stop) REFERENCES bus_stop(id_stop) ON DELETE RESTRICT,
    
    -- Uma rota não pode ter duas paradas com a mesma ordem
    UNIQUE (id_route, stop_order),
    
    CONSTRAINT chk_stop_order CHECK (stop_order > 0),
    CONSTRAINT chk_distance_positive CHECK (distance_from_origin >= 0),
    CONSTRAINT chk_time_positive CHECK (estimated_min >= 0),
    CONSTRAINT chk_fare_positive CHECK (fare_from_origin >= 0)
);

-- Índice para consultas de percurso ordenado
CREATE INDEX idx_route_stop_order ON route_stop(id_route, stop_order);

COMMENT ON TABLE route_stop IS 'Define o percurso completo de cada rota com ordem, distâncias e tarifas';
COMMENT ON COLUMN route_stop.stop_order IS 'Posição da parada no percurso (1=primeira, 2=segunda, etc.)';
COMMENT ON COLUMN route_stop.fare_from_origin IS 'Tarifa acumulada desde a origem - permite calcular preço entre paradas';

-- =====================================================
-- TABELA: Schedule
-- Horários programados para cada rota (ex: sai às 8:00 todos os dias)
-- =====================================================
CREATE TABLE schedule (
    id_schedule SERIAL PRIMARY KEY,
    id_route INT NOT NULL,
    id_company INT NOT NULL,
    departure_time TIME NOT NULL, -- Hora de saída (ex: 08:00:00)
    arrival_time TIME, -- Hora de chegada estimada (opcional)
    days_of_week JSONB DEFAULT '[1,2,3,4,5,6,7]', -- Dias que opera (1=segunda, 7=domingo)
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_route) REFERENCES route(id_route) ON DELETE CASCADE,
    FOREIGN KEY (id_company) REFERENCES company(id_company) ON DELETE RESTRICT
);

-- Índices
CREATE INDEX idx_schedule_route ON schedule(id_route);
CREATE INDEX idx_schedule_company ON schedule(id_company);
CREATE INDEX idx_schedule_days ON schedule USING GIN (days_of_week);

COMMENT ON TABLE schedule IS 'Horários programados recorrentes para as rotas';
COMMENT ON COLUMN schedule.days_of_week IS 'Array JSON com dias que opera: [1,2,3,4,5] = segunda a sexta';

-- =====================================================
-- TABELA: Vehicle
-- Veículos (ônibus, micro-ônibus) propriedade das empresas
-- =====================================================
CREATE TABLE vehicle (
    id_vehicle SERIAL PRIMARY KEY,
    id_company INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE, -- Placa do veículo
    brand VARCHAR(100),
    model VARCHAR(100),
    year INT,
    capacity INT NOT NULL, -- Capacidade total de passageiros
    vehicle_type VARCHAR(20) NOT NULL DEFAULT 'urban_bus', -- 'urban_bus', 'microbus', 'coach'
    has_assigned_seating BOOLEAN DEFAULT FALSE, -- TRUE = assentos numerados, FALSE = livre
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'maintenance', 'retired'
    last_maintenance_date DATE,
    created_at DATE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_company) REFERENCES Company(id_company) ON DELETE RESTRICT,
    
    CONSTRAINT chk_capacity CHECK (capacity > 0),
    CONSTRAINT chk_year CHECK (year IS NULL OR (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1)),
    CONSTRAINT chk_vehicle_type CHECK (vehicle_type IN ('urban_bus', 'microbus', 'coach')),
    CONSTRAINT chk_vehicle_status CHECK (status IN ('active', 'maintenance', 'retired'))
);

-- Índices
CREATE INDEX idx_vehicle_company ON vehicle(id_company);
CREATE INDEX idx_vehicle_status ON vehicle(status);
CREATE INDEX idx_vehicle_plate ON vehicle(license_plate);

COMMENT ON TABLE vehicle IS 'Veículos de transporte público';
COMMENT ON COLUMN vehicle.has_assigned_seating IS 'FALSE = transporte urbano (assentos livres), TRUE = interurbano (assentos atribuídos)';
COMMENT ON COLUMN vehicle.capacity IS 'Número total de passageiros que pode transportar';

-- =====================================================
-- TABELA: Seat
-- Assentos numerados (somente para veículos com has_assigned_seating = TRUE)
-- =====================================================
CREATE TABLE seat (
    id_seat SERIAL PRIMARY KEY,
    id_vehicle INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL, -- Número do assento (1, 2, 3... ou 1A, 1B, etc.)
    floor INT DEFAULT 1, -- Para ônibus de dois andares (1 ou 2)
    is_active BOOLEAN DEFAULT TRUE, -- Permite desativar assentos temporariamente
    
    FOREIGN KEY (id_vehicle) REFERENCES vehicle(id_vehicle) ON DELETE CASCADE,
    
    UNIQUE (id_vehicle, seat_number),
    
    CONSTRAINT chk_floor CHECK (floor IN (1, 2))
);

-- Índice para busca de assentos disponíveis
CREATE INDEX idx_seat_vehicle ON seat(id_vehicle, is_active);

COMMENT ON TABLE seat IS 'Assentos numerados - são criados apenas para veículos com assentos atribuídos';

-- =====================================================
-- TABELA: Person
-- Entidade base para TODAS as pessoas no sistema
-- =====================================================
CREATE TABLE person (
    id_person SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE, -- CPF da pessoa (formato: 000.000.000-00)
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    birthday DATE,
    person_type VARCHAR(20) NOT NULL, -- 'passenger' ou 'employee'
    created_at DATE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_person_type CHECK (person_type IN ('passenger', 'employee')),
    CONSTRAINT chk_birthday CHECK (birthday IS NULL OR birthday <= CURRENT_DATE),
    CONSTRAINT chk_cpf_format CHECK (cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$')
);

-- Índices
CREATE INDEX idx_person_type ON person(person_type);
CREATE INDEX idx_person_email ON person(email);

COMMENT ON TABLE person IS 'Entidade base - todos os usuários herdam daqui';
COMMENT ON COLUMN person.cpf IS 'Cadastro de Pessoas Físicas - identificação pessoal Brasil';
COMMENT ON COLUMN person.person_type IS 'Tipo de pessoa: passenger (passageiro) ou employee (funcionário)';

-- =====================================================
-- TABELA: Passenger
-- Subtipo de Person - passageiros que usam o sistema
-- =====================================================
CREATE TABLE passenger (
    id_person INT PRIMARY KEY,
    loyalty_points INT DEFAULT 0, -- Pontos de fidelidade (opcional)
    is_student BOOLEAN DEFAULT FALSE, -- Indica se é estudante
    
    FOREIGN KEY (id_person) REFERENCES Person(id_person) ON DELETE CASCADE,
    
    CONSTRAINT chk_loyalty_points CHECK (loyalty_points >= 0)
);

COMMENT ON TABLE passenger IS 'Passageiros do sistema de transporte';
COMMENT ON COLUMN passenger.is_student IS 'TRUE se o passageiro é estudante (terá registro em Student)';

-- =====================================================
-- TABELA: Student
-- Sub-subtipo de Passenger - estudantes com descontos
-- =====================================================
CREATE TABLE student (
    id_person INT PRIMARY KEY,
    id_u VARCHAR(50) NOT NULL UNIQUE, -- ID universitário
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'inactive', 'graduated'
    university_name VARCHAR(200),
    enrollment_date DATE DEFAULT CURRENT_DATE,
    
    FOREIGN KEY (id_person) REFERENCES passenger(id_person) ON DELETE CASCADE,
    
    CONSTRAINT chk_student_status CHECK (status IN ('active', 'inactive', 'graduated'))
);

-- Índices
CREATE INDEX idx_student_status ON student(status);
CREATE INDEX idx_student_university ON student(university_name);

COMMENT ON TABLE student IS 'Estudantes com descontos especiais - herda de Passenger';

-- =====================================================
-- TABELA: Employee
-- Subtipo de Person - funcionários das empresas de transporte
-- =====================================================
CREATE TABLE employee (
    id_person INT PRIMARY KEY,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    id_company INT NOT NULL,
    hire_date DATE DEFAULT CURRENT_DATE,
    salary DECIMAL(10, 2),
    employee_type VARCHAR(20) NOT NULL, -- 'driver', 'seller', 'admin', 'mechanic'
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (id_person) REFERENCES person(id_person) ON DELETE CASCADE,
    FOREIGN KEY (id_company) REFERENCES company(id_company) ON DELETE RESTRICT,
    
    CONSTRAINT chk_employee_type CHECK (employee_type IN ('driver', 'seller', 'admin', 'mechanic')),
    CONSTRAINT chk_salary CHECK (salary IS NULL OR salary >= 0)
);

-- Índices
CREATE INDEX idx_employee_company ON employee(id_company);
CREATE INDEX idx_employee_type ON employee(employee_type);
CREATE INDEX idx_employee_active ON employee(is_active);

COMMENT ON TABLE employee IS 'Funcionários das empresas de transporte';
COMMENT ON COLUMN employee.employee_type IS 'Tipo: driver (motorista), seller (vendedor), admin (administrativo), mechanic (mecânico)';

-- =====================================================
-- TABELA: Driver
-- Sub-subtipo de Employee - motoristas de veículos
-- =====================================================
CREATE TABLE driver (
    id_person INT PRIMARY KEY,
    license_number VARCHAR(50) NOT NULL UNIQUE, -- Número da carteira de motorista
    license_category VARCHAR(10) NOT NULL,
    license_expiry_date DATE NOT NULL,
    
    FOREIGN KEY (id_person) REFERENCES employee(id_person) ON DELETE CASCADE,
    
    CONSTRAINT chk_license_valid CHECK (license_expiry_date > CURRENT_DATE)
);

-- Índice para verificar licenças vigentes
CREATE INDEX idx_driver_license_expiry ON driver(license_expiry_date);

COMMENT ON TABLE driver IS 'Motoristas - herda de Employee';
COMMENT ON COLUMN driver.license_category IS 'Categoria de habilitação brasileira: D (ônibus), E (articulados)';

-- =====================================================
-- TABELA: Seller
-- Sub-subtipo de Employee - vendedores de tickets
-- =====================================================
CREATE TABLE seller (
    id_person INT PRIMARY KEY,
    terminal_id INT, -- ID do terminal/bilheteria atribuído
    
    FOREIGN KEY (id_person) REFERENCES employee(id_person) ON DELETE CASCADE
);

COMMENT ON TABLE seller IS 'Vendedores de tickets - herda de Employee';

-- =====================================================
-- TABELA: Trip
-- Instância ESPECÍFICA de um horário em uma data concreta
-- Esta é a tabela CHAVE do sistema
-- =====================================================
CREATE TABLE trip (
    id_trip SERIAL PRIMARY KEY,
    id_schedule INT NOT NULL, -- De qual horário provém
    id_vehicle INT NOT NULL, -- Qual veículo foi atribuído
    id_driver INT NOT NULL, -- Quem dirige
    trip_date DATE NOT NULL, -- Data da viagem
    departure_datetime TIMESTAMP NOT NULL, -- Data e hora de saída programada
    arrival_datetime TIMESTAMP, -- Data e hora de chegada programada
    status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    available_capacity INT NOT NULL, -- Vagas disponíveis (atualiza ao vender tickets)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_schedule) REFERENCES schedule(id_schedule) ON DELETE RESTRICT,
    FOREIGN KEY (id_vehicle) REFERENCES vehicle(id_vehicle) ON DELETE RESTRICT,
    FOREIGN KEY (id_driver) REFERENCES driver(id_person) ON DELETE RESTRICT,
    
    CONSTRAINT chk_trip_status CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT chk_available_capacity CHECK (available_capacity >= 0),
    CONSTRAINT chk_departure_before_arrival CHECK (arrival_datetime IS NULL OR departure_datetime < arrival_datetime)
);

-- Índices para consultas frequentes
CREATE INDEX idx_trip_schedule ON trip(id_schedule);
CREATE INDEX idx_trip_vehicle ON trip(id_vehicle);
CREATE INDEX idx_trip_driver ON trip(id_driver);
CREATE INDEX idx_trip_date ON trip(trip_date, status);
CREATE INDEX idx_trip_datetime ON trip(departure_datetime);

COMMENT ON TABLE trip IS 'Viagem específica - instância concreta de um horário em uma data';
COMMENT ON COLUMN trip.available_capacity IS 'Capacidade disponível - decrementa ao vender cada ticket';

-- =====================================================
-- TABELA: Ticket
-- Tickets vendidos - adaptável para transporte urbano e interurbano
-- =====================================================
CREATE TABLE ticket (
    id_ticket SERIAL PRIMARY KEY,
    id_trip INT NOT NULL, -- A qual viagem específica pertence
    id_passenger INT NOT NULL, -- Quem comprou o ticket
    id_seller INT, -- Quem vendeu (NULL para vendas online)
    id_company INT NOT NULL, -- Empresa que emite o ticket
    id_seat INT, -- Assento atribuído (NULL para transporte urbano sem assentos)
    id_boarding_stop INT NOT NULL, -- Onde o passageiro embarca
    id_destination_stop INT NOT NULL, -- Onde o passageiro desembarca
    price DECIMAL(8, 2) NOT NULL, -- Preço pago
    discount_applied DECIMAL(8, 2) DEFAULT 0.00, -- Desconto aplicado
    discount_reason VARCHAR(50), -- 'student', 'senior', 'promotion', etc.
    payment_method VARCHAR(20) NOT NULL DEFAULT 'cash', -- 'cash', 'card', 'transfer', 'wallet'
    status VARCHAR(20) DEFAULT 'paid', -- 'reserved', 'paid', 'used', 'cancelled', 'expired'
    purchase_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data e hora da compra
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_trip) REFERENCES trip(id_trip) ON DELETE RESTRICT,
    FOREIGN KEY (id_passenger) REFERENCES passenger(id_person) ON DELETE RESTRICT,
    FOREIGN KEY (id_seller) REFERENCES seller(id_person) ON DELETE SET NULL,
    FOREIGN KEY (id_company) REFERENCES company(id_company) ON DELETE RESTRICT,
    FOREIGN KEY (id_seat) REFERENCES seat(id_seat) ON DELETE RESTRICT,
    FOREIGN KEY (id_boarding_stop) REFERENCES bus_stop(id_stop) ON DELETE RESTRICT,
    FOREIGN KEY (id_destination_stop) REFERENCES bus_stop(id_stop) ON DELETE RESTRICT,
    
    -- Um assento não pode ser vendido duas vezes na mesma viagem (somente se tiver assento atribuído)
    UNIQUE (id_trip, id_seat),
    
    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_discount CHECK (discount_applied >= 0 AND discount_applied <= price),
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('cash', 'card', 'transfer', 'wallet', 'pix')),
    CONSTRAINT chk_ticket_status CHECK (status IN ('reserved', 'paid', 'used', 'cancelled', 'expired')),
    CONSTRAINT chk_different_stops CHECK (id_boarding_stop != id_destination_stop)
);

-- Índices importantes
CREATE INDEX idx_ticket_trip ON ticket(id_trip, status);
CREATE INDEX idx_ticket_passenger ON ticket(id_passenger);
CREATE INDEX idx_ticket_seller ON ticket(id_seller);
CREATE INDEX idx_ticket_company ON ticket(id_company);
CREATE INDEX idx_ticket_purchase_date ON ticket(purchase_datetime);
CREATE INDEX idx_ticket_seller_date ON ticket(id_seller, purchase_datetime);

COMMENT ON TABLE ticket IS 'Tickets vendidos - flexível para transporte urbano (sem assento) e interurbano (com assento)';
COMMENT ON COLUMN ticket.id_seat IS 'NULL para transporte urbano, assento específico para interurbano';
COMMENT ON COLUMN ticket.discount_reason IS 'Razão do desconto: student, senior, promotion, etc.';
COMMENT ON COLUMN ticket.id_company IS 'Empresa que emite o ticket - obtido da rota da viagem';
COMMENT ON COLUMN ticket.purchase_datetime IS 'Data e hora exata da compra do ticket';