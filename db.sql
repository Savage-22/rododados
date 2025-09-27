-- ================================
-- Tabelas base
-- ================================
create table if not exists Company (
    cnpj char(14) primary key,
    name varchar(255) not null
);

create table if not exists BusStop (
    id serial primary key,
    name varchar(255) not null,
    location varchar(255) not null unique
);

create table if not exists Route (
    id serial primary key,
    origin_id int not null,
    destination_id int not null,
    distance int not null,
    foreign key (origin_id) references BusStop(id) on delete cascade,
    foreign key (destination_id) references BusStop(id) on delete cascade,
    unique (origin_id, destination_id)
);

create table if not exists CompanyRoute (
    id serial primary key,
    cnpj char(14) not null,
    route_id int not null,
    foreign key (cnpj) references Company(cnpj) on delete cascade,
    foreign key (route_id) references Route(id) on delete cascade,
    unique (cnpj, route_id)
);

-- ================================
-- Veículos e assentos
-- ================================
create table if not exists Vehicle (
    license_plate char(7) primary key,
    brand varchar(255) not null,
    model varchar(255) not null
);

create table if not exists Seat (
    id serial primary key,
    seat_row char(2) not null,
    seat_column char(2) not null,
    license_plate char(7) not null,
    foreign key (license_plate) references Vehicle(license_plate) on delete cascade,
    unique (license_plate, seat_row, seat_column)
);

-- ================================
-- Passageiros e funcionários
-- ================================
create table if not exists Passenger (
    cpf char(11) primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    birthday date not null,
    email varchar(100) not null unique,
    phone varchar(15) not null,
    type_passenger varchar(20) not null
);

create table if not exists Employee (
    cpf char(11) primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    birthday date not null,
    email varchar(100) not null unique,
    phone varchar(15) not null,
    role varchar(100) not null,
	n_license varchar(20)
);

-- ================================
-- Rotas, horários e paradas
-- ================================
create table if not exists Schedule (
    id serial primary key,
    departure_time timestamp not null,
    arrival_time timestamp not null,
    travel_time interval not null,
    route_id int not null,
    foreign key (route_id) references Route(id) on delete cascade
);

create table if not exists ScheduleEmployee (
    schedule_id int not null,
    employee_cpf char(11) not null,
    foreign key (schedule_id) references Schedule(id) on delete cascade,
    foreign key (employee_cpf) references Employee(cpf) on delete cascade,
    unique (schedule_id, employee_cpf)
);

-- ================================
-- Assentos em horários e bilhetes
-- ================================
create table if not exists SeatOnSchedule (
    id serial primary key,
    seat_id int not null,
    schedule_id int not null,
    is_available boolean default true,
    foreign key (seat_id) references Seat(id) on delete cascade,
    foreign key (schedule_id) references Schedule(id) on delete cascade,
    unique (seat_id, schedule_id)
);

create table if not exists Ticket (
    id serial primary key,
    price decimal(10,2) not null,
    seat_on_schedule_id int not null,
    passenger_cpf char(11) not null,
    foreign key (seat_on_schedule_id) references SeatOnSchedule(id) on delete cascade,
    foreign key (passenger_cpf) references Passenger(cpf) on delete cascade
);
