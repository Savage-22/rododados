-- ================================
-- Empresas
-- ================================
insert into Company (cnpj, name) values
('12345678000195', 'TransBrasil'),
('98765432000111', 'ViaSul Transportes'),
('11122233000177', 'Rápido Campinas');

-- ================================
-- Paradas (BusStop)
-- ================================
insert into BusStop (name, location) values
('Terminal Central', 'Av. Brasil, 100 - Campinas/SP'),
('Rodoviária Campinas', 'Rua das Flores, 500 - Campinas/SP'),
('Rodoviária São Paulo', 'Av. Tietê, 1500 - São Paulo/SP'),
('Rodoviária Rio de Janeiro', 'Av. Presidente Vargas, 2000 - Rio de Janeiro/RJ'),
('Rodoviária Belo Horizonte', 'Av. Amazonas, 3000 - Belo Horizonte/MG'),
('Rodoviária Curitiba', 'Rua XV de Novembro, 700 - Curitiba/PR'),
('Rodoviária Florianópolis', 'Av. Beira Mar, 900 - Florianópolis/SC');

-- ================================
-- Rotas (Route)
-- ================================
insert into Route (origin_id, destination_id, distance) values
(1, 3, 100), -- Campinas -> SP
(3, 4, 450), -- SP -> RJ
(1, 5, 580), -- Campinas -> BH
(5, 6, 830), -- BH -> Curitiba
(6, 7, 300); -- Curitiba -> Floripa

-- ================================
-- Associa empresa a rota (CompanyRoute)
-- ================================
insert into CompanyRoute (cnpj, route_id) values
('12345678000195', 1),
('12345678000195', 2),
('98765432000111', 3),
('11122233000177', 4),
('11122233000177', 5);

-- ================================
-- Veículos
-- ================================
insert into Vehicle (license_plate, model, brand) values
('ABC1D23', 'Marcopolo G7', 'Mercedes-Benz'),
('XYZ9K88', 'Marcopolo G8', 'Volvo'),
('JKL5H67', 'Irizar i6', 'Scania');

-- ================================
-- Assentos
-- (4 fileiras x 2 colunas = 8 assentos por veículo)
-- ================================
insert into Seat (seat_row, seat_column, license_plate) values
('1', 'A', 'ABC1D23'), ('1', 'B', 'ABC1D23'),
('2', 'A', 'ABC1D23'), ('2', 'B', 'ABC1D23'),
('3', 'A', 'ABC1D23'), ('3', 'B', 'ABC1D23'),
('4', 'A', 'ABC1D23'), ('4', 'B', 'ABC1D23'),

('1', 'A', 'XYZ9K88'), ('1', 'B', 'XYZ9K88'),
('2', 'A', 'XYZ9K88'), ('2', 'B', 'XYZ9K88'),
('3', 'A', 'XYZ9K88'), ('3', 'B', 'XYZ9K88'),
('4', 'A', 'XYZ9K88'), ('4', 'B', 'XYZ9K88'),

('1', 'A', 'JKL5H67'), ('1', 'B', 'JKL5H67'),
('2', 'A', 'JKL5H67'), ('2', 'B', 'JKL5H67'),
('3', 'A', 'JKL5H67'), ('3', 'B', 'JKL5H67'),
('4', 'A', 'JKL5H67'), ('4', 'B', 'JKL5H67');

-- ================================
-- Funcionários (Employee)
-- ================================
insert into Employee (cpf, first_name, last_name, birthday, email, phone, role, n_license) values
-- Motoristas
('55555555555', 'João', 'Pereira', '1975-11-02', 'joao.pereira@transbrasil.com', '11911112222', 'Motorista', 'CNH123456'),
('66666666666', 'Marcos', 'Oliveira', '1982-04-12', 'marcos.oliveira@viasul.com', '21922223333', 'Motorista', 'CNH987654'),
('77777777777', 'Rafael', 'Costa', '1987-08-23', 'rafael.costa@rapidocampinas.com', '31933334444', 'Motorista', 'CNH456789'),
('88888888888', 'Luciana', 'Souza', '1990-06-10', 'luciana.souza@viasul.com', '11944445555', 'Motorista', 'CNH112233'),

-- Atendentes
('11111111111', 'Carlos', 'Silva', '1985-03-20', 'carlos.silva@transbrasil.com', '11987654321', 'Atendente', null),
('22222222222', 'Fernanda', 'Souza', '1990-07-15', 'fernanda.souza@viasul.com', '11912345678', 'Atendente', null),

-- Fiscais
('33333333333', 'Juliana', 'Mendes', '1988-01-10', 'juliana.mendes@rapidocampinas.com', '19945678901', 'Fiscal', null),

-- Mecânicos
('44444444444', 'Paulo', 'Lima', '1980-09-05', 'paulo.lima@transbrasil.com', '21998765432', 'Mecânico', null),
('99999999999', 'Roberto', 'Fernandes', '1979-12-19', 'roberto.fernandes@viasul.com', '21966667777', 'Mecânico', null);


-- ================================
-- Passageiros
-- ================================
insert into Passenger (cpf, first_name, last_name, birthday, email, phone, type_passenger) values
('88888888888', 'Ana', 'Martins', '1995-12-25', 'ana@gmail.com', '11955556666', 'Regular'),
('99999999999', 'Bruno', 'Almeida', '2000-02-14', 'bruno@gmail.com', '21977778888', 'Estudante'),
('12312312312', 'Clara', 'Rodrigues', '1960-05-30', 'clara@gmail.com', '31999990000', 'Idoso'),
('32132132132', 'Diego', 'Ferreira', '1992-09-18', 'diego@gmail.com', '41911112222', 'Regular');

-- ================================
-- Horários (Schedule)
-- ================================
insert into Schedule (departure_time, arrival_time, travel_time, route_id) values
('2025-10-01 08:00:00', '2025-10-01 10:00:00', '2 hours', 1),
('2025-10-01 14:00:00', '2025-10-01 20:00:00', '6 hours', 2),
('2025-10-02 07:00:00', '2025-10-02 16:00:00', '9 hours', 3),
('2025-10-02 09:00:00', '2025-10-02 20:00:00', '11 hours', 4),
('2025-10-03 06:00:00', '2025-10-03 10:00:00', '4 hours', 5);

-- ================================
-- Alocação de funcionários/motoristas em horários
-- ================================
insert into ScheduleEmployee (schedule_id, employee_cpf) values
(1, '11111111111'), (1, '33333333333'),
(2, '22222222222'), (3, '44444444444');

-- ================================
-- Assentos em horários (SeatOnSchedule)
-- (Aqui coloco só alguns, mas a ideia é expandir todos assentos/veículos)
-- ================================
insert into SeatOnSchedule (seat_id, schedule_id, is_available) values
(1, 1, true), (2, 1, true), (3, 1, false),
(4, 2, true), (5, 2, true), (6, 2, false),
(7, 3, true), (8, 3, false), (9, 3, true);

-- ================================
-- Tickets
-- ================================
insert into Ticket (price, seat_on_schedule_id, passenger_cpf) values
(59.90, 3, '88888888888'),
(120.00, 6, '99999999999'),
(200.00, 8, '12312312312');